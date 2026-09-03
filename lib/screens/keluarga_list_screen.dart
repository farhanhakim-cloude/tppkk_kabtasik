import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';
import 'keluarga_form_screen.dart';

class KeluargaListScreen extends StatefulWidget {
  const KeluargaListScreen({super.key});

  @override
  State<KeluargaListScreen> createState() => _KeluargaListScreenState();
}

class _KeluargaListScreenState extends State<KeluargaListScreen> {
  final _service = KeluargaService();
  final _searchController = TextEditingController();
  late Future<List<Keluarga>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAll();
  }

  void _reload() {
    setState(() => _future = _service.getAll(query: _searchController.text));
  }

  Future<void> _openForm({Keluarga? keluarga}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeluargaFormScreen(keluarga: keluarga)),
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Data Keluarga', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari nama kepala keluarga...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Keluarga>>(
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
                        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Belum ada data', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final k = list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openForm(keluarga: k),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.home_rounded, color: primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      k.namaKepalaKeluarga,
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      k.alamat,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        _Chip(text: 'RT ${k.rt}/RW ${k.rw}', color: primary),
                                        _Chip(text: '${k.jumlahAnggota} anggota', color: Colors.grey[500]!),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}