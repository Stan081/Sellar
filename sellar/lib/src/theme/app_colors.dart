import 'package:flutter/material.dart';

/// Application color palette - Sellar branding
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors - Indigo (trust, depth, premium)
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4338CA); // Indigo-700
  static const Color primaryLight = Color(0xFFA5B4FC); // Indigo-300

  // Secondary colors - Coral/Rose (energy, action, social)
  static const Color secondary = Color(0xFFF43F5E); // Rose-500
  static const Color secondaryDark = Color(0xFFBE123C); // Rose-700
  static const Color secondaryLight = Color(0xFFFDA4AF); // Rose-300

  // Accent colors - Violet (creativity, premium feel)
  static const Color accent = Color(0xFF8B5CF6); // Violet-500
  static const Color accentLight = Color(0xFFC4B5FD); // Violet-300

  // Background colors
  static const Color background = Color(0xFFF9FAFB); // Gray-50
  static const Color backgroundDark = Color(0xFF111827); // Gray-900
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1F2937); // Gray-800

  // Text colors
  static const Color textPrimary = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textHint = Color(0xFF9CA3AF); // Gray-400
  static const Color textOnPrimary = Colors.white;

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // Divider and border colors
  static const Color divider = Color(0xFFE5E7EB); // Gray-200
  static const Color border = Color(0xFFD1D5DB); // Gray-300

  // Card colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1F2937); // Gray-800
}
