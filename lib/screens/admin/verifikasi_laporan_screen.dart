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
import '../../main.dart';

class VerifikasiLaporanScreen extends StatefulWidget {
  final PokjaKategori? pokjaDefault;
  const VerifikasiLaporanScreen({super.key, this.pokjaDefault});
  @override State<VerifikasiLaporanScreen> createState() => _VerifikasiLaporanScreenState();
}

class _VerifikasiLaporanScreenState extends State<VerifikasiLaporanScreen> {
  bool _isLoading = true;
  List<CatatanKegiatan> _laporanList = [];
  String? _errorMessage;
  bool _isDarkMode = false;
  PokjaKategori? _filterPokja;

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
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) throw Exception('Token tidak ditemukan. Silakan login ulang.');

      // FIX: endpoint 'admin/laporan-kegiatan'
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/laporan-kegiatan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawData = data['data'];
        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List) list = rawData['data'] as List;

        final pendingRaw = list.where((item) {
          final status = (item['status']?.toString() ?? '').toLowerCase().trim();
          final statusLabel = (item['status_label']?.toString() ?? '').toLowerCase().trim();
          return status == 'pending' || status == 'menunggu' || status == 'waiting' ||
                 statusLabel.contains('menunggu') || statusLabel.contains('pending');
        }).toList();

        setState(() => _laporanList = pendingRaw.map((item) => CatatanKegiatan.fromJson(item)).toList());
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
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
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(
              isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 22
            )
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(
            isApprove ? 'Setujui Laporan?' : 'Tolak Laporan?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF14181D)
            )
          ))
        ]),
        content: Text(
          'Apakah Anda yakin ingin ${isApprove ? 'menyetujui' : 'menolak'} "${laporan.judul}"?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
            height: 1.5
          )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B)
            ))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)
            )
          )
        ],
      )
    );

    if (confirm != true) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) throw Exception('Token tidak ditemukan');

      // Coba beberapa endpoint (admin prefix & tanpa) agar kompatibel dengan backend manapun
      final endpoints = isApprove
          ? ['admin/laporan-kegiatan/${laporan.id}/approve', 'laporan-kegiatan/${laporan.id}/approve', 'admin/laporan-kegiatan/${laporan.id}/status']
          : ['admin/laporan-kegiatan/${laporan.id}/reject', 'laporan-kegiatan/${laporan.id}/reject', 'admin/laporan-kegiatan/${laporan.id}/status'];

      http.Response? successRes;
      String lastBody = '';
      int lastCode = 0;
      for (final ep in endpoints) {
        try {
          final isStatusEp = ep.endsWith('/status');
          final res = await http.put(
            Uri.parse('${AppConstants.baseUrl}$ep'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
            body: isStatusEp ? jsonEncode({'status': isApprove ? 'approved' : 'rejected'}) : null,
          ).timeout(const Duration(seconds: 10));
          lastCode = res.statusCode;
          lastBody = res.body.length > 300 ? res.body.substring(0, 300) : res.body;
          if (res.statusCode == 200 || res.statusCode == 201) { successRes = res; break; }
          if (res.statusCode != 404 && res.statusCode != 500) break;
        } catch (_) { continue; }
      }

      if (successRes != null) {
        // Update lokal agar kader lihat status Disetujui, tidak hilang
        try { await CatatanKegiatanService().updateStatus(laporan.id, isApprove ? StatusKegiatan.dibaca : StatusKegiatan.terkirim); } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isApprove ? 'Laporan disetujui!' : 'Laporan ditolak!'),
            backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ));
        }
        _loadLaporan();
      } else {
        if (lastCode == 500 || lastCode == 404) {
          try { await CatatanKegiatanService().updateStatus(laporan.id, isApprove ? StatusKegiatan.dibaca : StatusKegiatan.terkirim); } catch (_) {}
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isApprove ? 'Disetujui (lokal, server: $lastCode)' : 'Ditolak (lokal, server: $lastCode)'),
              backgroundColor: const Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ));
          }
          setState(() => _laporanList.removeWhere((e) => e.id == laporan.id));
          return;
        }
        throw Exception('Gagal ($lastCode) $lastBody');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF3F5F7);
    final appBarBg = _isDarkMode ? const Color(0xFF1A1F28) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final primaryAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context)
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Verifikasi Laporan', style: GoogleFonts.plusJakartaSans(
            fontSize: 17, fontWeight: FontWeight.w700, color: textColor
          )),
          if (!_isLoading && _laporanList.isNotEmpty)
            Text('${_laporanList.length} menunggu persetujuan', style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5, fontWeight: FontWeight.w500, color: subtextColor
            ))
        ]),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadLaporan,
            icon: Icon(Icons.refresh_rounded, size: 20, color: primaryAccent)
          )
        ]
      ),
      body: _buildBody(),
    );
  }

  List<CatatanKegiatan> get _filteredList {
    if (_filterPokja == null) return _laporanList;
    return _laporanList.where((e) => e.kategori == _filterPokja).toList();
  }

  // ============================================================
  // FIX: switch mencakup semua 7 nilai PokjaKategori
  // ============================================================
  Color _pokjaColor(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1: return const Color(0xFF38BDF8);
      case PokjaKategori.pokja2: return const Color(0xFF10B981);
      case PokjaKategori.pokja3: return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4: return const Color(0xFFEF4444);
      case PokjaKategori.pokja4Pyd: return const Color(0xFF8B5CF6);
      case PokjaKategori.pokja4Posyandu: return const Color(0xFF06B6D4);
      case PokjaKategori.pokja4Rekap: return const Color(0xFFEC4899);
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
      child: Row(children: chips.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList()),
    );
  }

  Widget _chip(String label, PokjaKategori? pokja, int count) {
    final selected = _filterPokja == pokja;
    final accent = pokja == null
        ? (_isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488))
        : _pokjaColor(pokja);
    final bg = selected ? accent : (_isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.white);
    final fg = selected ? Colors.white : (_isDarkMode ? Colors.white70 : const Color(0xFF475569));

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterPokja = pokja);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? accent
                  : (_isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)))
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: selected ? Colors.white : fg
          )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: 0.22) : accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text('$count', style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w800,
              color: selected ? Colors.white : accent
            ))
          )
        ]),
      ),
    );
  }

  Widget _buildBody() {
    final primaryAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);
    if (_isLoading) return Center(child: CircularProgressIndicator(color: primaryAccent, strokeWidth: 2.5));
    if (_errorMessage != null) return _buildErrorState();
    if (_laporanList.isEmpty) return _buildEmptyState();
    final list = _filteredList;
    if (list.isEmpty) {
      return Column(children: [
        _buildFilterChips(),
        Expanded(child: Center(child: Text(
          'Tidak ada laporan ${_filterPokja?.shortLabel ?? ''}',
          style: GoogleFonts.plusJakartaSans(
            color: _isDarkMode ? Colors.white60 : const Color(0xFF94A3B8)
          )
        )))
      ]);
    }
    return Column(children: [
      _buildFilterChips(),
      Expanded(child: RefreshIndicator(
        onRefresh: _loadLaporan,
        color: primaryAccent,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildLaporanCard(list[index])
        )
      ))
    ]);
  }

  Widget _buildErrorState() {
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final primaryAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);

    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
            shape: BoxShape.circle
          ),
          child: const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFEF4444))
        ),
        const SizedBox(height: 20),
        Text('Gagal Memuat Data', style: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: textColor
        )),
        const SizedBox(height: 8),
        Text(_errorMessage ?? 'Terjadi kesalahan',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtextColor, height: 1.5)
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadLaporan,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text('Coba Lagi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)
          )
        )
      ])
    ));
  }

  Widget _buildEmptyState() {
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final accent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);

    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.assignment_turned_in_rounded, size: 56, color: accent)
        ),
        const SizedBox(height: 20),
        Text('Semua Laporan Selesai', style: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: textColor
        )),
        const SizedBox(height: 8),
        Text('Tidak ada laporan baru yang perlu diverifikasi saat ini.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: subtextColor, height: 1.5)
        )
      ])
    ));
  }

  Widget _buildLaporanCard(CatatanKegiatan laporan) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final borderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final accent = _pokjaColor(laporan.kategori);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [_isDarkMode ? const BoxShadow(color: Colors.transparent) : BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2)
        )]
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(laporan.kategori.shortLabel, style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.3
                ))
              ])
            ),
            Text('${laporan.tanggal.day}/${laporan.tanggal.month}/${laporan.tanggal.year}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500)
            )
          ]),
          const SizedBox(height: 12),
          Text(laporan.judul, style: GoogleFonts.plusJakartaSans(
            fontSize: 16, fontWeight: FontWeight.w700, color: textColor, height: 1.3
          )),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: subtextColor),
            const SizedBox(width: 4),
            Expanded(child: Text('Kecamatan: ${laporan.kecamatan}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500)
            ))
          ]),
          const SizedBox(height: 10),
          Text(laporan.deskripsiSingkat, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtextColor, height: 1.5)
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _handleAction(laporan, false),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text('Tolak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13)
              )
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _handleAction(laporan, true),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text('Setujui', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13)
              )
            ))
          ])
        ])
      )
    );
  }
}
