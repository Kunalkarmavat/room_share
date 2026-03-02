import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0; // Buttons
  static const double lg = 16.0; // Cards
  static const double xl = 24.0;
}

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// COLORS
// =============================================================================

class RoomShareColors {
  // Primary Brand (Calm Teal)
  static const primary = Color(0xFF0F766E);
  static const primaryLight = Color(0xFF14B8A6);

  // Backgrounds
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);

  // Text
  static const text = Color(0xFF0F172A);
  static const textLight = Color(0xFF64748B);

  // UI
  static const divider = Color(0xFFE2E8F0);
  static const secondary = Color(0xFF14B8A6);

  // States
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF0F172A);
  static const error = Color(0xFFDC2626);

  static var onSurfaceVariant;
}


class AppColors {
  AppColors._();

  static const primary     = Color(0xFF0F766E);
  static const primaryLight = Color(0xFFFAEDE9);
  static const background  = Color(0xFFF8F5F2);
  static const white       = Color(0xFFFFFFFF);
  static const textDark    = Color(0xFF1A1A1A);
  static const textGrey    = Color(0xFF888888);
  static const border      = Color(0xFFE8E8E8);
  static const success     = Color(0xFF4CAF50);
  static const amber       = Color(0xFFFFC107);
}

// =============================================================================
// THEMES
// =============================================================================

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: RoomShareColors.primary,
    onPrimary: RoomShareColors.onPrimary,
    secondary: RoomShareColors.secondary,
    onSecondary: Colors.white,
    surface: RoomShareColors.background, // Background color for scaffold
    onSurface: RoomShareColors.text,
    error: RoomShareColors.error,
    outline: RoomShareColors.divider,
    background: RoomShareColors.background,
  ),
  scaffoldBackgroundColor: RoomShareColors.background,
  dividerTheme: const DividerThemeData(
    color: RoomShareColors.divider,
    thickness: 1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: RoomShareColors.background,
    foregroundColor: RoomShareColors.text,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    color: RoomShareColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg), // 16px
    ),
    margin: EdgeInsets.zero,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RoomShareColors.primary,
      foregroundColor: RoomShareColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md), // 12px
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: RoomShareColors.text,
      side: const BorderSide(color: RoomShareColors.text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: RoomShareColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: RoomShareColors.primary, width: 2),
    ),
    hintStyle: GoogleFonts.inter(color: RoomShareColors.textLight),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: RoomShareColors.primary,
    foregroundColor: RoomShareColors.onPrimary,
    elevation: 4,
    shape: CircleBorder(), // Or rounded rect? FABs are usually circular or rounded rect. Material 3 is rounded rect.
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge: TextStyle(color: RoomShareColors.text, fontSize: 16),
      bodyMedium: TextStyle(color: RoomShareColors.text, fontSize: 14),
      bodySmall: TextStyle(color: RoomShareColors.textLight, fontSize: 12),
      labelLarge: TextStyle(color: RoomShareColors.text, fontWeight: FontWeight.w600),
    ),
  ),
);

// We'll keep darkTheme simple or just reuse light for now since the prompt specified precise colors 
// which look like a light theme.
ThemeData get darkTheme => lightTheme; 
