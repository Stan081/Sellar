import 'package:flutter/material.dart';

/// Consistent spacing tokens following Material 3 guidelines (4dp grid)
class AppSpacing {
  AppSpacing._();

  // Base spacing scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double jumbo = 48.0;

  // Screen padding
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets screenHorizontal =
      EdgeInsets.symmetric(horizontal: lg);

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  // List item padding
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Section gap (between major UI sections)
  static const double sectionGap = xxl;

  // Border radius tokens
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;
}
