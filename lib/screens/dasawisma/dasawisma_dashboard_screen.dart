// ignore_for_file: unused_local_variable, unused_element
// lib/screens/dasawisma/dasawisma_dashboard_screen.dart
// Dashboard Dasawisma — selaras dengan Admin & Kader (cuaca + API)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart';
import '../../services/data_keluarga_dasawisma_service.dart';
import '../../services/kriteria_rumah_service.dart';
import '../../services/keluarga_service.dart';
import '../../services/dasawisma_catatan_keluarga_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/pemanfaatan_tanah_service.dart';
import '../../services/industri_rumah_tangga_service.dart';
import '../../services/rekap_ibu_anak_service.dart';
import '../../widgets/weather_card.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'kriteria_rumah_list_screen.dart';
import 'keluarga_list_screen.dart';
import 'catatan_keluarga_list_screen.dart';
import 'kegiatan_warga_list_screen.dart';
import 'pemanfaatan_tanah_list_screen.dart';
import 'industri_rumah_tangga_list_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'data_umum_dasawisma_screen.dart';
import '../profile_screen.dart';

class DasawismaDashboardScreen extends StatefulWidget {
  const DasawismaDashboardScreen({super.key});

  @override
  State<DasawismaDashboardScreen> createState() => _DasawismaDashboardScreenState();
}

class _DasawismaDashboardScreenState extends State<DasawismaDashboardScreen> {
  String _userName = 'Dasawisma';
  String _desaKecamatan = 'Kab. Tasikmalaya';
  bool _isDarkMode = false;
  int _navIndex = 0;
  int _weatherVersion = 0;

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
      final raw = prefs.getString('user_data') ?? prefs.getString('user') ?? '{}';
      final data = jsonDecode(raw);
      setState(() {
        _userName = data['name'] ?? data['nama'] ?? 'Dasawisma';
        final desa = data['desa'] ?? data['kelurahan'] ?? '';
        final kec = data['kecamatan'] ?? prefs.getString('default_kecamatan') ?? 'Tasikmalaya';
        _desaKecamatan = desa.isNotEmpty ? '$desa, $kec' : 'Kec. $kec';
      });
    } catch (_) {}
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}, ${now.year}';
  }

  Future<void> _onRefresh() async {
    setState(() => _weatherVersion++);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF3F5F7);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final sub = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final text = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    const primaryMint = Color(0xFF2ED9C3);
    final primaryAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);

    final pages = [
      _buildBeranda(bg, cardBg, border, sub, text, primaryAccent, primaryMint),
      const DataKeluargaDasawismaListScreen(embedded: false),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, 'Beranda', _navIndex, primaryAccent, sub),
              _navItem(1, Icons.groups_rounded, 'Binaan', _navIndex, primaryAccent, sub),
              _navItem(2, Icons.person_rounded, 'Profil', _navIndex, primaryAccent, sub),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label, int cur, Color primary, Color sub) {
    final sel = cur == idx;
    return Expanded(
      child: InkWell(
        onTap: () { HapticFeedback.selectionClick(); setState(() => _navIndex = idx); },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(color: sel ? primary.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 22, color: sel ? primary : const Color(0xFF94A3B8)),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, color: sel ? primary : sub)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBeranda(Color bg, Color cardBg, Color border, Color sub, Color text, Color primaryAccent, Color primaryMint) {
    final formattedDate = _getFormattedDate();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header selaras Admin/Kader: Hey, Dasawisma! + tanggal
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w500, color: text),
                  children: [
                    const TextSpan(text: 'Hey, '),
                    TextSpan(text: _userName.split(' ').first, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primaryAccent)),
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF0D9488)),
                const SizedBox(width: 4),
                Expanded(child: Text(_desaKecamatan, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: sub, fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Text(formattedDate, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: sub.withValues(alpha: 0.9))),
              ]),
            ]),
            const SizedBox(height: 16),

            // Cuaca via API — selaras dengan Admin/Kader (pakai WeatherCard + WeatherService Open-Meteo)
            WeatherCard(key: ValueKey(_weatherVersion)),
            const SizedBox(height: 16),

            // Rincian Data Dasawisma — card gini saja (seperti Rincian Antrean Pokja Image 2)
            FutureBuilder(
              future: Future.wait([
                DataKeluargaDasawismaService().getAll(),
                KriteriaRumahService().getAll(),
                KeluargaService().getAll(),
                DasawismaCatatanKeluargaService().getAll(),
                KegiatanWargaService().getAll(),
                PemanfaatanTanahService().getAll(),
                IndustriRumahTanggaService().getAll(),
                RekapIbuAnakService().getAll(),
              ]),
              builder: (c, snap) {
                final das = (snap.data?[0] as List?)?.length ?? 0;
                final rumah = (snap.data?[1] as List?)?.length ?? 0;
                final kel = (snap.data?[2] as List?)?.length ?? 0;
                final cat = (snap.data?[3] as List?)?.length ?? 0;
                final keg = (snap.data?[4] as List?)?.length ?? 0;
                final tanah = (snap.data?[5] as List?)?.length ?? 0;
                final industri = (snap.data?[6] as List?)?.length ?? 0;
                final ibu = (snap.data?[7] as List?)?.length ?? 0;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: primaryAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.dashboard_rounded, size: 14, color: primaryAccent)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Rincian Data Dasawisma', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: text))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _dasawismaMiniCard(icon: Icons.groups_rounded, color: const Color(0xFF38BDF8), label: 'Binaan', count: das, sublabel: 'Data')),
                      const SizedBox(width: 8),
                      Expanded(child: _dasawismaMiniCard(icon: Icons.family_restroom_rounded, color: const Color(0xFF10B981), label: 'Keluarga', count: kel, sublabel: 'KK')),
                      const SizedBox(width: 8),
                      Expanded(child: _dasawismaMiniCard(icon: Icons.diversity_3_rounded, color: const Color(0xFFF59E0B), label: 'Kegiatan', count: keg, sublabel: 'Warga')),
                      const SizedBox(width: 8),
                      Expanded(child: _dasawismaMiniCard(icon: Icons.grass_rounded, color: const Color(0xFF059669), label: 'Tanah', count: tanah, sublabel: 'Pekarangan')),
                    ]),
                  ]),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2 Fitur utama — selaras Kader/Admin (MainFeatureTile)
            FutureBuilder(
              future: Future.wait([DataKeluargaDasawismaService().getAll(), RekapIbuAnakService().getAll()]),
              builder: (c, snap) {
                final das = (snap.data?[0] as List?)?.length ?? 0;
                final ibu = (snap.data?[1] as List?)?.length ?? 0;
                return Row(children: [
                  Expanded(child: _buildMainFeatureTile(title: 'Input Data Binaan', subtitle: '$das data binaan', icon: Icons.assignment_outlined, badgeText: '9 Fitur', isMintTheme: true, primaryColor: primaryAccent, cardBg: cardBg, textColor: text, subtextColor: sub, borderColor: border, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataKeluargaDasawismaListScreen())), onTapAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataKeluargaDasawismaListScreen())), actionLabel: '+ Input')),
                  const SizedBox(width: 14),
                  Expanded(child: _buildMainFeatureTile(title: 'Data Umum', subtitle: '$ibu ibu & kegiatan', icon: Icons.assignment_rounded, badgeText: '2 Form', isMintTheme: false, primaryColor: primaryAccent, cardBg: cardBg, textColor: text, subtextColor: sub, borderColor: border, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataUmumDasawismaScreen())), onTapAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataUmumDasawismaScreen())), actionLabel: 'Buka')),
                ]);
              },
            ),
            const SizedBox(height: 18),

            // Menu Dasawisma — grid 2 kolom selaras Kader (Akses Cepat)
            Text('MENU DASAWISMA • 9 FITUR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: sub)),
            const SizedBox(height: 10),
            _menuGrid(cardBg, border, text, sub),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _dasawismaMiniCard({required IconData icon, required Color color, required String label, required int count, String sublabel = 'Data'}) {
    final has = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(color: has ? color.withValues(alpha: 0.10) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: has ? color.withValues(alpha: 0.18) : const Color(0xFFE2E8F0))),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: has ? color.withValues(alpha: 0.15) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: has ? Colors.transparent : const Color(0xFFE2E8F0))), child: Icon(icon, size: 14, color: color)),
        const SizedBox(height: 6),
        FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
        const SizedBox(height: 2),
        Text('$count', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: has ? color : const Color(0xFF94A3B8))),
        Text(sublabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF94A3B8))),
      ]),
    );
  }

  Widget _weatherStat({required String label, required String value}) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0D3E38), fontWeight: FontWeight.w800, fontSize: 13.5)), const SizedBox(height: 1), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0D3E38).withValues(alpha: 0.75), fontSize: 11, fontWeight: FontWeight.w600))]));
  Widget _bannerDivider() => Container(width: 1, height: 26, color: Colors.black.withValues(alpha: 0.1));

  Widget _buildMainFeatureTile({required String title, required String subtitle, required IconData icon, required String badgeText, required bool isMintTheme, required Color primaryColor, required Color cardBg, required Color textColor, required Color subtextColor, required Color borderColor, required VoidCallback onTap, required VoidCallback onTapAction, required String actionLabel}) {
    final activeBg = isMintTheme ? primaryColor.withValues(alpha: 0.12) : cardBg;
    final activeBorder = isMintTheme ? primaryColor.withValues(alpha: 0.6) : borderColor;
    return Container(
      height: 168,
      decoration: BoxDecoration(color: activeBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: activeBorder, width: 1.2), boxShadow: isMintTheme ? [BoxShadow(color: primaryColor.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMintTheme ? primaryColor.withValues(alpha: 0.25) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: isMintTheme ? primaryColor : const Color(0xFF334155), size: 20)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: isMintTheme ? primaryColor.withValues(alpha: 0.2) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)), child: Text(badgeText, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: isMintTheme ? primaryColor : const Color(0xFF475569))))]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: textColor, fontWeight: FontWeight.w700, fontSize: 14)), const SizedBox(height: 2), Text(subtitle, style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w500))]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('BUKA', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: isMintTheme ? primaryColor : const Color(0xFF94A3B8), letterSpacing: 0.5)), InkWell(onTap: onTapAction, borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isMintTheme ? primaryColor : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)), child: Text(actionLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: isMintTheme ? Colors.white : const Color(0xFF1E293B)))))])
      ])))),
    );
  }

  Widget _menuGrid(Color cardBg, Color border, Color text, Color sub) {
    final items = [
      _GridItem('Keluarga Binaan', 'Data dasawisma & anggota', Icons.groups_rounded, const Color(0xFF10B981), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataKeluargaDasawismaListScreen()))),
      _GridItem('Kriteria Rumah', 'Sehat / tidak sehat', Icons.home_rounded, const Color(0xFFFF6B35), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KriteriaRumahListScreen()))),
      _GridItem('Data Keluarga', 'KK & anggota', Icons.family_restroom_rounded, const Color(0xFF3B82F6), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KeluargaListScreen()))),
      _GridItem('Catatan Keluarga', '19 kolom + 8 kegiatan', Icons.family_restroom_rounded, const Color(0xFFDC2626), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatanKeluargaListScreen()))),
      _GridItem('Kegiatan Warga', '7 kegiatan Y/T', Icons.diversity_3_rounded, const Color(0xFF0EA5E9), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KegiatanWargaListScreen()))),
      _GridItem('Pemanfaatan Tanah', 'TOGA & ternak', Icons.grass_rounded, const Color(0xFF059669), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PemanfaatanTanahListScreen()))),
      _GridItem('Industri RT', 'Pangan, sandang', Icons.storefront_rounded, const Color(0xFF7C3AED), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IndustriRumahTanggaListScreen()))),
      _GridItem('Rekap Ibu & Anak', 'Hamil & bayi', Icons.child_care_rounded, const Color(0xFFEC4899), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RekapIbuAnakListScreen()))),
      _GridItem('Data Umum', 'Data warga & bumil', Icons.assignment_rounded, const Color(0xFF0F766E), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataUmumDasawismaScreen()))),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.45),
      itemCount: items.length,
      itemBuilder: (c, i) {
        final it = items[i];
        return _menu(cardBg, border, text, sub, it.title, it.desc, it.icon, it.color, it.onTap);
      },
    );
  }

  Widget _menu(Color cardBg, Color border, Color text, Color sub, String title, String desc, IconData icon, Color color, VoidCallback tap) => InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5, color: text)), Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: sub))])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
          ]),
        ),
      );
}

class _GridItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _GridItem(this.title, this.desc, this.icon, this.color, this.onTap);
}
