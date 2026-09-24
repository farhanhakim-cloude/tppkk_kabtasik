// lib/screens/kader/kader_catatan_kegiatan_screen.dart

// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart';
import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../catatan_kegiatan_form_screen.dart';

class KaderCatatanKegiatanScreen extends StatefulWidget {
  final PokjaKategori? pokjaDefault;

  const KaderCatatanKegiatanScreen({super.key, this.pokjaDefault});

  @override
  State<KaderCatatanKegiatanScreen> createState() =>
      _KaderCatatanKegiatanScreenState();
}

class _KaderCatatanKegiatanScreenState extends State<KaderCatatanKegiatanScreen>
    with SingleTickerProviderStateMixin {
  final _service = CatatanKegiatanService();
  PokjaKategori? _selectedFilter;
  PokjaKategori? _restrictedPokja;
  String _searchQuery = '';
  bool _isDarkMode = false;
  late AnimationController _fabAnim;
  late Future<List<CatatanKegiatan>> _future;

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.pokjaDefault;
    _future = _service.getAll();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadTheme();
    _loadRoleRestriction();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  Future<void> _loadRoleRestriction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_data');
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final roles = data['roles'] is List ? List<dynamic>.from(data['roles']) : const [];
      final username = (data['username'] ?? '').toString().toLowerCase();
      final role = (data['role'] ??
              (roles.isNotEmpty ? roles.first : '') ??
              (username.startsWith('pokja') ? username : ''))
          .toString()
          .toLowerCase();
      final index = int.tryParse(role.replaceFirst('pokja', ''));
      if (index == null || index < 1 || index > 4) return;

      final pokja = PokjaKategori.values[index - 1];
      if (!mounted) return;
      setState(() {
        _restrictedPokja = pokja;
        _selectedFilter = pokja;
      });
    } catch (_) {}
  }

  // ✅ FIX: _reload jadi Future<void>, sinkron di dalam setState
  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _future = _service.getAll();
    });
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _fabAnim.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark =
          prefs.getBool('kader_dark_mode') ??
          prefs.getBool('isDarkMode') ??
          (themeNotifier.value == ThemeMode.dark);
      if (mounted && _isDarkMode != isDark) {
        setState(() => _isDarkMode = isDark);
      }
      if (themeNotifier.value != (isDark ? ThemeMode.dark : ThemeMode.light)) {
        themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (_) {}
  }

  // ============================================================
  // FIX: switch mencakup semua 7 nilai PokjaKategori
  // ============================================================
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

  IconData _getPokjaIcon(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return Icons.groups_rounded;
      case PokjaKategori.pokja2:
        return Icons.school_rounded;
      case PokjaKategori.pokja3:
        return Icons.cottage_rounded;
      case PokjaKategori.pokja4:
        return Icons.health_and_safety_rounded;
      case PokjaKategori.pokja4Pyd:
        return Icons.child_friendly_rounded;
      case PokjaKategori.pokja4Posyandu:
        return Icons.local_hospital_rounded;
      case PokjaKategori.pokja4Rekap:
        return Icons.assignment_rounded;
    }
  }

  // ✅ FIX: _openForm jadi Future<void>
  Future<void> _openForm({
    CatatanKegiatan? catatan,
    PokjaKategori? pokjaAwal,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatatanKegiatanFormScreen(
          catatan: catatan,
          pokjaAwal: pokjaAwal ?? _selectedFilter,
        ),
      ),
    );
    if (!mounted) return;
    await _reload();
  }

  List<PokjaKategori> _availablePokjas() {
    if (_restrictedPokja == null) return PokjaKategori.values;
    if (_restrictedPokja == PokjaKategori.pokja4) {
      return const [
        PokjaKategori.pokja4,
        PokjaKategori.pokja4Pyd,
        PokjaKategori.pokja4Posyandu,
        PokjaKategori.pokja4Rekap,
      ];
    }
    return [_restrictedPokja!];
  }

  void _showFilterSheet() {
    final sheetBg = Colors.white;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Saring catatan berdasarkan kategori',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      if (_restrictedPokja == null) ...[
                        _buildFilterSheetItem(
                          null,
                          'Semua Pokja',
                          'Tampilkan semua kategori',
                          Icons.apps_rounded,
                          const Color(0xFF0D9488),
                          ctx,
                        ),
                        const SizedBox(height: 8),
                      ],
                      ..._availablePokjas().map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildFilterSheetItem(
                                  p,
                                  p.label,
                                  _pokjaSubtitle(p),
                                  _getPokjaIcon(p),
                                  _getPokjaColor(p),
                                  ctx,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _restrictedPokja == null ? () {
                      setState(() => _selectedFilter = null);
                      Navigator.pop(ctx);
                    } : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Reset filter',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSheetItem(
    PokjaKategori? pokja,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    BuildContext sheetCtx,
  ) {
    final isSel = _selectedFilter == pokja;
    return Material(
      color: isSel ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() => _selectedFilter = pokja);
          Navigator.pop(sheetCtx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? color.withValues(alpha: 0.22) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSel ? color.withValues(alpha: 0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(icon, size: 18, color: color),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSel)
                Icon(Icons.check_circle_rounded, size: 20, color: color)
              else
                const Icon(
                  Icons.circle_outlined,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _pokjaSubtitle(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return 'Gotong Royong & Pembinaan Karakter';
      case PokjaKategori.pokja2:
        return 'Pendidikan & Ekonomi Keluarga';
      case PokjaKategori.pokja3:
        return 'Pangan, Sandang & Papan';
      case PokjaKategori.pokja4:
        return 'Kesehatan & Lingkungan';
      case PokjaKategori.pokja4Pyd:
        return 'Data Kunjungan PYD per Bulan';
      case PokjaKategori.pokja4Posyandu:
        return 'Data Kegiatan Posyandu per Bulan';
      case PokjaKategori.pokja4Rekap:
        return 'Rekap Ibu Hamil, Melahirkan & Nifas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode
        ? const Color(0xFF14181F)
        : const Color(0xFFF3F5F7);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final primaryAccent = _isDarkMode
        ? const Color(0xFF2ED9C3)
        : const Color(0xFF0D9488);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode
        ? const Color(0xFF8E9BAE)
        : const Color(0xFF64748B);
    final borderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final searchBg = _isDarkMode
        ? const Color(0xFF252B36)
        : const Color(0xFFF1F5F9);
    final appBarBg = _isDarkMode ? const Color(0xFF1A1F28) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _isDarkMode ? Colors.white : const Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Catatan Kegiatan Pokja',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryAccent, size: 22),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: appBarBg,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: searchBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari kegiatan, desa, kecamatan…',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: subtextColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: subtextColor,
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: _selectedFilter == null ? cardBg : primaryAccent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _showFilterSheet,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedFilter == null
                              ? borderColor
                              : primaryAccent,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: _selectedFilter == null
                                ? subtextColor
                                : Colors.white,
                          ),
                          if (_selectedFilter != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedFilter != null || _searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              color: appBarBg,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  if (_selectedFilter != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPokjaColor(
                          _selectedFilter!,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPokjaIcon(_selectedFilter!),
                            size: 12,
                            color: _getPokjaColor(_selectedFilter!),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedFilter!.shortLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _getPokjaColor(_selectedFilter!),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _selectedFilter = null),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _getPokjaColor(_selectedFilter!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedFilter != null && _searchQuery.isNotEmpty)
                    const SizedBox(width: 8),
                  if (_searchQuery.isNotEmpty)
                    Expanded(
                      child: Text(
                        'Pencarian: "$_searchQuery"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: subtextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Divider(height: 1, color: borderColor),
          Expanded(
            child: FutureBuilder<List<CatatanKegiatan>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryAccent,
                      strokeWidth: 2.5,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 44,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Gagal memuat',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _reload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Coba lagi',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final allList = snapshot.data ?? [];
                final filteredList = allList.where((item) {
                  if (_selectedFilter != null &&
                      item.kategori != _selectedFilter) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    return item.judul.toLowerCase().contains(q) ||
                        (item.desa ?? '').toLowerCase().contains(q) ||
                        item.kecamatan.toLowerCase().contains(q) ||
                        item.deskripsiSingkat.toLowerCase().contains(q);
                  }
                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  if (allList.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: subtextColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tidak ada hasil filter',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Coba ubah filter Pokja atau kata kunci pencarian.\nTotal dimuat: ${allList.length}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => setState(() {
                                _selectedFilter = null;
                                _searchQuery = '';
                              }),
                              child: const Text('Reset filter'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildEmptyState(
                    primaryAccent,
                    textColor,
                    subtextColor,
                  );
                }
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: cardBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '${filteredList.length} kegiatan dimuat • ${allList.length} total • ketuk untuk lihat/edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subtextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: borderColor),
                    Expanded(
                      child: RefreshIndicator(
                        // ✅ FIX: onRefresh langsung panggil _reload (Future<void>)
                        onRefresh: _reload,
                        color: primaryAccent,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            try {
                              return _buildCatatanCard(
                                filteredList[index],
                                cardBg,
                                textColor,
                                subtextColor,
                                borderColor,
                                primaryAccent,
                              );
                            } catch (e) {
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  'Error render: $e\nData: ${filteredList[index].toJson()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          onPressed: () =>
              _openForm(pokjaAwal: _selectedFilter ?? PokjaKategori.pokja1),
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            'Input Kegiatan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatatanCard(
    CatatanKegiatan item,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    Color accentColor,
  ) {
    final color = _getPokjaColor(item.kategori);
    final isApproved = item.status == StatusKegiatan.dibaca;
    final statusLabel = isApproved ? 'Disetujui' : 'Menunggu Verifikasi';
    final statusColor = isApproved
        ? const Color(0xFF10B981)
        : const Color(0xFFD97706);
    final statusBg = isApproved
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF7ED);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openForm(catatan: item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.judul.isNotEmpty ? item.judul : 'Tanpa judul #${item.id}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
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
                  fontSize: 13,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.tag_rounded, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    item.kategori.shortLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ketuk untuk edit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    Color accentColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 52,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Catatan Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol "Input Kegiatan" di bawah\nuntuk melaporkan kegiatan pokja.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: subtextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
