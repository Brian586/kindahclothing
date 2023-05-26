import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PointOfSale extends StatefulWidget {
  const PointOfSale({super.key});

  @override
  State<PointOfSale> createState() => _PointOfSaleState();
}

class _PointOfSaleState extends State<PointOfSale> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    checkIfLoggedIn();
  }

  void checkIfLoggedIn() async {
    Timer(const Duration(seconds: 3), () {
      if (_auth.currentUser == null) {
        // Proceed to login screen
        GoRouter.of(context).go("/POS/login");
      } else {
        // Proceed to Home
        String userID = _auth.currentUser!.uid;

        GoRouter.of(context).go("/POS/$userID/home");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              // scale: 0.8,
              height: 100.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              width: 250,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LinearProgressIndicator(),
              ),
            ),
            const Text(
              'Loading POS...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
