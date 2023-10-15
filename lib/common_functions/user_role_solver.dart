import 'package:flutter/material.dart';
import 'package:kindah/config.dart';

String toHumanReadable(String role) {
  return role.split("_").join(" ").toTitleCase();
}

String toCoded(String role) {
  return role.toLowerCase().split(" ").join("_");
}

Color tagColor(String role) {
  switch (role) {
    case "shop_attendant":
      return Colors.teal;
    case "fabric_cutter":
      return Colors.deepOrange;
    case "tailor":
      return Colors.blue;
    case "finisher":
      return Colors.lime;
    default:
      return Colors.teal;
  }
}
