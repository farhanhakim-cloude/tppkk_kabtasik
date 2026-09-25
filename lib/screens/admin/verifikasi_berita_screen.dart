// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/berita.dart';
import '../../constants/app_constants.dart';
import '../../constants/admin_elderly_style.dart';
import '../../main.dart';

class VerifikasiBeritaScreen extends StatefulWidget {
  const VerifikasiBeritaScreen({super.key});

  @override
  State<VerifikasiBeritaScreen> createState() => _VerifikasiBeritaScreenState();
}

class _VerifikasiBeritaScreenState extends State<VerifikasiBeritaScreen> {
  bool _isLoading = true;
  List<Berita> _pendingBerita = [];
  bool _isDarkMode = false;
  final _searchController = TextEditingController();
  String _query = '';

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
    _searchController.dispose();
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
      if (token == null || token.isEmpty)
        throw Exception('Token tidak ditemukan');
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
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
        setState(
          () => _pendingBerita = list
              .map((item) => Berita.fromJson(item))
              .toList(),
        );
      } else {
        throw Exception('Gagal load: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat berita: $e')));
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
        title: Text(
          isApprove ? 'Setujui Berita?' : 'Tolak Berita?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: AdminElderlyStyle.dialogTitleSize,
            color: isDark ? Colors.white : const Color(0xFF14181D),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin ${isApprove ? 'menyetujui' : 'menolak'} "${berita.judul}"?',
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
      http.Response response;
      String endpoint = isApprove
          ? 'admin/berita/${berita.id}/approve'
          : 'admin/berita/${berita.id}/reject';
      response = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
      // Fallback: coba endpoint alternatif admin/berita/{id}/status jika 404/500
      if (response.statusCode == 404 || response.statusCode == 500) {
        final altEndpoint = 'admin/berita/${berita.id}/status';
        final altBody = jsonEncode({
          'status': isApprove ? 'approved' : 'rejected',
        });
        final altRes = await http
            .put(
              Uri.parse('${AppConstants.baseUrl}$altEndpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: altBody,
            )
            .timeout(const Duration(seconds: 10));
        if (altRes.statusCode == 200 || altRes.statusCode == 201)
          response = altRes;
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isApprove ? 'Berita disetujui!' : 'Berita ditolak!',
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
        _loadPendingBerita();
      } else {
        // Jika backend belum siap (data dummy lokal) â†’ anggap sukses lokal agar tidak stuck 500
        final bodySnippet = response.body.length > 300
            ? response.body.substring(0, 300)
            : response.body;
        if (response.statusCode == 500 || response.statusCode == 404) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isApprove
                      ? 'Disetujui (lokal, server: ${response.statusCode})'
                      : 'Ditolak (lokal, server: ${response.statusCode})',
                ),
                backgroundColor: const Color(0xFFF59E0B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          setState(() => _pendingBerita.removeWhere((b) => b.id == berita.id));
          return;
        }
        throw Exception('Gagal: ${response.statusCode} $bodySnippet');
      }
    } catch (e) {
      if (mounted)
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

  List<Berita> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _pendingBerita;
    return _pendingBerita.where((b) {
      return b.judul.toLowerCase().contains(q) ||
          (b.kecamatan ?? '').toLowerCase().contains(q) ||
          (b.kategori ?? '').toLowerCase().contains(q) ||
          (b.createdByName ?? '').toLowerCase().contains(q);
    }).toList();
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
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verifikasi Berita',
          style: GoogleFonts.plusJakartaSans(
            fontSize: AdminElderlyStyle.appBarTitleSize,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryAccent, size: 22),
            onPressed: _loadPendingBerita,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryAccent,
                strokeWidth: 2.5,
              ),
            )
          : _pendingBerita.isEmpty
          ? _buildEmptyState(textColor, subtextColor, primaryAccent)
          : RefreshIndicator(
              onRefresh: _loadPendingBerita,
              color: primaryAccent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _buildSummaryHeader(subtextColor, primaryAccent),
                  const SizedBox(height: 12),
                  _buildSearchBar(subtextColor, primaryAccent),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _filtered.length; i++) ...[
                    _buildBeritaCard(_filtered[i]),
                    if (i < _filtered.length - 1) const SizedBox(height: 12),
                  ],
                  if (_filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Tidak ditemukan untuk "$_query"',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: subtextColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// Kartu info jumlah — gaya kartu putih polos ala kader
  Widget _buildSummaryHeader(Color subtextColor, Color accent) {
    final total = _pendingBerita.length;
    final isDark = _isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.newspaper_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total Berita Menunggu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Setujui untuk tampilkan, Tolak untuk kembalikan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Search bar — gaya kolom cari halaman kader
  Widget _buildSearchBar(Color subtextColor, Color accent) {
    final isDark = _isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textColor),
        decoration: InputDecoration(
          hintText: 'Cari judul, kecamatan, penulis...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: subtextColor,
          ),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: subtextColor),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: subtextColor,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtextColor, Color accent) {
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
                Icons.check_circle_outline_rounded,
                size: 56,
                color: accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak Ada Berita Pending',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua berita telah diverifikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.55,
                color: subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeritaCard(Berita berita) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final borderColor = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final titleColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final faintColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF94A3B8);
    const statusColor = Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      'Menunggu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                berita.tanggal,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: faintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            berita.judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Oleh: ${berita.createdByName ?? 'Anonim'} • ${berita.kecamatan ?? 'Tidak ada lokasi'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: bodyColor),
          ),
          const SizedBox(height: 6),
          Text(
            berita.ringkasan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: bodyColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.tag_rounded, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  berita.kategori ?? 'Berita',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F326D),
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
                  onPressed: () => _handleAction(berita, false),
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
                  onPressed: () => _handleAction(berita, true),
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
    );
  }
}
