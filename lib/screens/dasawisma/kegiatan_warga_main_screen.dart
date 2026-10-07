// lib/screens/dasawisma/kegiatan_warga_main_screen.dart
// Halaman Kegiatan Warga Dasawisma — SATU layar Rekap Berjenjang.
// Tab satuan (Kegiatan, Kriteria Rumah, Catatan, Pekarangan, Industri RT)
// sudah dihapus dari navigasi: input lewat "Input Terpadu Satu Pintu",
// angka rekap otomatis. File-file list/form satuan tetap ada di codebase
// dan bisa dipasang lagi bila needed (mis. untuk edit per item).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kegiatan_rekap_berjenjang_screen.dart';

class KegiatanWargaMainScreen extends StatelessWidget {
  final int initialIndex;
  const KegiatanWargaMainScreen({super.key, this.initialIndex = 0});

  static const Color _darkText = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 20, color: _darkText),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kegiatan Warga',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: _darkText,
              ),
            ),
            Text(
              'Rekap otomatis + Input Terpadu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: const KegiatanRekapBerjenjangScreen(embedded: true),
    );
  }
}
