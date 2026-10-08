// lib/screens/dasawisma/dasawisma_dashboard_screen.dart
// Dashboard Dasawisma — bersih, formal, standar dinas.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../main.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../services/auth_service.dart';
import '../../services/daftar_warga_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/bumil_service.dart';
import '../../widgets/skeleton.dart';

import 'input_keluarga_dasawisma_screen.dart';
import 'input_terpadu_screen.dart';
import 'data_umum_rekap_screen.dart';
import 'kegiatan_warga_main_screen.dart';
import 'bumil_ibu_list_screen.dart';
import '../profile_screen.dart';

class DasawismaDashboardScreen extends StatefulWidget {
  const DasawismaDashboardScreen({super.key});

  @override
  State<DasawismaDashboardScreen> createState() => _DasawismaDashboardScreenState();
}

class _DasawismaDashboardScreenState extends State<DasawismaDashboardScreen> {
  static const Color biru = Color(0xFF0072BC);
  static const Color ink = Color(0xFF1A2B3C);
  static const Color muted = Color(0xFF5B6B7C);
  static const Color line = Color(0xFFE1E7EE);
  static const Color paper = Color(0xFFF4F6F9);

  String _userName = 'Kader Dasawisma';
  String _desa = '';
  String _kecamatan = '';
  bool _isDarkMode = false;
  int _navIndex = 0;

  bool _loading = true;
  List<DataKeluargaDasawisma> _listKk = [];
  int _totalKk = 0;
  int _totalJiwa = 0;
  int _totalBalita = 0;
  int _totalBumil = 0;
  int _totalKegiatan = 0;
  int _pendingKk = 0;
  int _approvedKk = 0;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadUserInfo();
    _loadData();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (!mounted) return;
      setState(() {
        _userName = user.name;
        _desa = user.desa;
        _kecamatan = user.kecamatan;
      });
      if (_desa.isEmpty && _kecamatan.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('user_data') ?? prefs.getString('user') ?? '{}';
        final data = jsonDecode(raw);
        if (!mounted) return;
        setState(() {
          _userName = (data['name'] ?? data['nama'] ?? _userName).toString();
          _desa = (data['desa'] ?? data['kelurahan'] ?? '').toString();
          _kecamatan = (data['kecamatan'] ?? '').toString();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      List<DataKeluargaDasawisma> listKk = [];
      var listKeg = <dynamic>[];
      var listBumil = <dynamic>[];
      try {
        listKk = await DaftarWargaService().getAll();
      } catch (_) {}
      try {
        listKeg = await KegiatanWargaService().getAll();
      } catch (_) {}
      try {
        listBumil = await BumilService().getAll();
      } catch (_) {}

      int totalJiwa = 0;
      int totalBalita = 0;
      int pending = 0;
      int approved = 0;
      for (final kk in listKk) {
        totalJiwa += (kk.jumlahLakiLaki + kk.jumlahPerempuan);
        totalBalita += (kk.jumlahBalitaL + kk.jumlahBalitaP);
        final s = kk.status.toLowerCase();
        if (s == 'approved' || s == 'disetujui') {
          approved++;
        } else if (s == 'rejected' || s == 'ditolak') {
        } else {
          pending++;
        }
      }
      if (!mounted) return;
      setState(() {
        _listKk = listKk;
        _totalKk = listKk.length;
        _totalJiwa = totalJiwa;
        _totalBalita = totalBalita;
        _totalBumil = listBumil.length;
        _totalKegiatan = listKeg.length;
        _pendingKk = pending;
        _approvedKk = approved;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openInputForm() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InputKeluargaDasawismaScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _go(Widget page, {bool refresh = false}) async {
    HapticFeedback.selectionClick();
    final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (refresh && r == true && mounted) _loadData();
  }

  TextStyle get _tTitle => GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: ink);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildBeranda(),
      const DataUmumRekapScreen(),
      const KegiatanWargaMainScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: paper,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: line)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
                _navItem(1, Icons.folder_outlined, Icons.folder_rounded, 'Data Umum'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: ElevatedButton(
                      onPressed: _openInputForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: biru,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Input',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                _navItem(2, Icons.assignment_outlined, Icons.assignment_rounded, 'Kegiatan'),
                _navItem(3, Icons.person_outline, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData iconActive, String label) {
    final sel = _navIndex == idx;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _navIndex = idx);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? iconActive : icon, size: 22, color: sel ? biru : muted),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? biru : muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildBeranda() {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: biru,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusStrip(),
                    const SizedBox(height: 14),
                    Text('Layanan Pendataan', style: _tTitle),
                    const SizedBox(height: 8),
                    _menuGrid(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Ringkasan', style: _tTitle),
                        TextButton(
                          onPressed: () => _go(const DataUmumRekapScreen()),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                          child: Text('Lihat rekap',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: biru)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _stats(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Data Terbaru', style: _tTitle),
                        TextButton(
                          onPressed: () => setState(() => _navIndex = 1),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                          child: Text('Lihat semua',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: biru)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _recent(),
                    const SizedBox(height: 14),
                    _alur(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kepala dinas: biru PKK solid, teks putih, logo di kotak putih.
  Widget _header() {
    final wilayah =
        _desa.isNotEmpty && _kecamatan.isNotEmpty ? 'Desa $_desa • Kec. $_kecamatan' : 'Kab. Tasikmalaya';
    final initial = _userName.trim().isEmpty ? 'D' : _userName.trim()[0].toUpperCase();
    return Container(
      color: biru,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.account_balance_outlined, color: biru, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TP PKK KAB. TASIKMALAYA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.4)),
                    Text('Dasawisma',
                        style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadData,
                tooltip: 'Muat ulang',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(17)),
                child: Center(
                    child: Text(initial,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: biru))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('$_userName  •  $wilayah',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.lock_outline_rounded, size: 12, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusStrip() {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 160, height: 13),
            SizedBox(height: 10),
            SkeletonBox(width: double.infinity, height: 6, radius: 4),
            SizedBox(height: 8),
            SkeletonBox(width: 220, height: 11, radius: 6),
          ],
        ),
      );
    }
    final pct = _totalKk == 0 ? 0.0 : (_approvedKk / _totalKk).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status Verifikasi Desa',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: ink)),
              Text('$_approvedKk dari $_totalKk disetujui',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: paper,
              valueColor: const AlwaysStoppedAnimation<Color>(biru),
            ),
          ),
          const SizedBox(height: 8),
          Text('$_pendingKk menunggu  •  $_totalJiwa jiwa  •  $_totalBalita balita',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted)),
        ],
      ),
    );
  }

  // Layanan ringkas — Terpadu jadi sorotan biru, sisanya putih bersih.
  Widget _menuGrid() {
    final items = [
      _Layanan(Icons.add_box_outlined, 'Input KK', () => _openInputForm(), false),
      _Layanan(Icons.flash_on_outlined, 'Terpadu', () => _go(const InputTerpaduScreen(), refresh: true), true),
      _Layanan(Icons.pregnant_woman_outlined, 'Bumil', () => _go(const BumilIbuListScreen(), refresh: true), false),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.12),
      itemCount: items.length,
      itemBuilder: (c, i) {
        final m = items[i];
        final bg = m.primary ? biru : Colors.white;
        final fg = m.primary ? Colors.white : biru;
        final tx = m.primary ? Colors.white : ink;
        return Material(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: m.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: m.primary ? biru : line)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(m.icon, size: 24, color: fg),
                    const SizedBox(height: 6),
                    Text(m.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5, fontWeight: FontWeight.w700, color: tx)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stats() {
    if (_loading) {
      return const SkeletonStats();
    }
    return Row(
      children: [
        _statBox('KK', '$_totalKk', () => setState(() => _navIndex = 1)),
        const SizedBox(width: 10),
        _statBox('Jiwa', '$_totalJiwa', () => setState(() => _navIndex = 1)),
        const SizedBox(width: 10),
        _statBox('Bumil', '$_totalBumil', () => _go(const BumilIbuListScreen())),
        const SizedBox(width: 10),
        _statBox('Giat', '$_totalKegiatan', () => setState(() => _navIndex = 2)),
      ],
    );
  }

  Widget _statBox(String label, String value, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
            child: Column(
              children: [
                Text(value,
                    style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700, color: biru)),
                const SizedBox(height: 2),
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recent() {
    if (_loading) {
      return const SkeletonList(count: 3);
    }
    if (_listKk.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Belum ada data',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                  const SizedBox(height: 2),
                  Text('Mulai dengan Input Data Keluarga.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _openInputForm,
              style: ElevatedButton.styleFrom(
                  backgroundColor: biru,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
              child: Text('Input',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
    final recent = _listKk.take(3).toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
      child: Column(
        children: [
          for (int i = 0; i < recent.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _navIndex = 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                recent[i].namaKepalaRumahTangga.isEmpty
                                    ? '(Tanpa nama kepala rumah tangga)'
                                    : recent[i].namaKepalaRumahTangga,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                            const SizedBox(height: 2),
                            Text('RT ${recent[i].rt}/RW ${recent[i].rw}  •  ${recent[i].jumlahLakiLaki + recent[i].jumlahPerempuan} jiwa',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusText(recent[i].status),
                    ],
                  ),
                ),
              ),
            ),
            if (i < recent.length - 1) const Divider(height: 1, indent: 14, endIndent: 14, color: line),
          ],
        ],
      ),
    );
  }

  Widget _statusText(String status) {
    final s = status.toLowerCase();
    final Color c;
    final String t;
    if (s == 'approved' || s == 'disetujui') {
      c = const Color(0xFF1B7A4D);
      t = 'Disetujui';
    } else if (s == 'rejected' || s == 'ditolak') {
      c = const Color(0xFFB42318);
      t = 'Ditolak';
    } else {
      c = const Color(0xFF92600A);
      t = 'Menunggu';
    }
    return Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c));
  }

  Widget _alur() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
      child: Row(
        children: [
          _alurStep('1', 'Isi'),
          _alurDiv(),
          _alurStep('2', 'Terkirim'),
          _alurDiv(),
          _alurStep('3', 'Disetujui'),
        ],
      ),
    );
  }

  Widget _alurStep(String n, String t) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(7)),
            child: Center(
                child: Text(n,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: biru))),
          ),
          const SizedBox(width: 6),
          Flexible(
              child: Text(t,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: ink))),
        ],
      ),
    );
  }

  Widget _alurDiv() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Icon(Icons.chevron_right_rounded, size: 16, color: muted),
      );
}

class _Layanan {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool primary;
  _Layanan(this.icon, this.title, this.onTap, this.primary);
}
