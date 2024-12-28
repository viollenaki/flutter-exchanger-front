import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user.dart';

class ApiService {
  // static const String _baseUrl = 'https://tochka28.pythonanywhere.com/api/v1';
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  static Future<List<String>> fetchCurrencies() async {
    final response = await http.get(Uri.parse('$_baseUrl/currencies'));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedResponse);
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

  static Future<void> addEvent(String type, String currency, double amount, double rate, double total) async {
    final now = DateTime.now();
    print(DateFormat('HH:mm').format(now));
    final response = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'type': type,
        'currency': currency,
        'amount': amount,
        'date': DateFormat('HH:mm').format(now),
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


  static Future<List<String>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedResponse);
      return data.map((user) => user['name'].toString()).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> addUser(String username, String password, bool isSuperAdmin, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password, 'isSuperUser': isSuperAdmin, 'email': email}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }

  static Future<void> deleteUser(String username) async {
    final response = await http.delete(Uri.parse('$_baseUrl/users'), 
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'username': username})
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  static Future<void> editUser(String username, String oldUsername, String password, bool isSuperAdmin, String email) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'oldUsername': oldUsername, 'password': password, 'isSuperUser': isSuperAdmin, 'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  static Future<Map<String, dynamic>> getUserDetails(String username) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$username'));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedResponse);
      // log data to console
      return data;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  static Future<bool> clearAll(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/clear-all'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> editEvent(int id, String type, String currency, double amount, double rate, double total) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/events/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'type': type,
        'currency': currency,
        'amount': amount,
        'rate': rate,
        'total': total,
      }),
    );

    if (response.statusCode != 200) {
      return false;      
    }else{
      return true;
    }
  }
}
