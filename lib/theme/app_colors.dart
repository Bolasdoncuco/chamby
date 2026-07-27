import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryBlue = Color(0xFFDBEAFE);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate500 = Color(0xFF64748B);
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
