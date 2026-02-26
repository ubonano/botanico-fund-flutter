import 'package:flutter/material.dart';
import 'package:botanico_fund_flutter/features/dashboard/screens/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Botanico Fund',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981), // Emerald 500 - Neon Green
          secondary: Color(0xFFF43F5E), // Rose 500 - Soft Red
          surface: Color(0xFF1E293B), // Slate 800
          background: Color(0xFF0F172A), // Slate 900
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
      home: const DashboardScreen(),
    );
  }
}
