// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:go_router/go_router.dart';
// import 'package:kindah/pages/NFC/nfc_payment_screen.dart';
// import 'package:kindah/widgets/adaptive_ui.dart';
// import 'package:kindah/widgets/progress_widget.dart';
// import 'package:nfc_manager/nfc_manager.dart';

// import '../../config.dart';
// import '../../widgets/custom_button.dart';

// class NFCSender extends StatefulWidget {
//   const NFCSender({super.key});

//   @override
//   State<NFCSender> createState() => _NFCSenderState();
// }

// class _NFCSenderState extends State<NFCSender> {
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

//     print(isNFCAvailable);

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
//               NdefMessage message1 = await ndefTag.read();

//               if (message1.records.isNotEmpty) {
//                 // Get Amount, Page and Data
//                 String amount = utf8.decode(message1.records[0].payload);
//                 String page = utf8.decode(message1.records[1].payload);
//                 String data = utf8.decode(message1.records[2].payload);

//                 print(amount);
//                 print(page);
//                 print(data);

//                 // Open PaymentPage
//                 String result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => NFCPaymentScreen(
//                             totalAmount: int.parse(amount).toDouble(),
//                             page: page,
//                             data: data)));

//                 print(result);
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
//         onBackPressed: () => context.go("/home"),
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
