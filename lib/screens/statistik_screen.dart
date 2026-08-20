import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Statistik')),
      body: FutureBuilder<_StatistikData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat statistik: ${snapshot.error}'));
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
                  _SummaryCard(label: 'Total Keluarga', value: '${data.totalKeluarga}', icon: Icons.home),
                  _SummaryCard(label: 'Total Anggota', value: '${data.totalAnggota}', icon: Icons.people),
                  _SummaryCard(label: 'Ibu Hamil', value: '${data.totalIbuHamil}', icon: Icons.pregnant_woman),
                  _SummaryCard(label: 'Ibu Menyusui', value: '${data.totalIbuMenyusui}', icon: Icons.child_friendly),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Status Gizi Balita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _BarRow(label: 'Normal', value: data.balitaGiziNormal, total: data.totalBalita, color: Colors.green),
                      const SizedBox(height: 12),
                      _BarRow(label: 'Kurang', value: data.balitaGiziKurang, total: data.totalBalita, color: Colors.orange),
                      const SizedBox(height: 12),
                      _BarRow(label: 'Lebih', value: data.balitaGiziLebih, total: data.totalBalita, color: Colors.red),
                    ],
                  ),
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

  const _SummaryCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final pink = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: pink, size: 24),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$value dari $total'),
          ],
        ),
        const SizedBox(height: 6),
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