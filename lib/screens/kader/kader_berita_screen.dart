// lib/screens/kader/kader_berita_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/berita.dart';
import '../../services/berita_service.dart';
import '../../widgets/skeleton.dart';
import '../berita_form_screen.dart';

class KaderBeritaScreen extends StatefulWidget {
  const KaderBeritaScreen({super.key});

  @override
  State<KaderBeritaScreen> createState() => _KaderBeritaScreenState();
}

class _KaderBeritaScreenState extends State<KaderBeritaScreen> {
  final _service = BeritaService();
  bool _isLoading = false;
  List<Berita> _myNews = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMyBerita();
  }

  Future<void> _fetchMyBerita() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final list = await _service.getMyBerita();
      setState(() {
        _myNews = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openTulisBerita({Berita? berita}) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BeritaFormScreen(berita: berita),
      ),
    );
    if (res == true || res != null) {
      _fetchMyBerita();
    }
  }

  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    switch (s) {
      case 'published':
      case 'disetujui':
        return const Color(0xFF1B7A4D); // Green
      case 'pending':
      case 'menunggu':
        return const Color(0xFF92600A); // Amber
      case 'rejected':
      case 'ditolak':
        return const Color(0xFFB42318); // Red
      default:
        return const Color(0xFF5B6B7C); // Slate
    }
  }

  String _getStatusLabel(String? status) {
    final s = (status ?? '').toLowerCase();
    switch (s) {
      case 'published':
      case 'disetujui':
        return 'Diterbitkan';
      case 'pending':
      case 'menunggu':
        return 'Menunggu Verifikasi';
      case 'rejected':
      case 'ditolak':
        return 'Perlu Revisi';
      default:
        return status ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Berita & Kabar Kader',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A2B3C),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF5B6B7C)),
            onPressed: _fetchMyBerita,
          ),
        ],
      ),
      body: _isLoading
          // Skeleton dinas selaras Dasawisma (tanpa spinner).
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              physics: NeverScrollableScrollPhysics(),
              child: SkeletonList(count: 4),
            )
          : _errorMessage.isNotEmpty && _myNews.isEmpty
              ? _buildErrorState()
              : _myNews.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchMyBerita,
                      color: const Color(0xFF0072BC),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myNews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _myNews[index];
                          final statusColor = _getStatusColor(item.status);
                          final statusLabel = _getStatusLabel(item.status);

                          return InkWell(
                            onTap: () {
                              if ((item.status ?? '').toLowerCase() == 'pending') {
                                _openTulisBerita(berita: item);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE1E7EE)),
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
                                            CircleAvatar(radius: 3, backgroundColor: statusColor),
                                            const SizedBox(width: 5),
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
                                      const Spacer(),
                                      Text(
                                        item.tanggal,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A2B3C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.ringkasan,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: const Color(0xFF5B6B7C),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.tag_rounded, size: 14, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.kategori ?? 'Berita',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0072BC),
                                        ),
                                      ),
                                      const Spacer(),
                                      if ((item.status ?? '').toLowerCase() == 'pending')
                                        Text(
                                          'Ketuk untuk edit',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0072BC),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-kader-berita',
        onPressed: () => _openTulisBerita(),
        backgroundColor: const Color(0xFF0072BC),
        elevation: 0,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: Text(
          'Tulis Berita',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0072BC).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.newspaper_rounded, size: 48, color: Color(0xFF0072BC)),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Berita yang Ditulis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2B3C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kader dapat mempublikasikan kegiatan PKK di wilayahnya dengan menekan tombol "Tulis Berita".',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5B6B7C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFB42318)),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Berita',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2B3C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Periksa koneksi internet Anda atau coba lagi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5B6B7C),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMyBerita,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0072BC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
