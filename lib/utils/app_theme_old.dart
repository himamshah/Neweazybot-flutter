import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0E0F12);
  static const Color bg2 = Color(0xFF15171C);
  static const Color bg3 = Color(0xFF1C1F27);
  static const Color bg4 = Color(0xFF232730);
  static const Color border = Color(0x12FFFFFF); // rgba(255,255,255,0.07)
  static const Color border2 = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)
  static const Color text = Color(0xFFF0F1F4);
  static const Color text2 = Color(0xFF8B90A0);
  static const Color text3 = Color(0xFF555B6E);
  static const Color green = Color(0xFF00D492);
  static const Color greenDim = Color(0x1F00D492); // rgba(0,212,146,0.12)
  static const Color red = Color(0xFFFF4D6A);
  static const Color redDim = Color(0x1FFF4D6A); // rgba(255,77,106,0.12)
  static const Color blue = Color(0xFF4D9EFF);
  static const Color blueDim = Color(0x1F4D9EFF); // rgba(77,158,255,0.12)
  static const Color amber = Color(0xFFFFB547);
  static const Color amberDim = Color(0x1FFFB547); // rgba(255,181,71,0.12)
  static const Color teal = Color(0xFF00C9C9);
  static const Color tealDim = Color(0x1F00C9C9); // rgba(0,201,201,0.12)

  static const double radius = 16.0;
  static const double radiusSm = 8.0;
  static const double radiusXs = 5.0;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg2,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: bg2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text2,
          backgroundColor: bg4,
          side: const BorderSide(color: border2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: text, fontSize: 13),
        bodySmall: TextStyle(color: text2, fontSize: 11),
        labelLarge: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: text2, fontSize: 12),
        labelSmall: TextStyle(color: text3, fontSize: 10),
      ),
      fontFamily: 'DM Sans',
    );
  }

  static TextStyle get monoStyle => const TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
  );

  static Color getPnLColor(double value) {
    if (value > 0) return green;
    if (value < 0) return red;
    return text;
  }

  static String formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  static String formatPrice(double value) {
    if (value >= 1000) {
      return '\$${value.toStringAsFixed(0)}';
    } else if (value >= 1) {
      return '\$${value.toStringAsFixed(4)}';
    } else {
      return '\$${value.toStringAsFixed(6)}';
    }
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }
}
