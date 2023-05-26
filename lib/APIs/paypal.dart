import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindah/APIs/currency_converter.dart';
import 'package:kindah/POS/models/pos_product.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/models/uniform.dart';
import 'package:url_launcher/url_launcher.dart';

class PayPal {
  final String baseDomain = "https://kindahclothing.web.app";
  // "http://localhost:57246";
  final String cancelUrl = "https://kindahclothing.web.app/home";

  Future<void> _launchUrl(String link) async {
    if (!await launchUrl(Uri.parse(link))) {
      throw Exception('Could not launch $link');
    }
  }

  Future<String> posPayment(
      String data, double totalAmount, String phone) async {
    List<POSProduct> products = POSProduct.decode(data);
    final String docID = DateTime.now().millisecondsSinceEpoch.toString();

    String returnUrl = "$baseDomain/paypal_success/${phone}_$docID";

    double exchangeRate = await CurrencyConverter().convertCurrency(
        amount: totalAmount, fromCurrency: "KES", toCurrency: "USD");

    print(exchangeRate);

    var createPaymentJson = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "redirect_urls": {
        "return_url": returnUrl,
        "cancel_url": cancelUrl,
      },
      "transactions": [
        {
          "item_list": {
            "items": List.generate(products.length, (index) {
              POSProduct product = products[index];
              return {
                "name": product.name,
                "sku": product.name,
                "price": (product.price! * exchangeRate).toString(),
                "currency": "USD",
                "quantity": product.quantity
              };
            })
          },
          "amount": {
            "currency": "USD",
            "total": (totalAmount * exchangeRate).toString()
          },
          "description": "Payment for Point Of Sale Items"
        }
      ]
    };

    String result = await processPayment(createPaymentJson, docID);

    return result;
  }

  Future<String> uniformPayment(
      String data, double totalAmount, String phone) async {
    List<Uniform> uniforms = Uniform.decode(data);

    final String docID = DateTime.now().millisecondsSinceEpoch.toString();

    String returnUrl = "$baseDomain/paypal_success/${phone}_$docID";

    double exchangeRate = await CurrencyConverter().convertCurrency(
        amount: totalAmount, fromCurrency: "KES", toCurrency: "USD");

    print(exchangeRate);
    var createPaymentJson = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "redirect_urls": {"return_url": returnUrl, "cancel_url": cancelUrl},
      "transactions": [
        {
          "item_list": {
            "items": List.generate(uniforms.length, (index) {
              Uniform uniform = uniforms[index];

              return {
                "name": uniform.name,
                "sku": uniform.name,
                "price": (uniform.unitPrice! * exchangeRate).toString(),
                "currency": "USD",
                "quantity": uniform.quantity
              };
            })
          },
          "amount": {
            "currency": "USD",
            "total": (totalAmount * exchangeRate).toString()
          },
          "description": "Payment for purchase of uniforms."
        }
      ]
    };

    String result = await processPayment(createPaymentJson, docID);

    return result;
  }

  Future<String> ecommercePayment(
      String data, double totalAmount, String phone) async {
    List<Product> products = Product.decode(data);

    final String docID = DateTime.now().millisecondsSinceEpoch.toString();

    String returnUrl = "$baseDomain/paypal_success/${phone}_$docID";

    double exchangeRate = await CurrencyConverter().convertCurrency(
        amount: totalAmount, fromCurrency: "KES", toCurrency: "USD");

    print(exchangeRate);

    var createPaymentJson = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "redirect_urls": {"return_url": returnUrl, "cancel_url": cancelUrl},
      "transactions": [
        {
          "item_list": {
            "items": List.generate(products.length, (index) {
              Product product = products[index];

              return {
                "name": product.title,
                "sku": product.title,
                "price": (product.price! * exchangeRate).toString(),
                "currency": "USD",
                "quantity": product.quantity
              };
            })
          },
          "amount": {
            "currency": "USD",
            "total": (totalAmount * exchangeRate).toString()
          },
          "description": "Payment for purchasing items"
        }
      ]
    };

    String result = await processPayment(createPaymentJson, docID);

    return result;
  }

  Future<String> processPayment(var createPaymentJson, String docID) async {
    await FirebaseFirestore.instance
        .collection("paypal_requests")
        .doc(docID)
        .set(createPaymentJson);

    Completer<String> completer = Completer();
    int count = 0;

    print("==========1==========");

    Timer timer =
        Timer.periodic(const Duration(seconds: 30), (Timer timer) async {
      count++;

      print('Task performed $count time(s)');

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("paypal_responses")
          .doc(docID)
          .get();

      if (documentSnapshot.exists) {
        timer.cancel();

        print(documentSnapshot.id);

        List<dynamic> links = documentSnapshot["links"];

        for (int i = 0; i < links.length; i++) {
          if (links[i]["rel"] == "approval_url") {
            await _launchUrl(links[i]["href"]);
          }
        }

        // show dialog to get data
        // String

        completer.complete("failed");
      } else if (count == 10 && !documentSnapshot.exists) {
        print("Could not get document");

        timer.cancel();

        completer.complete("failed");
      }
    });

    String status = await completer.future;

    print("==========2=========");

    print(status);

    return status;
  }
}

// sF3L$QF7
