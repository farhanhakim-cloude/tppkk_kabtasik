// lib/screens/kriteria_rumah_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kriteria_rumah.dart';
import '../services/kriteria_rumah_service.dart';
import 'kriteria_rumah_form_screen.dart';

class KriteriaRumahListScreen extends StatefulWidget {
  final bool embedded;
  const KriteriaRumahListScreen({super.key, this.embedded = false});

  @override
  State<KriteriaRumahListScreen> createState() => _KriteriaRumahListScreenState();
}

class _KriteriaRumahListScreenState extends State<KriteriaRumahListScreen> {
  final _service = KriteriaRumahService();
  final _searchCtrl = TextEditingController();
  late Future<List<KriteriaRumah>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(query: _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({KriteriaRumah? existing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KriteriaRumahFormScreen(existing: existing),
      ),
    );
    if (result == true) _reload();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Layak Huni':
        return const Color(0xFF059669);
      case 'Tidak Layak Huni':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Layak Huni':
        return Icons.check_circle_rounded;
      case 'Tidak Layak Huni':
        return Icons.cancel_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(
                'Kriteria Rumah',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
      floatingActionButton: widget.embedded
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab_kriteria_rumah',
              onPressed: () => _openForm(),
              backgroundColor: primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Nilai Rumah',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              onChanged: (_) => _reload(),
              decoration: InputDecoration(
                hintText: 'Cari nama KK / dasa wisma / desa...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _reload();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<KriteriaRumah>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat data: ${snapshot.error}',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                  );
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.home_work_rounded, size: 48, color: primary.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data penilaian rumah',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap tombol + untuk mulai menilai',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        if (widget.embedded) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _openForm(),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: Text(
                              'Nilai Rumah Baru',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final item = list[i];
                    final statusColor = _statusColor(item.statusRumah);
                    final statusIcon = _statusIcon(item.statusRumah);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openForm(existing: item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.home_work_rounded, color: statusColor, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.namaKepalaKeluarga,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'RT ${item.rt}/RW ${item.rw} • ${item.desa}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, size: 13, color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.statusRumah,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Skor bars
                              Row(
                                children: [
                                  Expanded(
                                    child: _ScoreBar(
                                      label: 'Skor Layak',
                                      score: item.skorLayakHuni,
                                      max: 10,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ScoreBar(
                                      label: 'Indikator Masalah',
                                      score: item.jumlahTidakLayak,
                                      max: 8,
                                      color: const Color(0xFFDC2626),
                                      isWarning: true,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.dasaWisma.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.holiday_village_rounded, size: 13, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dasa Wisma: ${item.dasaWisma}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.tanggalPenilaian,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Bar Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final int max;
  final Color color;
  final bool isWarning;

  const _ScoreBar({
    required this.label,
    required this.score,
    required this.max,
    required this.color,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? score / max : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$score/$max',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
