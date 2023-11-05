import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequest(String link,
      {Map<String, String>? headers}) async {
    var url = Uri.parse(link);

    http.Response response = await http.get(url, headers: headers);

    try {
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);

        return decodeData;
      } else {
        return "Failed";
      }
    } catch (exp) {
      print(exp.toString());

      return "Failed";
    }
  }

  static Future<dynamic> postRequest(String link,
      {Map<String, String>? headers, Object? body}) async {
    var url = Uri.parse(link);

    http.Response response = await http.post(url, headers: headers, body: body);

    try {
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);

        return decodeData;
      } else {
        return "Failed";
      }
    } catch (exp) {
      print(exp.toString());
      return "Failed";
    }
  }
}
