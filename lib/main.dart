import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'styles/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const HomeScreen(), // Remove title parameter as it's no longer needed
    );
  }
}