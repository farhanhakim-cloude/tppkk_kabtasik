import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/data_keluarga_dasawisma.dart';
import '../services/data_keluarga_dasawisma_service.dart';
import 'data_keluarga_dasawisma_form_screen.dart';

class DataKeluargaDasawismaListScreen extends StatefulWidget {
  final bool embedded;
  const DataKeluargaDasawismaListScreen({super.key, this.embedded = false});

  @override
  State<DataKeluargaDasawismaListScreen> createState() => _DataKeluargaDasawismaListScreenState();
}

class _DataKeluargaDasawismaListScreenState extends State<DataKeluargaDasawismaListScreen> {
  final _service = DataKeluargaDasawismaService();
  final _searchController = TextEditingController();
  late Future<List<DataKeluargaDasawisma>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(query: _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({DataKeluargaDasawisma? item}) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataKeluargaDasawismaFormScreen(data: item)),
    );
    if (res == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(
                'Data Keluarga (Dasawisma)',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_dasawisma_main',
        onPressed: () => _openForm(),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Catat Dasawisma',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari kepala rumah tangga, Dasa Wisma, RT/RW...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _reload(),
            ),
          ),

          // List Data
          Expanded(
            child: FutureBuilder<List<DataKeluargaDasawisma>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: ${snapshot.error}', style: GoogleFonts.plusJakartaSans()),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_outlined, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Belum ada data Keluarga Dasawisma', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
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
                        onTap: () => _openForm(item: item),
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
                                      color: primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.holiday_village_rounded, color: primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.namaKepalaRumahTangga,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Dasa Wisma ${item.dasaWisma} • RT ${item.rt}/RW ${item.rw} • ${item.desa}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _Chip(text: '👨‍👩‍👧‍👦 ${item.anggotaList.length} Anggota (${item.jumlahLakiLaki}L / ${item.jumlahPerempuan}P)', color: primary),
                                  _Chip(text: '👶 ${item.jumlahBalita} Balita', color: const Color(0xFF0284C7)),
                                  _Chip(text: '🏠 Rumah ${item.kriteriaRumah}', color: item.kriteriaRumah == 'Sehat' ? const Color(0xFF10B981) : Colors.amber[800]!),
                                  if (item.aktifitasUp2k)
                                    _Chip(text: '💼 UP2K: ${item.jenisUsahaUp2k}', color: const Color(0xFF8B5CF6)),
                                ],
                              ),
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

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
