import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color.fromRGBO(0, 204, 153, 1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color.fromRGBO(0, 204, 153, 1),
        brightness: Brightness.dark
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

}

extension ThemePlatform on ThemeData {
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  // bool get isIOS => false; // to test android
  bool get isWeb => kIsWeb;
}