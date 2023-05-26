// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:kindah/widgets/adaptive_ui.dart';
// import 'package:kindah/widgets/progress_widget.dart';
// import 'package:nfc_manager/nfc_manager.dart';

// import '../../config.dart';
// import '../../widgets/custom_button.dart';

// class NFCReceiver extends StatefulWidget {
//   final double totalAmount;
//   final String page;
//   final String data;
//   const NFCReceiver(
//       {super.key,
//       required this.totalAmount,
//       required this.page,
//       required this.data});

//   @override
//   State<NFCReceiver> createState() => _NFCReceiverState();
// }

// class _NFCReceiverState extends State<NFCReceiver> {
//   bool isNFCAvailable = false;
//   bool loading = false;
//   bool listenerRunning = false;

//   @override
//   void initState() {
//     super.initState();
//     checkNFCAvailability();
//   }

//   void checkNFCAvailability() async {
//     setState(() {
//       loading = true;
//     });

//     isNFCAvailable = await NfcManager.instance.isAvailable();

//     setState(() {
//       loading = false;
//     });
//   }

//   void _initiateNFC() async {
//     if (!listenerRunning) {
//       setState(() {
//         listenerRunning = true;
//       });

//       try {
//         // Start Session
//         NfcManager.instance.startSession(
//           onDiscovered: (NfcTag tag) async {
//             // Do something with an NfcTag instance.
//             //Try to convert the raw tag data to NDEF
//             final ndefTag = Ndef.from(tag);
//             //If the data could be converted we will get an object
//             if (ndefTag != null) {
//               NdefRecord amount =
//                   NdefRecord.createText(widget.totalAmount.toString());
//               NdefRecord page = NdefRecord.createText(widget.page);
//               NdefRecord data = NdefRecord.createText(widget.data);

//               NdefMessage message1 = NdefMessage([amount, page, data]);

//               try {
//                 ndefTag.write(message1);

//                 NdefMessage message = await ndefTag.read();

//                 if (message.records.isNotEmpty) {
//                   // This record is paymentInfo
//                   String paymentInfo =
//                       utf8.decode(message.records.first.payload);

//                   print(paymentInfo);
//                 }
//               } catch (e) {
//                 print(e.toString());
//               }
//             }
//           },
//         );

//         NfcManager.instance.stopSession();
//       } catch (e) {
//         print(e.toString());
//         Fluttertoast.showToast(msg: "An ERROR Occurred");
//       }
//     }
//   }

//   Widget unsupportedDevice() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: const [
//         Text(
//           "Your Device does not support Near Field Communication",
//           textAlign: TextAlign.center,
//           style:
//               TextStyle(color: Config.customGrey, fontWeight: FontWeight.w600),
//         )
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return EcommAdaptiveUI(
//         appbarTitle: "NFC Payments",
//         onBackPressed: () => Navigator.pop(context, "failed"),
//         body: loading
//             ? circularProgress()
//             : isNFCAvailable
//                 ? Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0),
//                         child: Text(
//                           "Make Payment with Near Field Communication (NFC)",
//                           textAlign: TextAlign.start,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium!
//                               .apply(color: Config.customGrey),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20.0,
//                       ),
//                       CustomButton(
//                         onPressed: () => _initiateNFC(),
//                         title: "Start NFC Session",
//                         iconData: Icons.nfc_outlined,
//                       )
//                     ],
//                   )
//                 : unsupportedDevice());
//   }
// }
