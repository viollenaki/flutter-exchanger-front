import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/currencies/currencies_screen.dart'; // Import the currencies screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchanger',
      theme: AppTheme.darkTheme,
      routes: {
        '/': (context) => const LoginScreen(),
        '/main': (context) => const HomeScreen(),
        '/currencies': (context) => const CurrenciesScreen(), // Add the currencies route
      },
    );
  }
}