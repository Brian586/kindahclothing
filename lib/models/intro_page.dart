import 'package:flutter/material.dart';

class IntroPage {
  final Widget? image;
  final String? title;
  final Widget? body;
  final String? userType;

  IntroPage({this.image, this.title, this.body, this.userType});
}

List<IntroPage> introScreens = [
  IntroPage(
    image: Image.asset("assets/images/template_shimmer.png",
        width: 250.0, fit: BoxFit.contain),
    title: "1. Create a template",
    body: const Text(
      "Generate a new template detailing the uniforms and student information for your client.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60),
    ),
    userType: "shop_attendant",
  ),
  IntroPage(
    image: const Icon(
      Icons.currency_exchange,
      size: 60.0,
      color: Colors.white38,
    ),
    title: "2. Make payment",
    body: const Text(
      "Let your client make a payment for the uniforms ordered.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60),
    ),
    userType: "shop_attendant",
  ),
  IntroPage(
    image: const Icon(
      Icons.thumb_up_alt_outlined,
      size: 60.0,
      color: Colors.white38,
    ),
    title: "3. All Done!",
    body: const Text(
      "Thats all! Let's get started!",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60),
    ),
    userType: "shop_attendant",
  ),
  IntroPage(
    image: Image.asset("assets/images/template_shimmer.png",
        width: 250.0, fit: BoxFit.contain),
    title: "1. Select available template",
    body: const SizedBox(
      height: 0.0,
      width: 0.0,
    ),
    userType: "fabric_cutter",
  ),
  IntroPage(
    image: Image.asset("assets/images/fabric_cutter.png",
        width: 200.0, fit: BoxFit.contain),
    title: "2. Pick order for Processing",
    body: Image.asset("assets/images/process_shimmer.png",
        width: 150.0, fit: BoxFit.contain),
    userType: "fabric_cutter",
  ),
  IntroPage(
    image: Image.asset("assets/images/tailor.png",
        width: 200.0, fit: BoxFit.contain),
    title: "3. Assign order to a tailor",
    body: Image.asset("assets/images/assign_shimmer.png",
        width: 150.0, fit: BoxFit.contain),
    userType: "fabric_cutter",
  ),
  IntroPage(
    image: Image.asset("assets/images/template_shimmer.png",
        width: 250.0, fit: BoxFit.contain),
    title: "1. Choose a template",
    body: const Text(
      "Pick a template to work on.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60),
    ),
    userType: "tailor",
  ),
  IntroPage(
    image: Image.asset("assets/images/tailor.png",
        width: 200.0, fit: BoxFit.contain),
    title: "2. Work on orders",
    body: const Text(
      "Make uniforms based on client orders.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60),
    ),
    userType: "tailor",
  ),
  IntroPage(
    image: const Icon(
      Icons.thumb_up_alt_outlined,
      size: 60.0,
      color: Colors.white38,
    ),
    title: "3. All Done!",
    body: const Text(
      "Thats all! Let's get started!",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white60),
    ),
    userType: "tailor",
  ),
  IntroPage(
    image: Image.asset("assets/images/template_shimmer.png",
        width: 250.0, fit: BoxFit.contain),
    title: "1. Select available template",
    body: const SizedBox(
      height: 0.0,
      width: 0.0,
    ),
    userType: "finisher",
  ),
  IntroPage(
    image: Image.asset("assets/images/fabric_cutter.png",
        width: 200.0, fit: BoxFit.contain),
    title: "2. Pick order for Processing",
    body: Image.asset("assets/images/process_shimmer.png",
        width: 150.0, fit: BoxFit.contain),
    userType: "finisher",
  ),
];
