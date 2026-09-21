// lib/screens/dasawisma/data_keluarga_main_screen.dart
// Halaman Utama Data Keluarga Dasawisma
// Berisi 2 Tab:
// 1. Data Keluarga Binaan (DataKeluargaDasawismaListScreen)
// 2. Data Keluarga / KK & Anggota (KeluargaListScreen)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'keluarga_list_screen.dart';

class DataKeluargaMainScreen extends StatefulWidget {
  final int initialIndex;
  const DataKeluargaMainScreen({super.key, this.initialIndex = 0});

  @override
  State<DataKeluargaMainScreen> createState() => _DataKeluargaMainScreenState();
}

class _DataKeluargaMainScreenState extends State<DataKeluargaMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryAccent = Color(0xFF10B981);
  static const Color _darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
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
              'Data Keluarga',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: _darkText,
              ),
            ),
            Text(
              'Keluarga Binaan & Data KK Warga',
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
              indicatorColor: _primaryAccent,
              indicatorWeight: 3,
              labelColor: _primaryAccent,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.groups_rounded, size: 18),
                  text: 'Keluarga Binaan',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.family_restroom_rounded, size: 18),
                  text: 'Data Keluarga (KK)',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DataKeluargaDasawismaListScreen(embedded: true),
          KeluargaListScreen(embedded: true),
        ],
      ),
    );
  }
}
