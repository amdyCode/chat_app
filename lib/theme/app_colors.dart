import 'package:flutter/material.dart';

class AppColors {
  // Brand colors from Stitch design
  static const Color primary = Color(0xFF3525CD);
  static const Color primaryContainer = Color(0xFF4F46E5);
  static const Color primaryFixed = Color(0xFFE2DFFF);
  static const Color primaryFixedDim = Color(0xFFC3C0FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFDAD7FF);

  // Background and surface colors
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Text & Content colors
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color outline = Color(0xFF777587);
  static const Color outlineVariant = Color(0xFFC7C4D8);

  // Status & Accents
  static const Color secondary = Color(0xFF006C49);
  static const Color secondaryContainer = Color(0xFF6CF8BB);
  static const Color onSecondaryContainer = Color(0xFF00714D);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Avatar palette for initials
  static const List<Color> avatarColors = [
    Color(0xFF3525CD), // Indigo
    Color(0xFF006C49), // Emerald
    Color(0xFF885500), // Amber / Ochre
    Color(0xFF007A99), // Ocean Teal
    Color(0xFF9333EA), // Purple
    Color(0xFFBE185D), // Magenta Pink
    Color(0xFFD97706), // Warm Orange
    Color(0xFF2563EB), // Royal Blue
  ];

  static Color getAvatarColor(String name) {
    if (name.isEmpty) return avatarColors.first;
    final int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return avatarColors[hash % avatarColors.length];
  }
}
