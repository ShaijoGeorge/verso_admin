import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale for Verso Admin.
///
/// Primary font family: **Metropolis** (`Regular`, `RegularItalic`, `Bold`, `ExtraBold`).
/// Also provides Google Fonts fallbacks for editorial display.
abstract final class AppTypography {
  /// Metropolis font family name as registered in pubspec.yaml.
  static const String fontFamily = 'Metropolis';

  // ── Display (Metropolis) ──

  static TextStyle get displayLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.15,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
      );

  // ── Headline (Metropolis) ──

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.22,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get headlineSmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.38,
      );

  // ── Title (Metropolis) ──

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.28,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.4,
      );

  // ── Body (Metropolis) ──

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.55,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.45,
      );

  // ── Label (Metropolis) ──

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        height: 1.35,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
        height: 1.35,
      );

  // ── Editorial Fallbacks (DM Serif Display) ──

  static TextStyle get editorialLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get editorialMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
        height: 1.25,
      );

  /// Builds the complete [TextTheme] for use in [ThemeData].
  static TextTheme textTheme({
    required Color bodyColor,
    required Color displayColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: displayColor),
      displayMedium: displayMedium.copyWith(color: displayColor),
      displaySmall: displaySmall.copyWith(color: displayColor),
      headlineLarge: headlineLarge.copyWith(color: bodyColor),
      headlineMedium: headlineMedium.copyWith(color: bodyColor),
      headlineSmall: headlineSmall.copyWith(color: bodyColor),
      titleLarge: titleLarge.copyWith(color: bodyColor),
      titleMedium: titleMedium.copyWith(color: bodyColor),
      titleSmall: titleSmall.copyWith(color: bodyColor),
      bodyLarge: bodyLarge.copyWith(color: bodyColor),
      bodyMedium: bodyMedium.copyWith(color: bodyColor),
      bodySmall: bodySmall.copyWith(color: bodyColor),
      labelLarge: labelLarge.copyWith(color: bodyColor),
      labelMedium: labelMedium.copyWith(color: bodyColor),
      labelSmall: labelSmall.copyWith(color: bodyColor),
    );
  }
}
