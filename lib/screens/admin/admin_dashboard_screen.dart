import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verifikasi_berita_screen.dart';
import 'verifikasi_laporan_screen.dart';
import '../berita_form_screen.dart';
import '../../constants/app_constants.dart';
import '../../models/catatan_kegiatan.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _pendingBeritaCount = 0;
  int _pendingLaporanCount = 0;
  Map<PokjaKategori, int> _pokjaPending = {
    PokjaKategori.pokja1: 0,
    PokjaKategori.pokja2: 0,
    PokjaKategori.pokja3: 0,
    PokjaKategori.pokja4: 0,
  };
  bool _loadingCount = true;

  String _weatherCity = 'Tasikmalaya';
  String _weatherCondition = 'Cerah Berawan';
  int _weatherTemp = 28;
  int _weatherFeelsLike = 31;
  int _weatherHumidity = 65;

  bool _isDarkMode = true;

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}, ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadPendingCounts();
    _loadWeather();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=-7.3274&longitude=108.2207&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=Asia%2FJakarta',
        ),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).round();
        final feelsLike = (current['apparent_temperature'] as num).round();
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
          _weatherFeelsLike = feelsLike;
          _weatherHumidity = humidity;
          _weatherCondition = condition;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPendingCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey) ?? '';
      if (token.isEmpty) {
        if (mounted) setState(() => _loadingCount = false);
        return;
      }

      // Berita pending
      final beritaRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      // Laporan Pokja pending — endpoint sama yang dipakai kader saat kirim
      final laporanRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.laporanKegiatan}'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      int beritaCount = 0;
      if (beritaRes.statusCode == 200) {
        final data = jsonDecode(beritaRes.body);
        final rawData = data['data'];
        if (rawData is List) beritaCount = rawData.length;
        else if (rawData is Map && rawData['data'] is List) beritaCount = (rawData['data'] as List).length;
        else if (data['count'] != null) beritaCount = data['count'] as int;
      }

      int laporanCount = 0;
      Map<PokjaKategori, int> pokjaMap = {
        PokjaKategori.pokja1: 0,
        PokjaKategori.pokja2: 0,
        PokjaKategori.pokja3: 0,
        PokjaKategori.pokja4: 0,
      };

      if (laporanRes.statusCode == 200) {
        final data = jsonDecode(laporanRes.body);
        final rawData = data['data'];
        List<dynamic> list = [];
        if (rawData is List) list = rawData;
        else if (rawData is Map && rawData['data'] is List) list = rawData['data'] as List;

        // Filter pending
        final pending = list.where((item) {
          final status = (item['status']?.toString() ?? '').toLowerCase().trim();
          final label = (item['status_label']?.toString() ?? '').toLowerCase().trim();
          return status == 'pending' || status == 'menunggu' || status == 'waiting' || label.contains('menunggu') || label.contains('pending');
        }).toList();

        laporanCount = pending.length;

        // Hitung per Pokja — sinkron dengan kategori_pokja yang dikirim kader (I,II,III,IV)
        for (final item in pending) {
          final kode = (item['kategori_pokja']?.toString() ?? item['kategori']?.toString() ?? '').toString().trim().toUpperCase();
          final kategoriRaw = (item['kategori']?.toString() ?? '').toString().toLowerCase();
          PokjaKategori? kat;
          if (kode == 'I' || kategoriRaw.contains('pokja1') || kategoriRaw.contains('pokja 1')) kat = PokjaKategori.pokja1;
          else if (kode == 'II' || kategoriRaw.contains('pokja2') || kategoriRaw.contains('pokja 2')) kat = PokjaKategori.pokja2;
          else if (kode == 'III' || kategoriRaw.contains('pokja3') || kategoriRaw.contains('pokja 3')) kat = PokjaKategori.pokja3;
          else if (kode == 'IV' || kategoriRaw.contains('pokja4') || kategoriRaw.contains('pokja 4')) kat = PokjaKategori.pokja4;
          else {
            // fallback via CatatanKegiatan.fromJson kategori
            try {
              final c = CatatanKegiatan.fromJson(item);
              kat = c.kategori;
            } catch (_) {}
          }
          if (kat != null) pokjaMap[kat] = (pokjaMap[kat] ?? 0) + 1;
        }
      }

      if (!mounted) return;
      setState(() {
        _pendingBeritaCount = beritaCount;
        _pendingLaporanCount = laporanCount;
        _pokjaPending = pokjaMap;
        _loadingCount = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCount = false);
    }
  }

  Color _pokjaColor(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1: return const Color(0xFF38BDF8);
      case PokjaKategori.pokja2: return const Color(0xFF10B981);
      case PokjaKategori.pokja3: return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4: return const Color(0xFFEF4444);
    }
  }

  IconData _pokjaIcon(PokjaKategori p) {
    switch (p) { case PokjaKategori.pokja1: return Icons.groups_rounded; case PokjaKategori.pokja2: return Icons.school_rounded; case PokjaKategori.pokja3: return Icons.cottage_rounded; case PokjaKategori.pokja4: return Icons.health_and_safety_rounded; }
  }

  @override
  Widget build(BuildContext context) {
    // Sinkron dengan mode Gelap/Terang — gelap = bg gelap, terang = bg terang
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF3F5F7);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    const primaryMint = Color(0xFF2ED9C3);
    final primaryMintAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final borderColor = _isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final formattedDate = _getFormattedDate();
    final totalAntrean = _pendingBeritaCount + _pendingLaporanCount;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await Future.wait([_loadPendingCounts(), _loadWeather()]),
          color: primaryMintAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header tanpa ikon
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w500, color: textColor), children: [const TextSpan(text: 'Hey, '), TextSpan(text: 'Admin', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primaryMintAccent)), const TextSpan(text: '!')])),
                const SizedBox(height: 3),
                Text(formattedDate, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 20),

              // Banner
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2ED9C3), Color(0xFF1FBFA8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: primaryMint.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(15)), child: Stack(alignment: Alignment.center, children: const [Positioned(top: 7, right: 8, child: Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBBF24), size: 18)), Positioned(bottom: 6, left: 7, child: Icon(Icons.cloud_rounded, color: Colors.white, size: 24))])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_weatherCondition, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF0D3E38), fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Plus Jakarta Sans')), const SizedBox(height: 2), Text(_weatherCity, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF0D3E38), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans'))])),
                    const SizedBox(width: 12),
                    Text('$_weatherTemp°', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0D3E38), fontWeight: FontWeight.w900, fontSize: 32, height: 1)),
                  ]),
                  const SizedBox(height: 18),
                  LayoutBuilder(builder: (context, constraints) {
                    // Prevent overflow on narrow screens — wrap stats
                    return Row(children: [
                      Expanded(child: _buildWeatherStat(label: 'Terasa', value: '$_weatherFeelsLike°')),
                      _buildBannerDivider(),
                      Expanded(child: _buildWeatherStat(label: 'Kelembapan', value: '$_weatherHumidity%')),
                      _buildBannerDivider(),
                      Expanded(child: _buildWeatherStat(label: 'Antrean', value: _loadingCount ? '...' : '$totalAntrean Verif')),
                      _buildBannerDivider(),
                      Expanded(child: _buildWeatherStat(label: 'Status', value: 'Admin Aktif')),
                    ]);
                  }),
                ]),
              ),
              const SizedBox(height: 16),

              // 2 TILE VERIFIKASI — Berita & Laporan Pokja 1-4
              Row(children: [
                Expanded(child: _buildMainFeatureTile(title: 'Verifikasi Berita', subtitle: _loadingCount ? 'Memuat...' : '$_pendingBeritaCount Menunggu', icon: Icons.article_rounded, badgeText: 'Moderasi', isMintTheme: true, primaryColor: primaryMintAccent, cardBg: cardBg, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiBeritaScreen())); _loadPendingCounts(); }, onTapAction: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiBeritaScreen())); _loadPendingCounts(); }, actionLabel: 'Buka')),
                const SizedBox(width: 14),
                Expanded(child: _buildMainFeatureTile(title: 'Verifikasi Laporan', subtitle: _loadingCount ? 'Memuat...' : '$_pendingLaporanCount Laporan Pokja', icon: Icons.assignment_turned_in_rounded, badgeText: 'Pokja 1-4', isMintTheme: false, primaryColor: primaryMintAccent, cardBg: cardBg, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiLaporanScreen())); _loadPendingCounts(); }, onTapAction: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiLaporanScreen())); _loadPendingCounts(); }, actionLabel: 'Buka')),
              ]),
              const SizedBox(height: 12),

              // Rincian Pokja 1-4 — sinkron realtime
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: primaryMintAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.dashboard_rounded, size: 14, color: primaryMintAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Rincian Antrean Pokja', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: textColor))),
                    const SizedBox(width: 8),
                    if (!_loadingCount && _pendingLaporanCount > 0)
                      Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFCD34D))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFFB45309)), const SizedBox(width: 4), Flexible(child: Text('$_pendingLaporanCount Menunggu', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309))))]))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    for (final p in PokjaKategori.values)
                      Expanded(child: Padding(padding: EdgeInsets.only(right: p == PokjaKategori.pokja4 ? 0 : 8), child: _pokjaMiniCard(p, _pokjaPending[p] ?? 0, _loadingCount, borderColor))),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),

              Text('MENU ADMIN', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: subtextColor)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaFormScreen(isAdminMode: true))),
                borderRadius: BorderRadius.circular(16),
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primaryMintAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.add_photo_alternate_rounded, size: 20, color: primaryMintAccent)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Input Berita Baru', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)), const SizedBox(height: 2), Text('Tambah berita langsung dari panel admin', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: subtextColor))])), Icon(Icons.chevron_right_rounded, size: 20, color: subtextColor.withValues(alpha: 0.6))])),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _pokjaMiniCard(PokjaKategori p, int count, bool loading, Color border) {
    final c = _pokjaColor(p);
    final has = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(color: has ? c.withValues(alpha: 0.10) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: has ? c.withValues(alpha: 0.18) : border)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: has ? c.withValues(alpha: 0.15) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: has ? Colors.transparent : border)), child: Icon(_pokjaIcon(p), size: 14, color: c)),
        const SizedBox(height: 6),
        FittedBox(fit: BoxFit.scaleDown, child: Text(p.shortLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
        const SizedBox(height: 2),
        Text(loading ? '...' : '$count', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: has ? c : const Color(0xFF94A3B8))),
        Text('Antrean', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF94A3B8))),
      ]),
    );
  }

  Widget _buildWeatherStat({required String label, required String value}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0D3E38), fontWeight: FontWeight.w800, fontSize: 13.5))), const SizedBox(height: 1), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0D3E38).withValues(alpha: 0.75), fontSize: 11, fontWeight: FontWeight.w600))]);
  Widget _buildBannerDivider() => Container(width: 1, height: 26, color: Colors.black.withValues(alpha: 0.1));

  Widget _buildMainFeatureTile({required String title, required String subtitle, required IconData icon, required String badgeText, required bool isMintTheme, required Color primaryColor, required Color cardBg, required Color textColor, required Color subtextColor, required Color borderColor, required VoidCallback onTap, required VoidCallback onTapAction, required String actionLabel}) {
    final activeBg = isMintTheme ? primaryColor.withValues(alpha: 0.12) : cardBg;
    final activeBorder = isMintTheme ? primaryColor.withValues(alpha: 0.6) : borderColor;
    return Container(
      height: 195,
      decoration: BoxDecoration(color: activeBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: activeBorder, width: 1.2), boxShadow: isMintTheme ? [BoxShadow(color: primaryColor.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMintTheme ? primaryColor.withValues(alpha: 0.25) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: isMintTheme ? primaryColor : const Color(0xFF334155), size: 22)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: isMintTheme ? primaryColor.withValues(alpha: 0.2) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)), child: Text(badgeText, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: isMintTheme ? primaryColor : const Color(0xFF475569))))]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: textColor, fontWeight: FontWeight.w700, fontSize: 14.5, height: 1.2)), const SizedBox(height: 3), Text(subtitle, style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w500))]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('BUKA', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: isMintTheme ? primaryColor : const Color(0xFF94A3B8), letterSpacing: 0.5)), InkWell(onTap: onTapAction, borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isMintTheme ? primaryColor : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)), child: Text(actionLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: isMintTheme ? Colors.white : const Color(0xFF1E293B)))))])
      ])))),
    );
  }
}
