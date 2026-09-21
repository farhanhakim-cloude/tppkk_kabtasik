import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../services/data_keluarga_dasawisma_service.dart';
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
    HapticFeedback.selectionClick();
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataKeluargaDasawismaFormScreen(data: item)),
    );
    if (res == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D9488);
    const bg = Color(0xFFF8FAFC);

    final content = Column(
      children: [
        // Header bar with Tambah Data action
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.holiday_village_rounded, color: Color(0xFF0D9488), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data & Kegiatan Warga',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Format Rekap Dasawisma (30 Kolom)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                label: Text('Tambah Data', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Search pill
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Cari kepala RT, Dasa Wisma, desa...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                        onPressed: () { _searchController.clear(); _reload(); },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
        ),

        Expanded(
          child: FutureBuilder<List<DataKeluargaDasawisma>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: primary));
              }
              if (snapshot.hasError) {
                return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Gagal memuat: ${snapshot.error}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFDC2626)))));
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(color: const Color(0xFF0D9488).withValues(alpha: 0.08), shape: BoxShape.circle),
                        child: const Icon(Icons.home_work_outlined, size: 52, color: Color(0xFF0D9488)),
                      ),
                      const SizedBox(height: 16),
                      Text('Belum ada data Dasawisma', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      Text('Mulai catat Dasa Wisma, RT/RW dan anggota keluarga', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.4)),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        label: Text('Input Dasawisma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11)),
                      ),
                    ]),
                  ),
                );
              }

              // Summary bar
              final totalAnggota = list.fold<int>(0, (p, e) => p + e.anggotaList.length);
              final sehat = list.where((e) => e.kriteriaRumah == 'Sehat').length;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _MetricChip(icon: Icons.holiday_village_rounded, label: '${list.length} Dasawisma', color: primary, bg: const Color(0xFFECFDF5)),
                        const SizedBox(width: 8),
                        _MetricChip(icon: Icons.people_alt_rounded, label: '$totalAnggota Anggota', color: const Color(0xFF2563EB), bg: const Color(0xFFEFF6FF)),
                        const SizedBox(width: 8),
                        _MetricChip(icon: Icons.verified_rounded, label: '$sehat Rumah Sehat', color: const Color(0xFF059669), bg: const Color(0xFFECFDF5)),
                      ]),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  Expanded(
                    child: Container(
                      color: bg,
                      child: RefreshIndicator(
                        onRefresh: () async => _reload(),
                        color: primary,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _DasawismaCard(item: list[index], onTap: () => _openForm(item: list[index]), primary: primary),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
                ),
              ),
              title: Text('Data Dasawisma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17, color: const Color(0xFF0F172A))),
              actions: [IconButton(icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)), onPressed: _reload)],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_dasawisma_input',
        onPressed: () => _openForm(),
        backgroundColor: primary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text('Tambah Data Warga', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5)),
      ),
      body: content,
    );
  }
}

class _DasawismaCard extends StatelessWidget {
  final DataKeluargaDasawisma item;
  final VoidCallback onTap;
  final Color primary;
  const _DasawismaCard({required this.item, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isSehat = item.kriteriaRumah == 'Sehat';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () { HapticFeedback.selectionClick(); onTap(); },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.home_work_rounded, color: primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.namaKepalaRumahTangga.isNotEmpty ? item.namaKepalaRumahTangga : 'Tanpa nama KR', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14.5, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text('Dasa Wisma ${item.dasaWisma} • RT ${item.rt}/RW ${item.rw} • ${item.desa}, ${item.kecamatan}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B))),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: (isSehat ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isSehat ? Icons.verified_rounded : Icons.warning_rounded, size: 12, color: isSehat ? const Color(0xFF059669) : const Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text(item.kriteriaRumah, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: isSehat ? const Color(0xFF059669) : const Color(0xFFB45309))),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _Chip(text: '${item.anggotaList.length} Anggota • ${item.jumlahLakiLaki}L/${item.jumlahPerempuan}P', color: primary, bg: const Color(0xFFECFDF5)),
                _Chip(text: '${item.jumlahBalita} Balita • ${item.jumlahLansia} Lansia', color: const Color(0xFF0284C7), bg: const Color(0xFFF0F9FF)),
                _Chip(text: 'MCK: ${item.jumlahMckSepticTank} • ${item.sumberAir}', color: const Color(0xFF7C3AED), bg: const Color(0xFFF5F3FF)),
                if (item.aktifitasUp2k) _Chip(text: 'UP2K ${item.jenisUsahaUp2k}', color: const Color(0xFFDB2777), bg: const Color(0xFFFFF1F2)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _MetricChip({required this.icon, required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.18))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: color), const SizedBox(width: 5), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: color))]),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Chip({required this.text, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );
}
