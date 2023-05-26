import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'request_assistant.dart';

class MPesa {
  final String consumerKey = "oXk44ItQDR2DvJDQcDCyTpGGigl3rkJ2";
  final String consumerSecret = "aAYzGUsQWXNvuvEH";
  final String businessShortCode = "174379";
  final String passkey =
      "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
  final String transactionType = "CustomerPayBillOnline";
  final String callbackUrl =
      "https://us-central1-kindahclothing.cloudfunctions.net/callback";
  final String transactionDesc = "Payment for template";

  final String authEndpoint =
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
  final String processRequestUrl =
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

  //Generate base64 code
  String getBasicAuthorization() {
    var bytes = utf8.encode("$consumerKey:$consumerSecret");
    var base64Encode = base64.encode(bytes);

    return base64Encode;
  }

  String password({String? shortCode, String? passKey, String? timestamp}) {
    var bytes = utf8.encode(shortCode! + passKey! + timestamp!);
    var base64Encode = base64.encode(bytes);

    return base64Encode;
  }

  Map<String, String> buildBasicHeaders() {
    String basicAuth = getBasicAuthorization();

    return {
      "Authorization": 'Basic $basicAuth',
    };
  }

  //Obtain access token
  Future<String> accessToken() async {
    Map<String, String> headers = buildBasicHeaders();

    var result =
        await RequestAssistant.getRequest(authEndpoint, headers: headers);

    return result["access_token"];
  }

  //build bearer headers
  Future<Map<String, String>> buildBearerHeaders() async {
    String generatedAccessToken = await accessToken();

    return {
      "Content-Type": "application/json",
      "Authorization": 'Bearer $generatedAccessToken',
      'Access-Control-Allow-Origin': 'https://sandbox.safaricom.co.ke'
    };
  }

  String encodeData(Object input) {
    return json.encode(input);
  }

  Object decodeData(String input) {
    return json.decode(input);
  }

  Future<String> authorizeMobileTransaction(
      {String? amount, String? phone}) async {
    Map<String, String> bearerHeaders = await buildBearerHeaders();

    String timestamp = DateFormat("yyyyMMddHHmmss").format(DateTime.now());

    String generatedPassword = password(
        shortCode: businessShortCode, passKey: passkey, timestamp: timestamp);

    Map<String, String> requestBody = {
      "BusinessShortCode": businessShortCode,
      "Timestamp": timestamp,
      "Password": generatedPassword,
      "TransactionType": transactionType,
      "Amount": "1",
      "PartyA": phone!,
      "PartyB": businessShortCode,
      "PhoneNumber": phone,
      "CallBackURL": callbackUrl,
      "AccountReference": phone,
      "TransactionDesc": transactionDesc,
    };

    final body = jsonEncode(requestBody);

    try {
      var result = await RequestAssistant.postRequest(processRequestUrl,
          headers: bearerHeaders, body: body);

      return encodeData(result);
    } catch (e) {
      print(e.toString());

      return encodeData("failed");
    }
  }

  Future<String> processTransaction({String? amount, String? phone}) async {
    if (kIsWeb) {
      // Send payment request to server
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> feedback = {};

      Map<String, dynamic> request = {
        "id": timestamp.toString(),
        "phone": phone,
        "status": "pending",
        "amount": "1",
        "timestamp": timestamp,
        "feedback": {}
      };

      await FirebaseFirestore.instance
          .collection("payment_request")
          .doc(timestamp.toString())
          .set(request);

      StreamSubscription<DocumentSnapshot> subscription = FirebaseFirestore
          .instance
          .collection("payment_request")
          .doc(timestamp.toString())
          .snapshots()
          .listen((docSnapshot) async {
        if (docSnapshot["status"] == 'success') {
          feedback = docSnapshot["feedback"];
        }
      });

      // Wait for a few seconds before cancelling subscription
      await Future.delayed(const Duration(seconds: 15));
      subscription.cancel();

      if (feedback.isNotEmpty) {
        var finalResult = await listenForPayment(feedback);

        return finalResult;
      } else {
        print("===========\n An error occured \n==============");

        return encodeData("failed");
      }
    } else {
      var result =
          await authorizeMobileTransaction(amount: amount, phone: phone);

      var output = decodeData(result);

      if (output != 'failed') {
        var finalResult =
            await listenForPayment(output as Map<String, dynamic>);

        return finalResult;
      } else {
        print("===========\n An error occured \n==============");

        return encodeData("failed");
      }
    }
  }

  Future<String> listenForPayment(Map<String, dynamic> stkPushResponse) async {
    if (stkPushResponse["ResponseCode"] == "0" ||
        stkPushResponse["ResponseCode"] == 0) {
      // Pin prompt successfull

      await Future.delayed(const Duration(seconds: 60));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("mpesa")
          .where("Body.stkCallback.MerchantRequestID",
              isEqualTo: stkPushResponse["MerchantRequestID"])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (querySnapshot.docs[0]["Body"]["stkCallback"]["ResultCode"] == 0) {
          int phoneNumber = querySnapshot.docs[0]["Body"]["stkCallback"]
              ["CallbackMetadata"]["Item"][4]["Value"];
          int amount = querySnapshot.docs[0]["Body"]["stkCallback"]
              ["CallbackMetadata"]["Item"][0]["Value"];
          String receiptNumber = querySnapshot.docs[0]["Body"]["stkCallback"]
              ["CallbackMetadata"]["Item"][1]["Value"];
          String merchantRequestID = stkPushResponse["MerchantRequestID"];
          String checkoutRequestID = querySnapshot.docs[0].id;

          Map<String, dynamic> paymentInfo = {
            "payment_method": "M-Pesa",
            "status": "paid",
            "amount": amount,
            "contact": phoneNumber,
            "MpesaReceiptNumber": receiptNumber,
            "MerchantRequestID": merchantRequestID,
            "CheckoutRequestID": checkoutRequestID
          };

          return encodeData(paymentInfo);
        } else {
          print("================\nUser Cancelled Request\n===============");

          return encodeData("failed");
        }
      } else {
        print("================\nAn ERROR Occurred\n===============");

        return encodeData("failed");
      }
    } else {
      // Error occurred

      print("================\nAn ERROR Occurred\n===============");

      return encodeData("failed");
    }
  }
}
