import 'package:flutter/material.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/custom_color.dart';

Future<List<CustomColor>> getColors(BuildContext context, String filter) async {
  // Create a list of custom colors model
  List<CustomColor> _colors = [];

  if (filter.isNotEmpty) {
    // filter the list of maps based on the value of the given value
    var filteredResults = colorsMap
        .where((map) => map['value'] == filter.toCapitalized())
        .toList();

    for (var filteredResult in filteredResults) {
      CustomColor customColor = CustomColor.fromJson(filteredResult);

      /// Add to [_colors]
      _colors.add(customColor);
    }
  } else {
    for (var res in colorsMap) {
      CustomColor customColor = CustomColor.fromJson(res);

      /// Add to [_colors]
      _colors.add(customColor);
    }
  }

  return _colors;
}

// import 'load_json.dart';

// Future<Map<String, String>> getColorsMap(BuildContext context) async {
//   try {
//     // Get colors from json file
//     Map<String, String> result = await LoadJsonData.getJsonData(
//         context: context, library: "assets/json/color_names.json");

//     return result;
//   } catch (e) {
//     print("Error loading JSON data: $e");
//     return {};
//   }
// }

Color hexToColor(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  int colorValue = int.parse(hexColor, radix: 16);
  return Color(colorValue)
      .withOpacity(1.0); // You can adjust the opacity if needed
}

String findColorName(String targetHex) {
  for (var color in colorsMap) {
    if (color["hex"] == targetHex) {
      return color["name"];
    }
  }
  return ""; // Return null if the color is not found
}

// String? getKeyByValue(Map<String, String> map, String value) {
//   for (var entry in map.entries) {
//     if (entry.value == value) {
//       return entry.key;
//     }
//   }
//   return null; // Value not found in the map
// }
