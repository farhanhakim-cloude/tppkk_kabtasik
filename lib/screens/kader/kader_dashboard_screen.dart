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
import '../catatan_kegiatan_form_screen.dart';
import '../berita_form_screen.dart';
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
  int _selectedCategoryIndex = 0; // 0: Semua, 1: Pokja I, 2: Pokja II, 3: Pokja III, 4: Pokja IV
  int _selectedBottomNavIndex = 0;
  bool _isDarkMode = false; // ikut global themeNotifier (default light)

  // ignore: unused_field
  final List<String> _categories = const [
    'Semua',
    'Pokja I',
    'Pokja II',
    'Pokja III',
    'Pokja IV',
  ];

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
        _desaKecamatan = desa.isNotEmpty ? '$desa, $kec' : 'Kec. $kec';
        _pokjaRole = ['pokja1', 'pokja2', 'pokja3', 'pokja4'].contains(role)
            ? role
            : null;
      });
    } catch (_) {}
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Dinamis untuk Dark Mode dan Light Mode
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF3F5F7);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    const primaryMint = Color(0xFF2ED9C3);
    final primaryMintAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final borderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final formattedDate = _getFormattedDate();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FutureBuilder<List<CatatanKegiatan>>(
          future: _catatanService.getAll(),
          builder: (context, catSnapshot) {
            final totalKegiatan = catSnapshot.data?.length ?? 0;

            return FutureBuilder(
              future: _beritaService.getMyBerita(),
              builder: (context, berSnapshot) {
                final totalBerita = berSnapshot.data?.length ?? 0;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Header: Hey, [Name] — tombol mode & keluar dipindah ke Profil ───
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Hey, '),
                                      TextSpan(
                                        text: _userName.split(' ').first,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          color: primaryMintAccent,
                                        ),
                                      ),
                                      const TextSpan(text: '!'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: subtextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ─── Banner Cuaca & Highlight Card (Persis Referensi Gambar) ───
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2ED9C3), Color(0xFF1FBFA8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryMint.withValues(alpha: _isDarkMode ? 0.28 : 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row Atas: Icon Cuaca Awan Cerah, Teks Cuaca, Lokasi, dan Suhu 28°
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: const [
                                                Positioned(
                                                  top: 7,
                                                  right: 8,
                                                  child: Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBBF24), size: 18),
                                                ),
                                                Positioned(
                                                  bottom: 6,
                                                  left: 7,
                                                  child: Icon(Icons.cloud_rounded, color: Colors.white, size: 24),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Cerah Berawan',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: const Color(0xFF0D3E38),
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'Kader Aktif',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: const Color(0xFF0A2E2A),
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _desaKecamatan,
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: const Color(0xFF0D3E38).withValues(alpha: 0.85),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Derajat Suhu
                                      Text(
                                        '28°',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF0D3E38),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 32,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  // Row Bawah: 4 Indikator
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildWeatherCardStat(
                                        label: 'Catatan',
                                        value: '$totalKegiatan Lap',
                                      ),
                                      _buildBannerDivider(),
                                      _buildWeatherCardStat(
                                        label: 'Berita',
                                        value: '$totalBerita Pos',
                                      ),
                                      _buildBannerDivider(),
                                      _buildWeatherCardStat(
                                        label: 'Kelembapan',
                                        value: '65%',
                                      ),
                                      _buildBannerDivider(),
                                      _buildWeatherCardStat(
                                        label: 'Status',
                                        value: _pokjaRole == null
                                            ? 'Siap 4 Pokja'
                                            : 'Akses ${_pokjaLabel(_pokjaRole!)}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ─── 2 FITUR UTAMA KADER (Grid 2 Kolom) ───
                            Row(
                              children: [
                                // Fitur 1: Catatan Kegiatan Pokja (Aksen Mint / Teal)
                                Expanded(
                                  child: _buildMainFeatureTile(
                                    title: 'Catatan Kegiatan',
                                    subtitle: '$totalKegiatan Laporan',
                                    icon: Icons.assignment_outlined,
                                    badgeText: _pokjaRole == null
                                        ? 'Pokja I - IV'
                                        : _pokjaLabel(_pokjaRole!),
                                    isMintTheme: true,
                                    primaryColor: primaryMintAccent,
                                    cardBg: cardBg,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    borderColor: borderColor,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const KaderCatatanKegiatanScreen()),
                                    ),
                                    onTapAction: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CatatanKegiatanFormScreen()),
                                      );
                                      setState(() {});
                                    },
                                    actionLabel: '+ Input',
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Fitur 2: Tulis & Publikasi Berita
                                Expanded(
                                  child: _buildMainFeatureTile(
                                    title: 'Kabar Berita',
                                    subtitle: '$totalBerita Terkirim',
                                    icon: Icons.newspaper_rounded,
                                    badgeText: 'Publikasi',
                                    isMintTheme: false,
                                    primaryColor: primaryMintAccent,
                                    cardBg: cardBg,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    borderColor: borderColor,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const KaderBeritaScreen()),
                                    ),
                                    onTapAction: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const BeritaFormScreen()),
                                      );
                                      setState(() {});
                                    },
                                    actionLabel: '+ Tulis',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ─── Akses Cepat Pokja (Filtered or All) ───
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AKSES CEPAT PER POKJA',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: subtextColor,
                                  ),
                                ),
                                if (_selectedCategoryIndex != 0)
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedCategoryIndex = 0),
                                    child: Text(
                                      'Lihat Semua',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: primaryMintAccent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            ..._buildPokjaList(cardBg, textColor, subtextColor, borderColor),
                          ],
                        ),
                      ),
                    ),

                    // ─── Modern Floating Bottom Navigation Bar ───
                    _buildBottomNavigationBar(cardBg, primaryMintAccent, borderColor, textColor, subtextColor),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCircleActionBtn({
    required IconData icon,
    required String tooltip,
    required Color cardBg,
    required Color iconColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildWeatherCardStat({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0D3E38),
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0D3E38).withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerDivider() {
    return Container(
      width: 1,
      height: 26,
      color: Colors.black.withValues(alpha: 0.1),
    );
  }

  Widget _buildMainFeatureTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required bool isMintTheme,
    required Color primaryColor,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required VoidCallback onTap,
    required VoidCallback onTapAction,
    required String actionLabel,
  }) {
    final activeBg = isMintTheme
        ? primaryColor.withValues(alpha: _isDarkMode ? 0.16 : 0.12)
        : cardBg;
    final activeBorder = isMintTheme
        ? primaryColor.withValues(alpha: 0.6)
        : borderColor;

    return Container(
      height: 195,
      decoration: BoxDecoration(
        color: activeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeBorder, width: 1.2),
        boxShadow: isMintTheme
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                if (!_isDarkMode)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Icon & Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMintTheme
                            ? primaryColor.withValues(alpha: 0.25)
                            : (_isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isMintTheme ? primaryColor : (_isDarkMode ? Colors.white : const Color(0xFF334155)),
                        size: 22,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMintTheme
                            ? primaryColor.withValues(alpha: 0.2)
                            : (_isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isMintTheme
                              ? primaryColor
                              : (_isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Bottom row: Quick action button + indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BUKA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isMintTheme
                            ? primaryColor
                            : (_isDarkMode ? Colors.white54 : const Color(0xFF94A3B8)),
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: onTapAction,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isMintTheme
                              ? primaryColor
                              : (_isDarkMode ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          actionLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isMintTheme
                                ? (_isDarkMode ? const Color(0xFF0A2E2A) : Colors.white)
                                : (_isDarkMode ? Colors.white : const Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPokjaList(
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    final allPokjas = [
      _PokjaItem(
        pokja: PokjaKategori.pokja1,
        title: 'Pokja I',
        desc: 'Penghayatan Pancasila & Gotong Royong',
        color: const Color(0xFF38BDF8),
        icon: Icons.groups_rounded,
        index: 1,
      ),
      _PokjaItem(
        pokja: PokjaKategori.pokja2,
        title: 'Pokja II',
        desc: 'Pendidikan, Keterampilan & UP2K',
        color: const Color(0xFF10B981),
        icon: Icons.school_rounded,
        index: 2,
      ),
      _PokjaItem(
        pokja: PokjaKategori.pokja3,
        title: 'Pokja III',
        desc: 'Pangan, Sandang & Perumahan',
        color: const Color(0xFFF59E0B),
        icon: Icons.cottage_rounded,
        index: 3,
      ),
      _PokjaItem(
        pokja: PokjaKategori.pokja4,
        title: 'Pokja IV',
        desc: 'Kesehatan, Kelestarian Lingkungan',
        color: const Color(0xFFEF4444),
        icon: Icons.health_and_safety_rounded,
        index: 4,
      ),
    ];

    final roleIndex = _pokjaRole == null
        ? null
        : int.tryParse(_pokjaRole!.substring('pokja'.length));
    final filtered = roleIndex != null
        ? allPokjas.where((p) => p.index == roleIndex).toList()
        : (_selectedCategoryIndex == 0
            ? allPokjas
            : allPokjas.where((p) => p.index == _selectedCategoryIndex).toList());

    return filtered.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KaderCatatanKegiatanScreen(pokjaDefault: item.pokja),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!_isDarkMode)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 20, color: item.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.desc,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: subtextColor.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  String _pokjaLabel(String role) {
    switch (role) {
      case 'pokja1':
        return 'Pokja I';
      case 'pokja2':
        return 'Pokja II';
      case 'pokja3':
        return 'Pokja III';
      case 'pokja4':
        return 'Pokja IV';
      default:
        return 'Pokja';
    }
  }

  Widget _buildBottomNavigationBar(
    Color cardBg,
    Color primaryColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    // nav ala contoh: pill putih, icon di atas label, selected ada pill background soft
    final navItems = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.assignment_rounded, Icons.assignment_outlined, 'Catatan'),
      (Icons.newspaper_rounded, Icons.newspaper_outlined, 'Berita'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDarkMode ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = _selectedBottomNavIndex == index;
          final (iconFilled, iconOut, label) = navItems[index];
          return Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedBottomNavIndex = index);
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KaderCatatanKegiatanScreen()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KaderBeritaScreen()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ).then((_) {
                    _loadUserInfo();
                    if (mounted) setState(() => _selectedBottomNavIndex = 0);
                  });
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withValues(alpha: _isDarkMode ? 0.18 : 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? iconFilled : iconOut,
                      color: isSelected ? primaryColor : (_isDarkMode ? Colors.white54 : const Color(0xFF94A3B8)),
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? primaryColor : (_isDarkMode ? Colors.white54 : const Color(0xFF64748B)),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

}

class _PokjaItem {
  final PokjaKategori pokja;
  final String title;
  final String desc;
  final Color color;
  final IconData icon;
  final int index;

  _PokjaItem({
    required this.pokja,
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
    required this.index,
  });
}
