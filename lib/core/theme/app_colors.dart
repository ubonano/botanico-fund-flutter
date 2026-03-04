import 'package:flutter/material.dart';

class AppColors {
  // Brand — Logo Gradient Colors (Cyan → Violet → Magenta)
  static const Color primaryCyan = Color(0xFF4FC3F7);
  static const Color primaryViolet = Color(0xFF7B68EE);
  static const Color primaryMagenta = Color(0xFFDA70D6);

  /// Color sólido principal (punto medio del degradé del logo).
  static const Color primary = Color(0xFF7B68EE);

  /// Degradé principal del logo: cyan → violeta → magenta.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryViolet, primaryMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Lista de colores del degradé para reutilizar en contextos que no aceptan LinearGradient.
  static const List<Color> primaryGradientColors = [primaryCyan, primaryViolet, primaryMagenta];

  static const Color secondaryRose = Color(0xFFF43F5E); // Soft Red for negative

  // Backgrounds & Surface (Zinc Palette)
  static const Color backgroundDark = Color(0xFF09090B); // Zinc 950
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color borderDark = Color(0xFF27272A); // Zinc 800

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFF43F5E); // Rose 500

  // Investor Chart Colors (Harmonized with Brand Gradient)
  static const List<Color> chartColors = [
    Color(0xFF7B68EE), // Violet (primary)
    Color(0xFF4FC3F7), // Cyan
    Color(0xFFDA70D6), // Magenta
    Color(0xFF6B7280), // Cool Gray
    Color(0xFF4B5563), // Darker Gray
    Color(0xFF3B82F6), // Blue (Accent)
    Color(0xFF10B981), // Emerald (Accent)
    Color(0xFFF59E0B), // Amber (Accent)
  ];
}
