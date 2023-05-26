import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CurrencyConverter {
  final String apiKey = "WduBk6sStnChEimbZTmVq8swIa4A5Qku";

  Future<double> convertCurrency(
      {double? amount, String? fromCurrency, String? toCurrency}) async {
    if (kIsWeb) {
      // final String apiUrl =
      //     'https://api.apilayer.com/exchangerates_data/latest?symbols=$fromCurrency&base=$toCurrency';

      // final response = await html.HttpRequest.request(apiUrl,
      //     requestHeaders: {"apikey": apiKey});
      // if (response.status == 200) {
      //   final jsonResponse = json.decode(response.response);
      //   if (jsonResponse['success']) {
      //     final exchangeRate = jsonResponse['rates'][toCurrency];
      //     return exchangeRate ?? 0.0076;
      //   } else {
      //     return 0.0076;
      //   }
      // } else {
      //   throw Exception('Failed to load exchange rate');
      // }

      return 0.0076;
    } else {
      final String apiUrl =
          'https://api.apilayer.com/exchangerates_data/latest?symbols=$fromCurrency&base=$toCurrency';

      final response =
          await http.get(Uri.parse(apiUrl), headers: {"apikey": apiKey});
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final exchangeRate = jsonResponse['rates'][toCurrency];
          return exchangeRate ?? 0.0076;
        } else {
          return 0.0076;
        }
      } else {
        throw Exception('Failed to load exchange rate');
      }
    }
  }
}
