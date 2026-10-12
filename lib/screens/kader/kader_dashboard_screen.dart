// lib/screens/kader/kader_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart';

import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../../services/berita_service.dart';
import '../../services/notifikasi_service.dart';
import '../../widgets/notifikasi_bell.dart';
import '../../widgets/skeleton.dart';
import '../notifikasi_screen.dart';
import '../catatan_kegiatan_form_screen.dart';
import 'buku_kegiatan_pokja1_form_screen.dart';
import 'kader_catatan_kegiatan_screen.dart';
import 'kader_berita_screen.dart';
import '../profile_screen.dart';

class KaderDashboardScreen extends StatefulWidget {
  const KaderDashboardScreen({super.key});

  @override
  State<KaderDashboardScreen> createState() => _KaderDashboardScreenState();
}

class _KaderDashboardScreenState extends State<KaderDashboardScreen> {
  final _catatanService = CatatanKegiatanService();
  final _beritaService = BeritaService();

  String _userName = 'Kader PKK';
  String _desaKecamatan = 'Kab. Tasikmalaya';
  String? _pokjaRole;
  int _navIndex = 0;
  bool _isDarkMode = false;
  
  int _totalKegiatan = 0;
  int _totalBerita = 0;
  bool _isLoading = true;
  int _unreadNotif = 0;
  final _notifService = NotifikasiService();

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

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
    _notifService.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data') ?? prefs.getString('user') ?? '{}';
      final data = jsonDecode(userDataStr);
      final nama = data['name'] ?? data['nama'] ?? 'Kader PKK';
      final desa = data['desa'] ?? data['kelurahan'] ?? '';
      final kec = data['kecamatan'] ?? prefs.getString('default_kecamatan') ?? 'Tasikmalaya';
      final role = (data['role'] ?? '').toString().toLowerCase();

      setState(() {
        _userName = nama;
        _desaKecamatan = 'Kabupaten Tasikmalaya';
        _pokjaRole = ['pokja1', 'pokja2', 'pokja3', 'pokja4'].contains(role) ? role : null;
      });
    } catch (_) {}
  }
  
  Future<void> _loadData() async {
    _refreshNotifCount();
    try {
      final catatan = await _catatanService.getAll();
      final berita = await _beritaService.getMyBerita();
      if (mounted) {
        setState(() {
          _totalKegiatan = catatan.length;
          _totalBerita = berita.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshNotifCount() async {
    final n = await _notifService.getUnreadCount();
    if (mounted) setState(() => _unreadNotif = n);
  }

  Future<void> _bukaNotifikasi() async {
    HapticFeedback.selectionClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
    );
    _refreshNotifCount();
  }

  // Palet Dinas selaras Dasawisma: biru 0072BC, ink 1A2B3C, muted 5B6B7C, line E1E7EE, paper F4F6F9.
  static const Color _biru = Color(0xFF0072BC);
  static const Color _ink = Color(0xFF1A2B3C);
  static const Color _muted = Color(0xFF5B6B7C);
  static const Color _line = Color(0xFFE1E7EE);
  static const Color _paper = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF10141D) : _paper;
    const brandBlue = _biru; // Biru resmi TP PKK seperti tombol login

    final pages = [
      _buildBeranda(bgColor, brandBlue),
      const KaderCatatanKegiatanScreen(),
      const KaderBeritaScreen(),
      const ProfileScreen(embedded: true),
    ];

    Future<void> openInputForm() async {
      HapticFeedback.mediumImpact();
      PokjaKategori? awal;
      if (_pokjaRole == 'pokja1') awal = PokjaKategori.pokja1;
      if (_pokjaRole == 'pokja2') awal = PokjaKategori.pokja2;
      if (_pokjaRole == 'pokja3') awal = PokjaKategori.pokja3;
      if (_pokjaRole == 'pokja4') awal = PokjaKategori.pokja4;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CatatanKegiatanFormScreen(pokjaAwal: awal),
        ),
      );
      _loadData();
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _line)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
                _navItem(1, Icons.assignment_outlined, Icons.assignment_rounded, 'Catatan'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: ElevatedButton(
                      onPressed: openInputForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Input',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                _navItem(2, Icons.newspaper_outlined, Icons.newspaper_rounded, 'Kabar'),
                _navItem(3, Icons.person_outline, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData iconActive, String label) {
    final isSelected = _navIndex == idx;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _navIndex = idx);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? iconActive : icon,
                size: 22, color: isSelected ? _biru : _muted),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _biru : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kepala dinas selaras Dasawisma: biru PKK solid, teks putih, logo di kotak putih.
  Widget _buildDinasHeader(Color brandBlue) {
    final roleLabel = _pokjaRole != null ? _pokjaRole!.toUpperCase() : 'KADER PKK';
    final initial = _userName.trim().isEmpty ? 'K' : _userName.trim()[0].toUpperCase();
    return Container(
      color: brandBlue,
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
                    errorBuilder: (_, _, _) => const Icon(Icons.account_balance_outlined, color: _biru, size: 22),
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
                    Text(roleLabel,
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
              NotifikasiBell(count: _unreadNotif, onTap: _bukaNotifikasi),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(17)),
                child: Center(
                    child: Text(initial,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: _biru))),
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
                  child: Text('$_userName  •  $_desaKecamatan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeranda(Color bgColor, Color brandBlue) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242F) : Colors.white;
    final textCol = _isDarkMode ? Colors.white : _ink;
    final sub = _isDarkMode ? const Color(0xFF94A3B8) : _muted;
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.08) : _line;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: brandBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kepala dinas selaras Dasawisma: biru solid + logo + user/wilayah.
              _buildDinasHeader(brandBlue),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

              // 2. RINGKASAN DATA RESMI (2 KARTU UTAMA: Kegiatan & Kabar).
              // Skeleton dinas selaras Dasawisma selagi _isLoading.
              if (_isLoading)
                Row(
                  children: [
                    Expanded(child: _buildSummarySkeletonCard(cardBg, border)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSummarySkeletonCard(cardBg, border)),
                  ],
                )
              else
                Row(
                  children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _navIndex = 1),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Kegiatan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub, fontWeight: FontWeight.w500)),
                                Icon(Icons.assignment_outlined, color: brandBlue, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_totalKegiatan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: brandBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _navIndex = 2),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kabar / Berita', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub, fontWeight: FontWeight.w500)),
                                Icon(Icons.newspaper_outlined, color: brandBlue, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_totalBerita',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: brandBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_pokjaRole == 'pokja1')
                InkWell(
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BukuKegiatanPokja1FormScreen(),
                      ),
                    );
                    if (res == true) _loadData();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brandBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: brandBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.menu_book_rounded,
                              color: brandBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Buku Kegiatan • Lamp. 4.13',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: textCol)),
                              const SizedBox(height: 2),
                              Text(
                                  'Input nama–uraian, terkirim pending ke admin kabupaten',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5, color: sub)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 15, color: brandBlue),
                      ],
                    ),
                  ),
                ),
              if (_pokjaRole == 'pokja1') const SizedBox(height: 12),
              if (_pokjaRole != 'pokja1') const SizedBox(height: 4),

              // 3. CATATAN KEGIATAN TERKINI (DATA YANG SUDAH DI INPUT)
              FutureBuilder<List<CatatanKegiatan>>(
                future: _catatanService.getAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Skeleton dinas selaras Dasawisma (tanpa spinner).
                    return const SkeletonList(count: 3);
                  }
                  final allList = snapshot.data ?? [];
                  final filteredList = _pokjaRole != null
                      ? allList.where((item) {
                          final roleNum = _pokjaRole!.replaceAll('pokja', '');
                          final targetKategori = roleNum == '1'
                              ? PokjaKategori.pokja1
                              : roleNum == '2'
                                  ? PokjaKategori.pokja2
                                  : roleNum == '3'
                                      ? PokjaKategori.pokja3
                                      : PokjaKategori.pokja4;
                          return item.kategori == targetKategori;
                        }).toList()
                      : allList;

                  if (filteredList.isEmpty) {
                    return _buildSimpleDinasCard(
                      title: _pokjaRole != null
                          ? 'Belum Ada Kegiatan ${_pokjaRole!.toUpperCase()}'
                          : 'Belum Ada Kegiatan Pokja',
                      subtitle: 'Tekan tombol di atas untuk mencatat kegiatan pertama',
                      badgeText: '0 Data',
                      icon: Icons.assignment_outlined,
                      brandBlue: brandBlue,
                      cardBg: cardBg,
                      textCol: textCol,
                      sub: sub,
                      border: border,
                      onTap: () => setState(() => _navIndex = 1),
                    );
                  }

                  final recentList = filteredList.take(3).toList();
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Catatan Kegiatan Terkini',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textCol,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _navIndex = 1),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                            child: Text(
                              'Lihat Semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: brandBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...recentList.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildSimpleActivityCard(
                          item: item,
                          cardBg: cardBg,
                          textCol: textCol,
                          sub: sub,
                          border: border,
                          brandBlue: brandBlue,
                        ),
                      )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
      ),
      ),
    ),
    );
  }

  // Skeleton kartu ringkasan selaras Dasawisma (tanpa spinner).
  Widget _buildSummarySkeletonCard(Color cardBg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 110, height: 12),
          SizedBox(height: 8),
          SkeletonBox(width: 48, height: 19),
        ],
      ),
    );
  }

  Widget _buildSimpleDinasCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color brandBlue,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required Color border,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: brandBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: sub),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: border),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: sub),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleActivityCard({
    required CatatanKegiatan item,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required Color border,
    required Color brandBlue,
  }) {
    // Status selaras Dasawisma: Disetujui hijau dinas, Menunggu mustard.
    final statusColor = item.status == StatusKegiatan.dibaca
        ? const Color(0xFF1B7A4D)
        : const Color(0xFF92600A);
    final statusLabel = item.status == StatusKegiatan.dibaca ? 'Disetujui' : 'Menunggu';
    final statusBg = item.status == StatusKegiatan.dibaca
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF7ED);
    final pokjaColor = _getPokjaColor(item.kategori);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KaderCatatanKegiatanScreen(pokjaDefault: item.kategori),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: pokjaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.kategori.shortLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: pokjaColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.judul.isNotEmpty ? item.judul : 'Tanpa judul',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.deskripsiSingkat.isNotEmpty
                  ? item.deskripsiSingkat
                  : 'Ketuk untuk lihat detail',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: sub,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 12, color: sub),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.tanggal),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: sub,
                  ),
                ),
                const SizedBox(width: 12),
                if (item.desa != null && item.desa!.isNotEmpty) ...[
                  Icon(Icons.location_on_rounded, size: 12, color: sub),
                  const SizedBox(width: 4),
                  Text(
                    item.desa!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: sub,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getPokjaColor(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return const Color(0xFF6366F1);
      case PokjaKategori.pokja2:
        return const Color(0xFF10B981);
      case PokjaKategori.pokja3:
        return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4:
        return const Color(0xFFEF4444);
      case PokjaKategori.pokja4Pyd:
        return const Color(0xFF8B5CF6);
      case PokjaKategori.pokja4Posyandu:
        return const Color(0xFF06B6D4);
      case PokjaKategori.pokja4Rekap:
        return const Color(0xFFEC4899);
      case PokjaKategori.pokja4DataDukung:
        return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4DataProgram:
        return const Color(0xFF14B8A6);
    }
  }
}