import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kesehatan.dart';
import '../services/keluarga_service.dart';
import '../services/kesehatan_service.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  final _keluargaService = KeluargaService();
  final _kesehatanService = KesehatanService();

  late Future<_StatistikData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_StatistikData> _loadData() async {
    final keluarga = await _keluargaService.getAll();
    final ibuHamil = await _kesehatanService.getAll(filter: KategoriKesehatan.ibuHamil);
    final ibuMenyusui = await _kesehatanService.getAll(filter: KategoriKesehatan.ibuMenyusui);
    final balita = await _kesehatanService.getAll(filter: KategoriKesehatan.balita);

    final balitaGiziKurang = balita.where((b) => b.statusGizi == 'Kurang').length;
    final balitaGiziNormal = balita.where((b) => b.statusGizi == 'Normal').length;
    final balitaGiziLebih = balita.where((b) => b.statusGizi == 'Lebih').length;

    return _StatistikData(
      totalKeluarga: keluarga.length,
      totalAnggota: keluarga.fold(0, (sum, k) => sum + k.jumlahAnggota),
      totalIbuHamil: ibuHamil.length,
      totalIbuMenyusui: ibuMenyusui.length,
      totalBalita: balita.length,
      balitaGiziKurang: balitaGiziKurang,
      balitaGiziNormal: balitaGiziNormal,
      balitaGiziLebih: balitaGiziLebih,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Statistik', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_StatistikData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat statistik: ${snapshot.error}', style: GoogleFonts.plusJakartaSans()));
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ringkasan cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _SummaryCard(label: 'Total Keluarga', value: '${data.totalKeluarga}', icon: Icons.home_rounded, color: const Color(0xFF2563EB)),
                  _SummaryCard(label: 'Total Anggota', value: '${data.totalAnggota}', icon: Icons.people_rounded, color: const Color(0xFF3F51B5)),
                  _SummaryCard(label: 'Ibu Hamil', value: '${data.totalIbuHamil}', icon: Icons.pregnant_woman_rounded, color: const Color(0xFFE91E63)),
                  _SummaryCard(label: 'Ibu Menyusui', value: '${data.totalIbuMenyusui}', icon: Icons.child_friendly_rounded, color: const Color(0xFFFF9800)),
                ],
              ),
              const SizedBox(height: 28),

              // Donut chart status gizi balita
              Text('Status Gizi Balita', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Dari total ${data.totalBalita} balita terpantau', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[600])),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(120, 120),
                            painter: _DonutChartPainter(
                              segments: [
                                _Segment(data.balitaGiziNormal.toDouble(), const Color(0xFF0F9E8E)),
                                _Segment(data.balitaGiziKurang.toDouble(), const Color(0xFFFF9800)),
                                _Segment(data.balitaGiziLebih.toDouble(), const Color(0xFFE53935)),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${data.totalBalita}', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800)),
                              Text('balita', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendRow(label: 'Normal', value: data.balitaGiziNormal, total: data.totalBalita, color: const Color(0xFF0F9E8E)),
                          const SizedBox(height: 10),
                          _LegendRow(label: 'Kurang', value: data.balitaGiziKurang, total: data.totalBalita, color: const Color(0xFFFF9800)),
                          const SizedBox(height: 10),
                          _LegendRow(label: 'Lebih', value: data.balitaGiziLebih, total: data.totalBalita, color: const Color(0xFFE53935)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Perbandingan kategori — bar chart horizontal
              Text('Perbandingan Kategori', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _HorizontalBar(
                      label: 'Ibu Hamil',
                      value: data.totalIbuHamil,
                      maxValue: _maxOf(data),
                      color: const Color(0xFFE91E63),
                      icon: Icons.pregnant_woman_rounded,
                    ),
                    const SizedBox(height: 16),
                    _HorizontalBar(
                      label: 'Ibu Menyusui',
                      value: data.totalIbuMenyusui,
                      maxValue: _maxOf(data),
                      color: const Color(0xFFFF9800),
                      icon: Icons.child_friendly_rounded,
                    ),
                    const SizedBox(height: 16),
                    _HorizontalBar(
                      label: 'Balita',
                      value: data.totalBalita,
                      maxValue: _maxOf(data),
                      color: const Color(0xFF3F51B5),
                      icon: Icons.child_care_rounded,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _maxOf(_StatistikData d) {
    final values = [d.totalIbuHamil, d.totalIbuMenyusui, d.totalBalita];
    final maxV = values.reduce((a, b) => a > b ? a : b);
    return maxV == 0 ? 1 : maxV;
  }
}

class _StatistikData {
  final int totalKeluarga;
  final int totalAnggota;
  final int totalIbuHamil;
  final int totalIbuMenyusui;
  final int totalBalita;
  final int balitaGiziKurang;
  final int balitaGiziNormal;
  final int balitaGiziLebih;

  _StatistikData({
    required this.totalKeluarga,
    required this.totalAnggota,
    required this.totalIbuHamil,
    required this.totalIbuMenyusui,
    required this.totalBalita,
    required this.balitaGiziKurang,
    required this.balitaGiziNormal,
    required this.balitaGiziLebih,
  });
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _LegendRow({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final persen = total == 0 ? 0 : ((value / total) * 100).round();
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Text('($persen%)', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey[500])),
      ],
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final IconData icon;

  const _HorizontalBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0 ? 0.0 : value / maxValue;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Segment {
  final double value;
  final Color color;
  _Segment(this.value, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_Segment> segments;

  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const strokeWidth = 16.0;

    if (total == 0) {
      final paint = Paint()
        ..color = Colors.grey[200]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 2 * math.pi, false, paint);
      return;
    }

    double startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweepAngle = (segment.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}