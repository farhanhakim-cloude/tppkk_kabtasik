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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
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
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _SummaryCard(label: 'Total Keluarga', value: '${data.totalKeluarga}', icon: Icons.home_rounded, color: const Color(0xFF0F9E8E)),
                  _SummaryCard(label: 'Total Anggota', value: '${data.totalAnggota}', icon: Icons.people_rounded, color: const Color(0xFF3F51B5)),
                  _SummaryCard(label: 'Ibu Hamil', value: '${data.totalIbuHamil}', icon: Icons.pregnant_woman_rounded, color: const Color(0xFFE91E63)),
                  _SummaryCard(label: 'Ibu Menyusui', value: '${data.totalIbuMenyusui}', icon: Icons.child_friendly_rounded, color: const Color(0xFFFF9800)),
                ],
              ),
              const SizedBox(height: 24),

              Text('Status Gizi Balita', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _BarRow(label: 'Normal', value: data.balitaGiziNormal, total: data.totalBalita, color: const Color(0xFF0F9E8E)),
                    const SizedBox(height: 16),
                    _BarRow(label: 'Kurang', value: data.balitaGiziKurang, total: data.totalBalita, color: const Color(0xFFFF9800)),
                    const SizedBox(height: 16),
                    _BarRow(label: 'Lebih', value: data.balitaGiziLebih, total: data.totalBalita, color: const Color(0xFFE53935)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _BarRow({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5)),
            Text('$value dari $total', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}