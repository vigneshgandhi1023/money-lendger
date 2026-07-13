import 'package:flutter/material.dart';

/// Custom color schemes for Loan Ledger.
///
/// Uses a premium fintech color palette:
/// - Deep Indigo primary for trust
/// - Teal secondary for freshness
/// - Emerald tertiary for money/success
/// - Semantic colors for money-in, money-out, warnings
class AppColors {
  AppColors._();

  // ─── Primary Palette ───────────────────────────────────
  static const Color primaryLight = Color(0xFF3F37C9);
  static const Color primaryDark = Color(0xFF8B83FF);

  static const Color secondaryLight = Color(0xFF0EA5E9);
  static const Color secondaryDark = Color(0xFF38BDF8);

  static const Color tertiaryLight = Color(0xFF10B981);
  static const Color tertiaryDark = Color(0xFF34D399);

  // ─── Surfaces ──────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF0F172A);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);

  static const Color cardVariantLight = Color(0xFFF1F5F9);
  static const Color cardVariantDark = Color(0xFF334155);

  // ─── Semantic Colors ───────────────────────────────────
  static const Color moneyIn = Color(0xFF10B981);
  static const Color moneyOut = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);

  static const Color moneyInLight = Color(0xFFD1FAE5);
  static const Color moneyOutLight = Color(0xFFFEE2E2);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  static const Color moneyInDark = Color(0xFF064E3B);
  static const Color moneyOutDark = Color(0xFF7F1D1D);
  static const Color warningDark = Color(0xFF78350F);
  static const Color infoDark = Color(0xFF0C4A6E);

  // ─── Text Colors ───────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // ─── Borders ───────────────────────────────────────────
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // ─── Color Schemes ─────────────────────────────────────

  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE8E6FF),
    onPrimaryContainer: const Color(0xFF1A1164),
    secondary: secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE0F2FE),
    onSecondaryContainer: const Color(0xFF0C4A6E),
    tertiary: tertiaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFD1FAE5),
    onTertiaryContainer: const Color(0xFF064E3B),
    error: moneyOut,
    onError: Colors.white,
    errorContainer: moneyOutLight,
    onErrorContainer: const Color(0xFF7F1D1D),
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    onSurfaceVariant: textSecondaryLight,
    outline: borderLight,
    outlineVariant: const Color(0xFFF1F5F9),
    shadow: const Color(0x1A0F172A),
    inverseSurface: const Color(0xFF1E293B),
    onInverseSurface: const Color(0xFFF1F5F9),
  );

  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: const Color(0xFF1A1164),
    primaryContainer: const Color(0xFF2D2780),
    onPrimaryContainer: const Color(0xFFE8E6FF),
    secondary: secondaryDark,
    onSecondary: const Color(0xFF0C4A6E),
    secondaryContainer: const Color(0xFF0C4A6E),
    onSecondaryContainer: const Color(0xFFE0F2FE),
    tertiary: tertiaryDark,
    onTertiary: const Color(0xFF064E3B),
    tertiaryContainer: const Color(0xFF064E3B),
    onTertiaryContainer: const Color(0xFFD1FAE5),
    error: const Color(0xFFFCA5A5),
    onError: const Color(0xFF7F1D1D),
    errorContainer: moneyOutDark,
    onErrorContainer: const Color(0xFFFEE2E2),
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    onSurfaceVariant: textSecondaryDark,
    outline: borderDark,
    outlineVariant: const Color(0xFF1E293B),
    shadow: const Color(0x4D000000),
    inverseSurface: const Color(0xFFF1F5F9),
    onInverseSurface: const Color(0xFF0F172A),
  );
}
