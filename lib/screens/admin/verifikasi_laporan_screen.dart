// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../../constants/app_constants.dart';
import '../../constants/admin_elderly_style.dart';
import '../../main.dart';

class VerifikasiLaporanScreen extends StatefulWidget {
  final PokjaKategori? pokjaDefault;
  const VerifikasiLaporanScreen({super.key, this.pokjaDefault});
  @override
  State<VerifikasiLaporanScreen> createState() =>
      _VerifikasiLaporanScreenState();
}

class _VerifikasiLaporanScreenState extends State<VerifikasiLaporanScreen> {
  bool _isLoading = true;
  List<CatatanKegiatan> _laporanList = [];
  String? _errorMessage;
  bool _isDarkMode = false;
  PokjaKategori? _filterPokja;
  String _searchQuery = '';

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    _filterPokja = widget.pokjaDefault;
    themeNotifier.addListener(_onThemeChanged);
    _loadLaporan();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> _loadLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty)
        throw Exception('Token tidak ditemukan. Silakan login ulang.');

      // FIX: endpoint 'admin/laporan-kegiatan'
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}admin/laporan-kegiatan'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawData = data['data'];
        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List)
          list = rawData['data'] as List;

        final pendingRaw = list.where((item) {
          final status = (item['status']?.toString() ?? '')
              .toLowerCase()
              .trim();
          final statusLabel = (item['status_label']?.toString() ?? '')
              .toLowerCase()
              .trim();
          return status == 'pending' ||
              status == 'menunggu' ||
              status == 'waiting' ||
              statusLabel.contains('menunggu') ||
              statusLabel.contains('pending');
        }).toList();

        setState(
          () => _laporanList = pendingRaw
              .map((item) => CatatanKegiatan.fromJson(item))
              .toList(),
        );
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat (${response.statusCode})');
      }
    } catch (e) {
      if (mounted)
        setState(
          () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(CatatanKegiatan laporan, bool isApprove) async {
    HapticFeedback.mediumImpact();
    final isDark = _isDarkMode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E242D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isApprove
                            ? const Color(0xFF0F326D)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isApprove
                    ? const Color(0xFF0F326D)
                    : const Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isApprove ? 'Setujui Laporan?' : 'Tolak Laporan?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AdminElderlyStyle.dialogTitleSize,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF14181D),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin ${isApprove ? 'menyetujui' : 'menolak'} "${laporan.judul}"?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: AdminElderlyStyle.dialogBodySize,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
            height: 1.55,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : const Color(0xFF475569),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove
                  ? const Color(0xFF0F326D)
                  : const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty)
        throw Exception('Token tidak ditemukan');

      // Coba beberapa endpoint (admin prefix & tanpa) agar kompatibel dengan backend manapun
      final endpoints = isApprove
          ? [
              'admin/laporan-kegiatan/${laporan.id}/approve',
              'laporan-kegiatan/${laporan.id}/approve',
              'admin/laporan-kegiatan/${laporan.id}/status',
            ]
          : [
              'admin/laporan-kegiatan/${laporan.id}/reject',
              'laporan-kegiatan/${laporan.id}/reject',
              'admin/laporan-kegiatan/${laporan.id}/status',
            ];

      http.Response? successRes;
      String lastBody = '';
      int lastCode = 0;
      for (final ep in endpoints) {
        try {
          final isStatusEp = ep.endsWith('/status');
          final res = await http
              .put(
                Uri.parse('${AppConstants.baseUrl}$ep'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: isStatusEp
                    ? jsonEncode({
                        'status': isApprove ? 'approved' : 'rejected',
                      })
                    : null,
              )
              .timeout(const Duration(seconds: 10));
          lastCode = res.statusCode;
          lastBody = res.body.length > 300
              ? res.body.substring(0, 300)
              : res.body;
          if (res.statusCode == 200 || res.statusCode == 201) {
            successRes = res;
            break;
          }
          if (res.statusCode != 404 && res.statusCode != 500) break;
        } catch (_) {
          continue;
        }
      }

      if (successRes != null) {
        // Update lokal agar kader lihat status Disetujui, tidak hilang
        try {
          await CatatanKegiatanService().updateStatus(
            laporan.id,
            isApprove ? StatusKegiatan.dibaca : StatusKegiatan.terkirim,
          );
        } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isApprove ? 'Laporan disetujui!' : 'Laporan ditolak!',
              ),
              backgroundColor: isApprove
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        _loadLaporan();
      } else {
        if (lastCode == 500 || lastCode == 404) {
          try {
            await CatatanKegiatanService().updateStatus(
              laporan.id,
              isApprove ? StatusKegiatan.dibaca : StatusKegiatan.terkirim,
            );
          } catch (_) {}
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isApprove
                      ? 'Disetujui (lokal, server: $lastCode)'
                      : 'Ditolak (lokal, server: $lastCode)',
                ),
                backgroundColor: const Color(0xFFF59E0B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          setState(() => _laporanList.removeWhere((e) => e.id == laporan.id));
          return;
        }
        throw Exception('Gagal ($lastCode) $lastBody');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8F9FB);
    final appBarBg = bgColor;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final primaryAccent = const Color(0xFF0F326D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verifikasi Laporan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: AdminElderlyStyle.appBarTitleSize,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            if (!_isLoading && _laporanList.isNotEmpty)
              Text(
                '${_laporanList.length} menunggu persetujuan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AdminElderlyStyle.appBarSubtitleSize,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadLaporan,
            icon: Icon(Icons.refresh_rounded, size: 22, color: primaryAccent),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  List<CatatanKegiatan> get _filteredList {
    final q = _searchQuery.trim().toLowerCase();
    return _laporanList.where((e) {
      if (_filterPokja != null && e.kategori != _filterPokja) return false;
      if (q.isNotEmpty) {
        return e.judul.toLowerCase().contains(q) ||
            e.kecamatan.toLowerCase().contains(q) ||
            (e.desa ?? '').toLowerCase().contains(q) ||
            e.deskripsiSingkat.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  // ============================================================
  // FIX: switch mencakup semua 7 nilai PokjaKategori
  // ============================================================
  Color _pokjaColor(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return const Color(0xFF38BDF8);
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

  Widget _buildFilterChips() {
    final chips = <Widget>[];
    final allCount = _laporanList.length;
    chips.add(_chip('Semua', null, allCount));
    for (final p in PokjaKategori.values) {
      final c = _laporanList.where((e) => e.kategori == p).length;
      chips.add(_chip(p.shortLabel, p, c));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: chips
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(right: 8), child: w),
            )
            .toList(),
      ),
    );
  }

  Widget _chip(String label, PokjaKategori? pokja, int count) {
    final selected = _filterPokja == pokja;
    final accent = pokja == null
        ? const Color(0xFF0F326D)
        : _pokjaColor(pokja);
    final bg = selected
        ? accent
        : (_isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.white);
    final fg = selected
        ? Colors.white
        : (_isDarkMode
              ? const Color(0xFF8E9BAE)
              : const Color(0xFF64748B));

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterPokja = pokja);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1.1,
            color: selected
                ? accent
                : (_isDarkMode
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AdminElderlyStyle.chipLabelSize,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : fg,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.22)
                    : accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AdminElderlyStyle.chipCountSize,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kolom cari — gaya halaman catatan kader
  Widget _buildSearchBar() {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final borderColor = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final hintColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Cari judul, desa, kecamatan...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: hintColor,
            ),
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: hintColor),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    color: hintColor,
                    onPressed: () => setState(() => _searchQuery = ''),
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
    );
  }

  Widget _buildBody() {
    final primaryAccent = const Color(0xFF0F326D);
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(
          color: primaryAccent,
          strokeWidth: 2.5,
        ),
      );
    if (_errorMessage != null) return _buildErrorState();
    if (_laporanList.isEmpty) return _buildEmptyState();
    final list = _filteredList;
    if (list.isEmpty) {
      return Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ditemukan untuk "$_searchQuery"'
                    : 'Tidak ada laporan ${_filterPokja?.shortLabel ?? ''}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _isDarkMode ? Colors.white60 : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadLaporan,
            color: primaryAccent,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildLaporanCard(list[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final primaryAccent = const Color(0xFF0F326D);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 50,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal Memuat Data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: subtextColor,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadLaporan,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: Text(
                  'Coba Lagi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final accent = const Color(0xFF0F326D);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                size: 56,
                color: accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Semua Laporan Selesai',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada laporan baru yang perlu diverifikasi saat ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: subtextColor,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard(CatatanKegiatan laporan) {
    // Gaya kartu disamakan dengan kartu catatan kader: putih polos,
    // pil status + judul + deskripsi + baris kategori, lalu tombol admin.
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final borderColor = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final titleColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final faintColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF94A3B8);
    final accent = _pokjaColor(laporan.kategori);
    const pendingBg = Color(0xFFFFF7ED);
    const pendingColor = Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? pendingColor.withValues(alpha: 0.15)
                        : pendingBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: pendingColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Menunggu Verifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: pendingColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${laporan.tanggal.day}/${laporan.tanggal.month}/${laporan.tanggal.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: faintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              laporan.judul.isNotEmpty ? laporan.judul : 'Tanpa judul',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              laporan.deskripsiSingkat.isNotEmpty
                  ? laporan.deskripsiSingkat
                  : 'Ketuk Setujui/Tolak untuk memverifikasi',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: bodyColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.tag_rounded, size: 14, color: accent),
                const SizedBox(width: 4),
                Text(
                  laporan.kategori.shortLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_on_outlined, size: 14, color: faintColor),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    laporan.kecamatan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: bodyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAction(laporan, false),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(
                      'Tolak',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(
                        color: Color(0xFFFCA5A5),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction(laporan, true),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      'Setujui',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F326D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
