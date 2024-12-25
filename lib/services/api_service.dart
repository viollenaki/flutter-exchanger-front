import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

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

  static Future<void> deleteCurrency(String currencyName) async {
    final response = await http.delete(Uri.parse('$_baseUrl/currencies/$currencyName'), 
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'name': currencyName})
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete currency');
    }
  }

  static Future<void> editCurrency(String currencyName, String currencyOldName) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/currencies/$currencyName'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'newName': currencyName, 'oldName': currencyOldName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update currency');
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

  static Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/events'));
      if (response.statusCode == 200) {
        // Декодируем ответ в UTF-8
        final decodedResponse = utf8.decode(response.bodyBytes);
        return json.decode(decodedResponse);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<User?> authenticate(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User(username: username);
    } else {
      return null;
    }
  }

  static Future<void> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password');
    }
  }

  static Future<void> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/events/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete event');
    }
  }
}