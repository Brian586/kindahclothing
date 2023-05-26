import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kindah/config.dart';

class PaymentSuccessful extends StatefulWidget {
  final String? text;
  const PaymentSuccessful({super.key, this.text});

  @override
  State<PaymentSuccessful> createState() => _PaymentSuccessfulState();
}

class _PaymentSuccessfulState extends State<PaymentSuccessful> {
  @override
  void initState() {
    super.initState();
    showSuccessful();
  }

  void showSuccessful() async {
    Timer(const Duration(seconds: 4), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.green.shade800,
                  child: const Icon(
                    Icons.done_rounded,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  widget.text!,
                  style: const TextStyle(
                      color: Config.customGrey, fontWeight: FontWeight.w700),
                )
              ],
            ),
          )),
    );
  }
}
