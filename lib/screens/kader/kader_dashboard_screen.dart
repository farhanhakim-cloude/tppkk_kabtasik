// lib/screens/kader/kader_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';

import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../../services/berita_service.dart';
import '../catatan_kegiatan_form_screen.dart';
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

  String _weatherCity = 'Tasikmalaya';
  String _weatherCondition = 'Cerah Berawan';
  int _weatherTemp = 28;
  int _weatherHumidity = 65;

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  Future<void> _loadWeather() async {
    try {
      final res = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=-7.3274&longitude=108.2207&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=Asia%2FJakarta')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).round();
        final humidity = (current['relative_humidity_2m'] as num).round();
        final code = current['weather_code'] as int;
        String condition;
        if (code == 0) condition = 'Cerah';
        else if (code <= 3) condition = 'Berawan';
        else if (code <= 48) condition = 'Berkabut';
        else if (code <= 67) condition = 'Hujan';
        else if (code <= 77) condition = 'Salju';
        else if (code <= 99) condition = 'Badai';
        else condition = 'Cerah Berawan';
        if (!mounted) return;
        setState(() {
          _weatherTemp = temp;
          _weatherHumidity = humidity;
          _weatherCondition = condition;
        });
      }
    } catch (_) {}
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
    _loadWeather();
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

  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF10141D) : const Color(0xFFF1F4F9);
    const brandBlue = Color(0xFF0072BC); // Biru resmi TP PKK seperti tombol login

    final pages = [
      _buildBeranda(bgColor, brandBlue),
      const KaderCatatanKegiatanScreen(),
      const KaderBeritaScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () async {
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
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 28, color: Color(0xFF0072BC)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: brandBlue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: brandBlue.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navItem(0, Icons.home_rounded, 'Beranda'),
                      const SizedBox(width: 4),
                      _navItem(1, Icons.assignment_outlined, 'Catatan'),
                    ],
                  ),
                  // Center gap for FAB (match FAB diameter)
                  const SizedBox(width: 60),
                  // Right group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navItem(2, Icons.newspaper_rounded, 'Kabar'),
                      const SizedBox(width: 4),
                      _navItem(3, Icons.person_outline_rounded, 'Profil'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final isSelected = _navIndex == idx;
    return InkWell(
      onTap: () => setState(() => _navIndex = idx),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFF0072BC) : Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeranda(Color bgColor, Color brandBlue) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242F) : Colors.white;
    final textCol = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: brandBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KOP PROFIL DINAS (Bersih, Rapi & Elegan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: brandBlue,
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _pokjaRole != null
                                ? '${_pokjaRole!.toUpperCase()} • $_desaKecamatan'
                                : 'Kader PKK • $_desaKecamatan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_none_rounded, color: sub, size: 22),
                      onPressed: () {},
                      tooltip: 'Pemberitahuan',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. RINGKASAN DATA RESMI (2 KARTU UTAMA: Kegiatan & Kabar)
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
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textCol,
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
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. CATATAN KEGIATAN TERKINI (DATA YANG SUDAH DI INPUT)
              FutureBuilder<List<CatatanKegiatan>>(
                future: _catatanService.getAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
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
                        children: [
                          Text(
                            'Catatan Kegiatan Terkini',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: textCol,
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _navIndex = 1),
                            child: Text(
                              'Lihat Semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
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
                color: const Color(0xFFF1F5F9),
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
    final statusColor = item.status == StatusKegiatan.dibaca
        ? const Color(0xFF10B981)
        : const Color(0xFFD97706);
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
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
    }
  }
}
