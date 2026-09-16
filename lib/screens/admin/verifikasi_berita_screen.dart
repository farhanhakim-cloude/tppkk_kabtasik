import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/berita.dart';
import '../../constants/app_constants.dart';
import '../../main.dart';

class VerifikasiBeritaScreen extends StatefulWidget {
  const VerifikasiBeritaScreen({super.key});

  @override
  State<VerifikasiBeritaScreen> createState() => _VerifikasiBeritaScreenState();
}

class _VerifikasiBeritaScreenState extends State<VerifikasiBeritaScreen> {
  bool _isLoading = true;
  List<Berita> _pendingBerita = [];
  bool _isDarkMode = true;

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadPendingBerita();
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

  Future<void> _loadPendingBerita() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) throw Exception('Token tidak ditemukan');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawData = data['data'];
        List<dynamic> list = [];
        if (rawData is List) list = rawData;
        else if (rawData is Map && rawData['data'] is List) list = rawData['data'] as List;
        setState(() => _pendingBerita = list.map((item) => Berita.fromJson(item)).toList());
      } else {
        throw Exception('Gagal load: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat berita: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(Berita berita, bool isApprove) async {
    HapticFeedback.mediumImpact();
    final isDark = _isDarkMode;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E242D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isApprove ? 'Setujui Berita?' : 'Tolak Berita?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        content: Text('Apakah Anda yakin ingin ${isApprove ? 'menyetujui' : 'menolak'} "${berita.judul}"?', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: isDark ? Colors.white70 : const Color(0xFF475569), height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : const Color(0xFF64748B)))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(isApprove ? 'Setujui' : 'Tolak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) throw Exception('Token tidak ditemukan');
      final endpoint = isApprove ? 'admin/berita/${berita.id}/approve' : 'admin/berita/${berita.id}/reject';
      final response = await http.put(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isApprove ? 'Berita disetujui!' : 'Berita ditolak!'), backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        _loadPendingBerita();
      } else {
        throw Exception('Gagal: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF3F5F7);
    final appBarBg = _isDarkMode ? const Color(0xFF1A1F28) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final primaryAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text('Verifikasi Berita', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
        actions: [IconButton(icon: Icon(Icons.refresh_rounded, color: primaryAccent, size: 22), onPressed: _loadPendingBerita)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryAccent, strokeWidth: 2.5))
          : _pendingBerita.isEmpty
              ? _buildEmptyState(textColor, subtextColor, primaryAccent)
              : RefreshIndicator(
                  onRefresh: _loadPendingBerita,
                  color: primaryAccent,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _pendingBerita.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildBeritaCard(_pendingBerita[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtextColor, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.check_circle_outline_rounded, size: 56, color: accent)),
          const SizedBox(height: 16),
          Text('Tidak Ada Berita Pending', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 6),
          Text('Semua berita telah diverifikasi.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtextColor)),
        ]),
      ),
    );
  }

  Widget _buildBeritaCard(Berita berita) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final borderColor = _isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    const statusColor = Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: [_isDarkMode ? const BoxShadow(color: Colors.transparent) : BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: statusColor, shape: BoxShape.circle)), const SizedBox(width: 5), Text('Menunggu', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor))])),
            const Spacer(),
            Text(berita.tanggal, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor)),
          ]),
          const SizedBox(height: 10),
          Text(berita.judul, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 4),
          Text('Oleh: ${berita.createdByName ?? 'Anonim'} - ${berita.kecamatan ?? 'Tidak ada lokasi'}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor)),
          const SizedBox(height: 8),
          Text(berita.ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subtextColor, height: 1.4)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _handleAction(berita, false), icon: const Icon(Icons.close_rounded, size: 16), label: Text('Tolak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFEF4444), side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: () => _handleAction(berita, true), icon: const Icon(Icons.check_rounded, size: 16), label: Text('Setujui', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
          ]),
        ]),
      ),
    );
  }
}
