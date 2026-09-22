// lib/screens/dasawisma/data_umum_dasawisma_screen.dart
// Halaman Data Umum Dasawisma (Gabungan Data Keluarga + Data Umum)
// Berisi 4 Tab:
// Tab 1: Keluarga Binaan & Rekap Warga (DataKeluargaDasawismaListScreen)
// Tab 2: Data Keluarga / KK & Anggota (KeluargaListScreen)
// Tab 3: Rekap Ibu Hamil & Bayi (RekapIbuAnakListScreen)
// Tab 4: Data Umum PKK Tingkat Desa & Kecamatan (DataUmumPkkListScreen)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'data_umum_pkk_list_screen.dart';
import 'keluarga_list_screen.dart';

class DataUmumDasawismaScreen extends StatefulWidget {
  /// Indeks tab awal, default 0 (Keluarga Binaan)
  final int initialIndex;
  const DataUmumDasawismaScreen({super.key, this.initialIndex = 0});

  @override
  State<DataUmumDasawismaScreen> createState() => _DataUmumDasawismaScreenState();
}

class _DataUmumDasawismaScreenState extends State<DataUmumDasawismaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryAccent = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 2),
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
              'Data Umum',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
            Text(
              'Keluarga Binaan, KK Warga & Data Umum Desa/Kec.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: const [
                Tab(
                  height: 48,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.groups_rounded, size: 15),
                    SizedBox(width: 6),
                    Text('Keluarga Binaan'),
                  ]),
                ),
                Tab(
                  height: 48,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.family_restroom_rounded, size: 15),
                    SizedBox(width: 6),
                    Text('Data KK'),
                  ]),
                ),
                Tab(
                  height: 48,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.assignment_rounded, size: 15),
                    SizedBox(width: 6),
                    Text('Data Umum PKK'),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // TAB 1: Keluarga Binaan Dasawisma + Rekap per Tingkat (Dasawisma → Kecamatan)
          DataKeluargaDasawismaListScreen(embedded: true),

          // TAB 2: Data Keluarga / KK & Anggota
          KeluargaListScreen(embedded: true),

          // TAB 3: Data Umum PKK Tingkat Desa & Kecamatan (Gambar 1-2)
          DataUmumPkkListScreen(embedded: true),
        ],
      ),
    );
  }
}

