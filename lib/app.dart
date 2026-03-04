import 'package:flutter/material.dart';
import 'package:botanico_fund_flutter/core/shared/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Botanico Fund',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B), // Fondo casi negro muy elegante (Zinc 950)
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B68EE), // Botanico Logo Violet
          secondary: Color(0xFFF43F5E), // Rose 500 - Soft Red
          surface: Color(0xFF18181B), // Zinc 900
          background: Color(0xFF09090B), // Zinc 950
        ),
        fontFamily: 'Roboto', // Or inter/outfit if imported in pubspec
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
        // default card theme
      ),
      home: const AuthGate(),
    );
  }
}
