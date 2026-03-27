import 'package:flutter/material.dart';

/// Application color palette — Sellar branding
///
/// M3 + Custom: Indigo primary, Rose secondary, with gradient accents
/// and tonal surface variants for visual personality.
class AppColors {
  AppColors._();

  // ─── Primary — Indigo (trust, depth, premium) ───────────────────────
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4338CA); // Indigo-700
  static const Color primaryLight = Color(0xFFA5B4FC); // Indigo-300
  static const Color primarySurface = Color(0xFFEEF2FF); // Indigo-50

  // ─── Secondary — Rose (energy, action, social) ──────────────────────
  static const Color secondary = Color(0xFFF43F5E); // Rose-500
  static const Color secondaryDark = Color(0xFFBE123C); // Rose-700
  static const Color secondaryLight = Color(0xFFFDA4AF); // Rose-300
  static const Color secondarySurface = Color(0xFFFFF1F2); // Rose-50

  // ─── Accent — Violet (creativity, premium feel) ─────────────────────
  static const Color accent = Color(0xFF8B5CF6); // Violet-500
  static const Color accentLight = Color(0xFFC4B5FD); // Violet-300
  static const Color accentSurface = Color(0xFFF5F3FF); // Violet-50

  // ─── Backgrounds ────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate-900
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceElevatedDark = Color(0xFF283548);

  // ─── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textHint = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Colors.white;

  // ─── Status ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successSurface = Color(0xFFECFDF5); // Emerald-50
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningSurface = Color(0xFFFFFBEB); // Amber-50
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorSurface = Color(0xFFFEF2F2); // Red-50
  static const Color info = Color(0xFF3B82F6); // Blue-500
  static const Color infoSurface = Color(0xFFEFF6FF); // Blue-50

  // ─── Borders & Dividers ─────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E8F0); // Slate-200
  static const Color border = Color(0xFFCBD5E1); // Slate-300

  // ─── Cards ──────────────────────────────────────────────────────────
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B); // Slate-800

  // ─── Gradients (custom touches) ─────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
