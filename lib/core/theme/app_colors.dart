import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primaryGold = Color(0xFFD4AF37); // Metallic Gold
  static const Color secondaryRose = Color(0xFFF43F5E); // Soft Red for negative

  // Backgrounds & Surface (Zinc Palette)
  static const Color backgroundDark = Color(0xFF09090B); // Zinc 950
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color borderDark = Color(0xFF27272A); // Zinc 800

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFF43F5E); // Rose 500

  // Investor Chart Colors (Harmonized with Dark Gold theme)
  static const List<Color> chartColors = [
    Color(0xFFD4AF37), // Gold
    Color(0xFFB49A45), // Subdued Gold
    Color(0xFF8B7735), // Dark Gold
    Color(0xFF6B7280), // Cool Gray
    Color(0xFF4B5563), // Darker Gray
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald (Accent)
    Color(0xFF3B82F6), // Blue (Accent)
  ];
}
