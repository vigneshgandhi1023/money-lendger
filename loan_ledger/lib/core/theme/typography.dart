import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for Loan Ledger.
///
/// Uses Google Fonts:
/// - **Outfit** for display/headline text (premium, geometric)
/// - **Inter** for body/label text (high legibility, UI-optimized)
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final Color primaryText = brightness == Brightness.light
        ? const Color(0xFF0F172A)
        : const Color(0xFFF1F5F9);

    final Color secondaryText = brightness == Brightness.light
        ? const Color(0xFF475569)
        : const Color(0xFF94A3B8);

    return TextTheme(
      // Display — Large hero numbers (dashboard KPIs)
      displayLarge: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: primaryText,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: primaryText,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: primaryText,
        height: 1.2,
      ),

      // Headline — Section headers
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primaryText,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primaryText,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
        height: 1.3,
      ),

      // Title — Card titles, list headers
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primaryText,
        height: 1.35,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
        height: 1.4,
      ),

      // Body — Main content text
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryText,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.4,
      ),

      // Label — Buttons, chips, badges
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryText,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: secondaryText,
        height: 1.3,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: secondaryText,
        height: 1.3,
      ),
    );
  }
}
