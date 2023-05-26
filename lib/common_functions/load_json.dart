import 'dart:convert';

import 'package:flutter/material.dart';

class LoadJsonData {
  static getJsonData({BuildContext? context, String? library}) async {
    try {
      // String data = await rootBundle.loadString(library!);
      // List<Map> maps = List<Map>.from(jsonDecode(data) as List);
      String data = await DefaultAssetBundle.of(context!).loadString(library!);

      final jsonResult = await jsonDecode(data);

      return jsonResult;
    } catch (e) {
      print(e.toString());

      return [];
    }
  }
}
