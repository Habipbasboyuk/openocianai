import 'package:flutter/material.dart';

/// Custom styling classes voor de hele app
class AppColors {
  // Ocean kleuren
  static const oceanBlue = Color(0xFF006994);
  static const deepOcean = Color(0xFF003554);
  static const seafoam = Color(0xFF4ECDC4);
  static const sand = Color(0xFFFFF4E6);
  static const coral = Color(0xFFFF6B6B);
  static const wave = Color(0xFF80D0F0);

  // Grays
  static const darkGray = Color(0xFF333333);
  static const lightGray = Color(0xFFE0E0E0);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.deepOcean,
  );

  static const subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.oceanBlue,
  );

  static const body = TextStyle(fontSize: 16, color: AppColors.darkGray);

  static const caption = TextStyle(fontSize: 12, color: AppColors.lightGray);

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppDecorations {
  // Chat bubble voor user
  static BoxDecoration userBubble = BoxDecoration(
    color: AppColors.oceanBlue,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(4),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Chat bubble voor AI
  static BoxDecoration aiBubble = BoxDecoration(
    color: AppColors.seafoam,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(20),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Card decoration
  static BoxDecoration card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Input field decoration
  static BoxDecoration inputField = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.lightGray, width: 1.5),
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
