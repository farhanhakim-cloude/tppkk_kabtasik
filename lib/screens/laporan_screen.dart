import 'package:flutter/material.dart';
import '../models/kesehatan.dart';
import '../services/keluarga_service.dart';
import '../services/kesehatan_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _keluargaService = KeluargaService();
  final _kesehatanService = KesehatanService();

  String _periode = 'Agustus 2026';
  late Future<_LaporanData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_LaporanData> _loadData() async {
    final keluarga = await _keluargaService.getAll();
    final ibuHamil = await _kesehatanService.getAll(filter: KategoriKesehatan.ibuHamil);
    final ibuMenyusui = await _kesehatanService.getAll(filter: KategoriKesehatan.ibuMenyusui);
    final balita = await _kesehatanService.getAll(filter: KategoriKesehatan.balita);

    return _LaporanData(
      keluarga: keluarga.length,
      anggota: keluarga.fold(0, (sum, k) => sum + k.jumlahAnggota),
      ibuHamil: ibuHamil.length,
      ibuMenyusui: ibuMenyusui.length,
      balita: balita.length,
      balitaGiziKurang: balita.where((b) => b.statusGizi == 'Kurang').length,
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export PDF akan ditambahkan setelah backend siap')),
    );
    // NANTI: pakai package pdf + printing untuk generate & share file PDF
  }

  @override
  Widget build(BuildContext context) {
    final pink = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: FutureBuilder<_LaporanData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat laporan: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: _periode,
                decoration: const InputDecoration(labelText: 'Periode Laporan'),
                items: ['Juni 2026', 'Juli 2026', 'Agustus 2026']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _periode = v!),
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Bulanan TP PKK',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pink),
                      ),
                      Text('Periode: $_periode', style: TextStyle(color: Colors.grey[600])),
                      const Divider(height: 24),

                      _LaporanRow(label: 'Total Keluarga Tercatat', value: '${data.keluarga}'),
                      _LaporanRow(label: 'Total Anggota Keluarga', value: '${data.anggota}'),
                      const Divider(height: 24),

                      const Text('Kesehatan Ibu & Anak', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _LaporanRow(label: 'Ibu Hamil Terpantau', value: '${data.ibuHamil}'),
                      _LaporanRow(label: 'Ibu Menyusui Terpantau', value: '${data.ibuMenyusui}'),
                      _LaporanRow(label: 'Balita Terpantau', value: '${data.balita}'),
                      _LaporanRow(
                        label: 'Balita Gizi Kurang',
                        value: '${data.balitaGiziKurang}',
                        highlight: data.balitaGiziKurang > 0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export ke PDF'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LaporanData {
  final int keluarga;
  final int anggota;
  final int ibuHamil;
  final int ibuMenyusui;
  final int balita;
  final int balitaGiziKurang;

  _LaporanData({
    required this.keluarga,
    required this.anggota,
    required this.ibuHamil,
    required this.ibuMenyusui,
    required this.balita,
    required this.balitaGiziKurang,
  });
}

class _LaporanRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _LaporanRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}