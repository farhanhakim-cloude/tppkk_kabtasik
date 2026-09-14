import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/berita.dart';
import '../../constants/app_constants.dart';

class VerifikasiBeritaScreen extends StatefulWidget {
  const VerifikasiBeritaScreen({super.key});

  @override
  State<VerifikasiBeritaScreen> createState() => _VerifikasiBeritaScreenState();
}

class _VerifikasiBeritaScreenState extends State<VerifikasiBeritaScreen> {
  bool _isLoading = true;
  List<Berita> _pendingBerita = [];

  @override
  void initState() {
    super.initState();
    _loadPendingBerita();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // ============================================================
  // 🔥 LOAD PENDING BERITA DARI ENDPOINT KHUSUS
  // ============================================================
  Future<void> _loadPendingBerita() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔍 PENDING BERITA [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawData = data['data'];

        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          list = rawData['data'] as List;
        }

        setState(() {
          _pendingBerita = list.map((item) => Berita.fromJson(item)).toList();
        });
      } else {
        throw Exception('Gagal load: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error load pending berita: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat berita: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // 🔥 APPROVE / REJECT BERITA
  // ============================================================
  Future<void> _handleAction(Berita berita, bool isApprove) async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Setujui Berita?' : 'Tolak Berita?'),
        content: Text(
          'Apakah Anda yakin ingin ${isApprove ? 'menyetujui' : 'menolak'} "${berita.judul}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(isApprove ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      // 🔥 Endpoint approve/reject
      final endpoint = isApprove
          ? 'admin/berita/${berita.id}/approve'
          : 'admin/berita/${berita.id}/reject';

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 APPROVE RESPONSE [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove ? 'Berita disetujui!' : 'Berita ditolak!'),
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
          );
        }
        _loadPendingBerita();
      } else {
        throw Exception('Gagal: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error approve berita: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Verifikasi Berita',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingBerita.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPendingBerita,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingBerita.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildBeritaCard(_pendingBerita[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Berita Pending',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua berita telah diverifikasi.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaCard(Berita berita) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Menunggu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
                Text(
                  berita.tanggal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              berita.judul,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Oleh: ${berita.createdByName ?? 'Anonim'} - ${berita.kecamatan ?? 'Tidak ada lokasi'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              berita.ringkasan,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAction(berita, false),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction(berita, true),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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