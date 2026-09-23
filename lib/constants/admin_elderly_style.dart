// lib/constants/admin_elderly_style.dart
// Standar tampilan panel Admin — disamakan dengan halaman Kader
// (kader_dashboard, kader_berita, kader_catatan_kegiatan):
// kartu putih polos, border samar, font kecil estetik yang tajam.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminElderlyStyle {
  // ── Warna disamakan dengan halaman kader ──
  static const Color lightText = Color(0xFF14181D);
  static const Color lightSubtext = Color(0xFF64748B);
  static const Color lightHint = Color(0xFF94A3B8);

  static const Color darkText = Colors.white;
  static const Color darkSubtext = Color(0xFF8E9BAE);

  static const Color primary = Color(0xFF0D9488);
  static const Color primaryBright = Color(0xFF2ED9C3);

  // ── Ukuran font: proporsi awal yang estetik, sedikit dipertajam ──
  static const double greetingSize = 19;
  static const double dateSize = 12.5;
  static const double sectionSize = 12;
  static const double cardTitleSize = 16;
  static const double cardBodySize = 13.5;
  static const double cardMetaSize = 12.5;
  static const double badgeSize = 11.5;
  static const double buttonSize = 13.5;
  static const double appBarTitleSize = 17;
  static const double appBarSubtitleSize = 12;
  static const double chipLabelSize = 12.5;
  static const double chipCountSize = 11.5;
  static const double countBigSize = 25;
  static const double dialogTitleSize = 17;
  static const double dialogBodySize = 14;

  // ── Helper text style ──
  static TextStyle greeting(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: greetingSize,
    fontWeight: FontWeight.w500,
    color: isDark ? darkText : lightText,
    height: 1.3,
  );

  static TextStyle greetingBold(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: greetingSize,
    fontWeight: FontWeight.w800,
    color: isDark ? primaryBright : primary,
    height: 1.3,
  );

  static TextStyle date(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: dateSize,
    fontWeight: FontWeight.w600,
    color: isDark ? darkSubtext : lightSubtext,
  );

  static TextStyle section(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: sectionSize,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    color: isDark ? darkSubtext : lightSubtext,
  );

  static TextStyle title(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: cardTitleSize,
    fontWeight: FontWeight.w800,
    color: isDark ? darkText : lightText,
    height: 1.35,
  );

  static TextStyle body(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: cardBodySize,
    fontWeight: FontWeight.w500,
    color: isDark ? darkSubtext : lightSubtext,
    height: 1.5,
  );

  static TextStyle meta(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: cardMetaSize,
    fontWeight: FontWeight.w600,
    color: isDark ? darkSubtext : lightSubtext,
  );

  static TextStyle button() => GoogleFonts.plusJakartaSans(
    fontSize: buttonSize,
    fontWeight: FontWeight.w800,
  );

  // ── Warna kartu bersih ala kader ──
  static Color cardBg(bool isDark) =>
      isDark ? const Color(0xFF1E242D) : Colors.white;

  static Color border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);

  static List<BoxShadow> cardShadow(bool isDark) => isDark
      ? const []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
}
