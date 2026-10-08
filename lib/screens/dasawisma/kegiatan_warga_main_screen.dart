// lib/screens/dasawisma/kegiatan_warga_main_screen.dart
// Hub Kegiatan Warga — Pekarangan & Industri adalah bagian dari Kegiatan.
// 3 tab: Kegiatan (rekap peserta) | Pekarangan (rincian lahan) | Industri (rincian usaha).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kegiatan_warga_list_screen.dart';
import 'pemanfaatan_tanah_list_screen.dart';
import 'industri_rumah_tangga_list_screen.dart';

class KegiatanWargaMainScreen extends StatefulWidget {
  final int initialIndex;
  const KegiatanWargaMainScreen({super.key, this.initialIndex = 0});

  static const Color navy = Color(0xFF0F326D);
  static const Color biru = Color(0xFF0072BC);

  @override
  State<KegiatanWargaMainScreen> createState() => _KegiatanWargaMainScreenState();
}

class _KegiatanWargaMainScreenState extends State<KegiatanWargaMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          tooltip: 'Kembali',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kegiatan Warga',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, fontSize: 16.5, color: const Color(0xFF0F172A))),
            Text('Pekarangan & Industri ada di dalam sini',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tab,
              onTap: (_) => HapticFeedback.selectionClick(),
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))
              ]),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF0F326D),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Kegiatan'),
                Tab(text: 'Pekarangan'),
                Tab(text: 'Industri'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          KegiatanWargaListScreen(embedded: true),
          PemanfaatanTanahListScreen(embedded: true),
          IndustriRumahTanggaListScreen(embedded: true),
        ],
      ),
    );
  }
}
