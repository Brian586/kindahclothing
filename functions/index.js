const functions = require("firebase-functions");
const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');

let unirest = require('unirest');

var moment = require('moment');

var paypal = require('paypal-rest-sdk');

initializeApp();

const db = getFirestore();

paypal.configure({
    'mode': 'sandbox', //sandbox or live
    'client_id': 'AcrUc1yBhfzFEDCz6JUexLMpY_OCEPbFCziJf55nS9yS16_5mHYPIRVnGb0IGhIGREqvaf9LD1tZyRCj',
    'client_secret': 'EGuCfJdiwQ861bQ1lmXY5uzg7OyDSfaQ51YvJh95fBT8p_oz7d3MGaGhAn_85BoZXm0V9NrwJZSMH9gW'
  });

const credentials = {
    apiKey: '87715da2e24548fc672e2fd50d03d8c5a7152af596703917fa87a1715d96be8c',      
    username: 'kindahstore',    
};
const Africastalking = require('africastalking')(credentials);

// Initialize a service e.g. SMS
const sms = Africastalking.SMS


function getBase64Encode(data) {
    let keySecretData = `${data}`;
    let buff = new Buffer(keySecretData);
    let basicAuth = buff.toString('base64');

    return basicAuth;
}

exports.mPesa = functions.firestore.document('payment_request/{requestID}').onCreate(async (snap, context) => {
    const request = snap.data();

    const consumerKey = "oXk44ItQDR2DvJDQcDCyTpGGigl3rkJ2";
    const consumerSecret = "aAYzGUsQWXNvuvEH";
    const businessShortCode = "174379";
    const passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
    const transactionType = "CustomerPayBillOnline";
    const callbackUrl = "https://us-central1-kindahclothing.cloudfunctions.net/callback";
    const transactionDesc = "Payment for template";

    let basicAuth = getBase64Encode(`${consumerKey}:${consumerSecret}`);

    try {
        // Call the first API to get the access token
        const accessTokenResponse = await unirest('GET', 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials')
        .headers({ 'Authorization': `Basic ${basicAuth}` })
        .send();
            
        // Store the access token in a variable
        const accessToken = accessTokenResponse.body.access_token;

        // Get timestamp
        var timestamp = moment().format("YYYYMMDDHHmmss");//YYYYMMDDHHmmss

        // Generate password
        var password = getBase64Encode(businessShortCode+passkey+timestamp);
            
        // Call the second API to make the STK push request
        const stkPushResponse = await unirest('POST', 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest')
            .headers({
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`,
            })
            .send(JSON.stringify({
                "BusinessShortCode": businessShortCode,
                "Password": password,
                "Timestamp": timestamp,
                "TransactionType": transactionType,
                "Amount": parseInt(request.amount),
                "PartyA": parseInt(request.phone),
                "PartyB": businessShortCode,
                "PhoneNumber": parseInt(request.phone),
                "CallBackURL": callbackUrl,
                "AccountReference": parseInt(request.phone),
                "TransactionDesc": transactionDesc,
            }));
            
        const requestRef = db.collection('payment_request').doc(request.id);

        await requestRef.update({
            feedback: stkPushResponse.body,
            status: 'success',
        });
    } catch (error) {
        console.log(error);

        const requestRef = db.collection('payment_request').doc(request.id);

        await requestRef.update({
            status: 'error',
            feedback: {
                error: error
            }
        });
    }
});

exports.callback = functions.https.onRequest(async function(req, res) {
    // Get the header and body through the req variable

    const docRef = db.collection('mpesa').doc(req.body.Body.stkCallback.CheckoutRequestID);

    await docRef.set(req.body);
});

function sendSMS(options) {
    sms.send(options)
      .then(response => {
        console.log(response);
      })
      .catch(error => {
        console.log(error);
      });
  }

exports.onProductOrderPlaced = functions.firestore.document('product_orders/{productOrderID}').onCreate(async (snap, context) => {
    const productOrder = snap.data();

    const phoneNumber = productOrder.paymentInfo.contact;
    const orderID = productOrder.id;

    // Notify user that order has been placed
    const options = {
        to: [`+${phoneNumber}`],
        message: `Dear Customer, your order #${orderID} has been successfully placed. Thank you for choosing Kindah Store. We will notify you once your order has been shipped. For any inquiries, please contact our customer support team. Thank you!`,
        //from: 'Kindah Store',
    }

    sendSMS(options);
});

exports.onProductOrderUpdated = functions.firestore.document('product_orders/{productOrderID}').onUpdate(async (snap, context) => {
    const productOrder = snap.after.data();

    // Check if the status field has changed
  if (productOrder.deliveryStatus !== snap.before.data().deliveryStatus) {

    if (productOrder && productOrder.paymentInfo && productOrder.paymentInfo.contact) {
    const recipient = productOrder.paymentInfo.contact; 

    // console.log("======================");

    // console.log(`+${recipient}`);

    // console.log([`+${recipient}`]);

    // console.log("======================");

    if (productOrder.deliveryStatus === 'shipping') {
        const message = `Dear Customer, your order #${productOrder.id} has been approved for shipping. Thank you for choosing us!`;
      // Send SMS notification to user
      const options = {
        to: [`+${recipient}`],
        message: message,
        //from: 'Kindah Store',
      };

      try {
        sendSMS(options);
        // const response = await sms.send(options);
        // console.log(`SMS notification sent to ${recipient}: `, response);
      } catch (error) {
        console.error(`Failed to send SMS notification to ${recipient}: `, error);
      }
    } else if(productOrder.deliveryStatus === 'delivered') {
        const message = `Dear Customer, your order #${productOrder.id} has been delivered successfully. Thank you for choosing Kindah Store. We hope you enjoy your purchase! If you have any questions, please don't hesitate to contact us. Thank you!`;
      // Send SMS notification to user
      const options = {
        to: [`+${recipient}`],
        message: message,
        //from: 'Kindah Store',
      };

      try {
        sendSMS(options);
        // const response = await sms.send(options);
        // console.log(`SMS notification sent to ${recipient}: `, response);
      } catch (error) {
        console.error(`Failed to send SMS notification to ${recipient}: `, error);
      }
    }}
  }

});

exports.onPOSProductPurchased = functions.firestore.document('POS_users/{userID}/product_orders/{productOrderID}').onCreate(async (snap, context) => {
    const productOrder = snap.data();

    const phoneNumber = productOrder.paymentInfo.contact;
    const orderID = productOrder.id;

    // Notify user that order has been placed
    const options = {
        to: [`+${phoneNumber}`],
        message: `Dear Customer, your order #${orderID} has been received by store #${productOrder.store}. Thank you for choosing Kindah Store. For any inquiries, please contact our customer support team. Thank you!`,
        //from: 'Kindah Store',
    }

    sendSMS(options);
});

exports.newUser = functions.firestore.document('users/{userID}').onCreate(async (snap, context) => {
    const newUser = snap.data();

    const phoneNumber = newUser.phone;
    const idNumber = newUser.idNumber;
    const username = newUser.username;

    const options = {
        to: [`+${phoneNumber}`],
        message: `Dear ${username}, your account has been created successfully. You can now log in to your account to access our services. If you have any questions, please don't hesitate to contact us. Thank you!`,
        //from: 'Kindah Store',
    }

    sendSMS(options);
});

exports.newUniformOrder = functions.firestore.document('orders/{orderID}').onCreate(async (snap, context) => {
    const newOrder = snap.data();
    
    const phoneNumber = newOrder.paymentInfo.contact;
    const clientName = newOrder.clientName;

    const options = {
        to: [`+${phoneNumber}`],
        message: `Dear ${clientName}, your order #${newOrder.id} has been successfully placed. Thank you for choosing Kindah Store. We will notify you once your uniforms have been processed. For any inquiries, please contact our customer support team. Thank you!`,
        //from: 'Kindah Store',
    }

    sendSMS(options);
});

exports.uniformOrderComplete = functions.firestore.document('orders/{orderID}').onUpdate(async (snap, context) => {
    const completedOrder = snap.after.data();

    if (completedOrder.processedStatus !== snap.before.data().processedStatus) {
        if(completedOrder.processedStatus === 'completed'){
            const phoneNumber = completedOrder.paymentInfo.contact;
            const clientName = completedOrder.clientName;

            const options = {
                to: [`+${phoneNumber}`],
                message: `Dear ${clientName}, your uniform order #${newOrder.id} has been successfully completed. Pick it up at your nearest store. Thank you for choosing Kindah Store.`,
                //from: 'Kindah Store',
            }

            sendSMS(options);
        }
    }
});

exports.paypal = functions.firestore.document('paypal_requests/{requestID}').onCreate(async (snap, context) => {
    const paypal_request = snap.data();

    paypal.payment.create(paypal_request, function (error, payment) {
        if (error) {
          console.error('Error creating PayPal payment:', error.response);
          throw error;
        } else {
          
          console.log('Create Payment Response:', payment.id);

          var payment_data = {
            "create_time": payment.create_time,
            "id": payment.id,
            "links": payment.links,
          };
      
          const docRef = db.collection('paypal_responses').doc(snap.id);
      
          docRef.set(payment_data)
            .then(() => {
              console.log('Payment response saved to Firestore:', payment.id);
            })
            .catch((error) => {
              console.error('Error saving payment response to Firestore:', error);
            });
        }
      });
      
});