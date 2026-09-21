// lib/screens/dasawisma/kegiatan_warga_main_screen.dart
// Halaman Utama Kegiatan Warga Dasawisma
// Berisi 5 Tab Sesuai Pengelompokan Kegiatan Warga:
// 1. Kegiatan Warga (7 Kegiatan: Pancasila, Gotong Royong, dll)
// 2. Kriteria Rumah (Sehat / Tidak Sehat)
// 3. Catatan Keluarga (19 Kolom + Kegiatan PKK)
// 4. Pemanfaatan Tanah Pekarangan (AKU HATINYA PKK)
// 5. Industri Rumah Tangga (Pangan, Sandang, Jasa)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kegiatan_warga_list_screen.dart';
import 'kriteria_rumah_list_screen.dart';
import 'catatan_keluarga_list_screen.dart';
import 'pemanfaatan_tanah_list_screen.dart';
import 'industri_rumah_tangga_list_screen.dart';

class KegiatanWargaMainScreen extends StatefulWidget {
  final int initialIndex;
  const KegiatanWargaMainScreen({super.key, this.initialIndex = 0});

  @override
  State<KegiatanWargaMainScreen> createState() => _KegiatanWargaMainScreenState();
}

class _KegiatanWargaMainScreenState extends State<KegiatanWargaMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryAccent = Color(0xFF0EA5E9);
  static const Color _darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
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
              'Kegiatan Warga',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: _darkText,
              ),
            ),
            Text(
              'Kegiatan, Rumah, Catatan, Pekarangan & Industri RT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _primaryAccent,
              indicatorWeight: 3,
              labelColor: _primaryAccent,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.diversity_3_rounded, size: 17),
                  text: 'Kegiatan Warga',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.home_rounded, size: 17),
                  text: 'Kriteria Rumah',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.assignment_ind_rounded, size: 17),
                  text: 'Catatan Keluarga',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.grass_rounded, size: 17),
                  text: 'Pemanfaatan Tanah',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.storefront_rounded, size: 17),
                  text: 'Industri RT',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          KegiatanWargaListScreen(embedded: true),
          KriteriaRumahListScreen(embedded: true),
          CatatanKeluargaListScreen(embedded: true),
          PemanfaatanTanahListScreen(embedded: true),
          IndustriRumahTanggaListScreen(embedded: true),
        ],
      ),
    );
  }
}
