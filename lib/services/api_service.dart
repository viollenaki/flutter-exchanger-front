import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://tochka28.pythonanywhere.com/api/v1';
  static const String _ratesUrl = 'https://data.fx.kg/api/v1/central';
  // static const String _baseUrl = 'http://localhost:8000/api/v1';
  static const String _bearerKey = 'dv2FvCMPNs3S1Snd9Tn9dznvyHVGwrNFxHy9yuNy20d3d94a';

  static final Map<String, bool> _superUserCache = {};

  static Future<Map<String, String>> _getHeaders() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  static Future<http.Response> _makeRequestWithTokenRefresh(
      Future<http.Response> Function(Map<String, String>) request) async {
    var headers = await _getHeaders();
    var response = await request(headers);

    if (response.statusCode == 401) {
      await refreshJWT();
      headers = await _getHeaders();
      response = await request(headers);
    }

    return response;
  }

  static Future<List<String>> fetchCurrencies() async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.get(Uri.parse('$_baseUrl/currencies'), headers: headers),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedResponse);
      return data.map((currency) => currency['name'].toString()).toList();
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  static Future<void> addCurrency(String currencyName) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.post(
        Uri.parse('$_baseUrl/currencies'),
        headers: headers,
        body: json.encode({'name': currencyName}),
      ),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add currency');
    }
  }

  static Future<void> deleteCurrency(String currencyName) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.delete(
        Uri.parse('$_baseUrl/currencies/$currencyName'),
        headers: headers,
        body: json.encode({'name': currencyName}),
      ),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete currency');
    }
  }

  static Future<void> editCurrency(String currencyName, String currencyOldName) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.put(
        Uri.parse('$_baseUrl/currencies/$currencyName'),
        headers: headers,
        body: json.encode({'newName': currencyName, 'oldName': currencyOldName}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update currency');
    }
  }

  static Future<void> addEvent(String type, String currency, double amount, double rate, double total) async {
    final now = DateTime.now();
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.post(
        Uri.parse('$_baseUrl/events'),
        headers: headers,
        body: json.encode({
          'type': type,
          'currency': currency,
          'amount': amount,
          'date': DateFormat('HH:mm').format(now),
          'rate': rate,
          'total': total,
        }),
      ),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add event ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await _makeRequestWithTokenRefresh(
        (headers) => http.get(Uri.parse('$_baseUrl/events'), headers: headers),
      );
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
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.delete(Uri.parse('$_baseUrl/events/$id'), headers: headers),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete event');
    }
  }

  static Future<List<String>> fetchUsers() async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.get(Uri.parse('$_baseUrl/users'), headers: headers),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedResponse);
      return data.map((user) => user['username'].toString()).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> addUser(String username, String password, bool isSuperAdmin, String email) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.post(
        Uri.parse('$_baseUrl/users'),
        headers: headers,
        body: json.encode({'username': username, 'password': password, 'isSuperUser': isSuperAdmin, 'email': email}),
      ),
    );

    if (response.statusCode == 400) {
      throw "Имя пользователь или почта уже заняты";
    }
  }

  static Future<void> deleteUser(String username) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.delete(
        Uri.parse('$_baseUrl/users'),
        headers: headers,
        body: json.encode({'username': username}),
      ),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  static Future<void> editUser(String username, String oldUsername, String password, bool isSuperAdmin, String email) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.put(
        Uri.parse('$_baseUrl/users'),
        headers: headers,
        body: json.encode({'username': username, 'oldUsername': oldUsername, 'password': password, 'isSuperUser': isSuperAdmin, 'email': email}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  static Future<Map<String, dynamic>> getUserDetails(String username) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.get(Uri.parse('$_baseUrl/users/$username'), headers: headers),
    );

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
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.post(
        Uri.parse('$_baseUrl/clear-all'),
        headers: headers,
        body: json.encode({'username': username, 'password': password}),
      ),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> editEvent(int id, String type, String currency, double amount, double rate, double total) async {
    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.put(
        Uri.parse('$_baseUrl/events/$id'),
        headers: headers,
        body: json.encode({
          'type': type,
          'currency': currency,
          'amount': amount,
          'rate': rate,
          'total': total,
        }),
      ),
    );

    if (response.statusCode != 200) {
      return false;      
    }else{
      return true;
    }
  }

  static Future<bool> isSuperUser(String username) async {
    if (_superUserCache.containsKey(username)) {
      return _superUserCache[username]!;
    }

    final response = await _makeRequestWithTokenRefresh(
      (headers) => http.get(
        Uri.parse('$_baseUrl/super-user-check/$username'),
        headers: headers,
      ),
    );

    final result = response.statusCode == 204;
    _superUserCache[username] = result;
    return result;
  }

  static void clearSuperUserCache() {
    _superUserCache.clear();
  }

  static Future<Map<String, dynamic>> getCurrencyRate() async {
    final response = await http.get(Uri.parse(_ratesUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_bearerKey'}
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {};
    }
  }

  static Future<void> getAccessJWT(String username, String password) async {
    final response = await http.post(Uri.parse('$_baseUrl/token'), 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password})
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedResponse);    
      final storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: data['access']);
      await storage.write(key: 'refreshToken', value: data['refresh']);
    } else {
      throw Exception('Failed to load tokens');
    }
  }

  static Future<void> refreshJWT() async {
    final storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    final response = await http.post(
      Uri.parse('$_baseUrl/token/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );
    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedResponse);
      await storage.write(key: 'accessToken', value: data['access']);
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
