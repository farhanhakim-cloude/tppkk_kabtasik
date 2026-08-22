import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      SnackBar(content: Text('Export PDF akan ditambahkan setelah backend siap', style: GoogleFonts.plusJakartaSans())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Laporan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_LaporanData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat laporan: ${snapshot.error}', style: GoogleFonts.plusJakartaSans()));
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DropdownButtonFormField<String>(
                  value: _periode,
                  decoration: InputDecoration(
                    labelText: 'Periode Laporan',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
                  items: ['Juni 2026', 'Juli 2026', 'Agustus 2026']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _periode = v!),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.description_rounded, color: primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Laporan Bulanan TP PKK', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                              Text('Periode: $_periode', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    _LaporanRow(label: 'Total Keluarga Tercatat', value: '${data.keluarga}'),
                    _LaporanRow(label: 'Total Anggota Keluarga', value: '${data.anggota}'),
                    const Divider(height: 28),

                    Text('Kesehatan Ibu & Anak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(height: 10),
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
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                  label: Text('Export ke PDF', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: Colors.grey[700])),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: highlight ? const Color(0xFFE53935) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}