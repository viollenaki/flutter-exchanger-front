import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:5050/api/v1';

  static Future<List<String>> fetchCurrencies() async {
    final response = await http.get(Uri.parse('$_baseUrl/currencies'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((currency) => currency['name'].toString()).toList();
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  static Future<void> addCurrency(String currencyName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/currencies'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': currencyName}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add currency');
    }
  }

  static Future<void> addEvent(String type, String currency, double amount, String date, double rate, double total) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'type': type,
        'currency': currency,
        'amount': amount,
        'date': date,
        'rate': rate,
        'total': total,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add event ${response.body}');
    }
  }
}