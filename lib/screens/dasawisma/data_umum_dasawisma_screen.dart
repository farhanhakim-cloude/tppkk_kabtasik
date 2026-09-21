// lib/screens/dasawisma/data_umum_dasawisma_screen.dart
// Halaman Data Umum Dasawisma
// Berisi 2 Tab Sesuai Format Gambar Excel Dasawisma:
// Tab 1: Rekapitulasi Data & Kegiatan Warga Kelompok Dasa Wisma (Gambar 1 - 30 Kolom)
// Tab 2: Rekapitulasi Data Ibu Hamil, Melahirkan, Nifas, Bayi & Kematian (Gambar 2 - 17 Kolom)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'data_keluarga_dasawisma_list_screen.dart';

class DataUmumDasawismaScreen extends StatefulWidget {
  const DataUmumDasawismaScreen({super.key});

  @override
  State<DataUmumDasawismaScreen> createState() => _DataUmumDasawismaScreenState();
}

class _DataUmumDasawismaScreenState extends State<DataUmumDasawismaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryAccent = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: _darkText),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Umum Dasawisma',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
            Text(
              'Format Rekap Data Kegiatan Warga & Ibu Hamil Dasawisma',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
          labelColor: _primaryAccent,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: _primaryAccent,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '1. Rekap Data & Kegiatan Warga'),
            Tab(text: '2. Rekap Ibu Hamil & Bayi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Rekapitulasi Catatan Data dan Kegiatan Warga Kelompok Dasa Wisma (Gambar 1)
          const DataKeluargaDasawismaListScreen(embedded: true),

          // TAB 2: Rekapitulasi Ibu Hamil, Melahirkan, Nifas, Bayi & Kematian (Gambar 2)
          const RekapIbuAnakListScreen(embedded: true),
        ],
      ),
    );
  }
}
