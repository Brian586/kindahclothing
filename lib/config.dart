import 'package:flutter/material.dart';

class Config {
  static const String appName = "Kindah Clothing";
  static const LinearGradient horizontalGradient = LinearGradient(colors: [
    Color.fromRGBO(255, 148, 130, 1),
    Color.fromRGBO(125, 119, 255, 1)
  ]);
  static const LinearGradient verticalGradient = LinearGradient(colors: [
    Color.fromRGBO(255, 148, 130, 1),
    Color.fromRGBO(125, 119, 255, 1)
  ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  static const LinearGradient diagonalGradient = LinearGradient(colors: [
    Color.fromRGBO(255, 148, 130, 1),
    Color.fromRGBO(125, 119, 255, 1)
  ], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Color customGrey = Color.fromRGBO(112, 112, 112, 1.0);
  static const Color customBlue = Color.fromRGBO(125, 119, 255, 1);
}

Map<int, Color> color = {
  50: const Color.fromRGBO(125, 119, 255, .1),
  100: const Color.fromRGBO(125, 119, 255, .2),
  200: const Color.fromRGBO(125, 119, 255, .3),
  300: const Color.fromRGBO(125, 119, 255, .4),
  400: const Color.fromRGBO(125, 119, 255, .5),
  500: const Color.fromRGBO(125, 119, 255, .6),
  600: const Color.fromRGBO(125, 119, 255, .7),
  700: const Color.fromRGBO(125, 119, 255, .8),
  800: const Color.fromRGBO(125, 119, 255, .9),
  900: const Color.fromRGBO(125, 119, 255, 1),
};

MaterialColor customPrimaryColor = MaterialColor(0xFF7D77FF, color);

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? "${this[0].toUpperCase()}${substring(1).toLowerCase()}" : "";
  String toTitleCase() => replaceAll(RegExp(" +"), " ")
      .split(" ")
      .map((str) => str.toCapitalized())
      .join(" ");
}
