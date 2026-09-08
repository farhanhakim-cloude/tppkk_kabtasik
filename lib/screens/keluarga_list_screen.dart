import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';
import 'keluarga_form_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'rekap_ibu_anak_form_screen.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'data_keluarga_dasawisma_form_screen.dart';

class KeluargaListScreen extends StatefulWidget {
  final bool embedded;
  const KeluargaListScreen({super.key, this.embedded = false});

  @override
  State<KeluargaListScreen> createState() => _KeluargaListScreenState();
}

class _KeluargaListScreenState extends State<KeluargaListScreen> {
  final _service = KeluargaService();
  final _searchController = TextEditingController();
  late Future<List<Keluarga>> _future;

  int _subTabIndex = 0; // 0 = Data Dasawisma, 1 = Daftar Warga (KK), 2 = Ibu & Anak

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

  Future<void> _openForm({Keluarga? keluarga}) async {
    if (_subTabIndex == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataKeluargaDasawismaFormScreen()),
      );
      if (result == true) _reload();
    } else if (_subTabIndex == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KeluargaFormScreen(keluarga: keluarga)),
      );
      if (result == true) _reload();
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RekapIbuAnakFormScreen()),
      );
      if (result == true) _reload();
    }
  }

  String get _appBarTitle {
    switch (_subTabIndex) {
      case 0:
        return 'Data Dasawisma';
      case 1:
        return 'Daftar Warga TP PKK';
      case 2:
        return 'Data Ibu & Anak Dasa Wisma';
      default:
        return 'Data Dasawisma';
    }
  }

  String get _fabLabel {
    switch (_subTabIndex) {
      case 0:
        return 'Catat Dasawisma';
      case 1:
        return 'Tambah Warga';
      case 2:
        return 'Catat Ibu & Anak';
      default:
        return 'Tambah Data';
    }
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
                _appBarTitle,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_data_main_3tabs',
        onPressed: () => _openForm(),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _fabLabel,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.embedded)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu Data PKK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── SEGMENTED 3-SUB-TAB TOGGLE ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildSubTabItem(0, 'Dasawisma', Icons.holiday_village_rounded, primary),
                _buildSubTabItem(1, 'Daftar Warga', Icons.badge_rounded, primary),
                _buildSubTabItem(2, 'Ibu & Anak', Icons.child_care_rounded, primary),
              ],
            ),
          ),

          // ── TAB CONTENT ──
          Expanded(
            child: IndexedStack(
              index: _subTabIndex,
              children: [
                // SUB-TAB 0: DATA KELUARGA DASAWISMA
                const DataKeluargaDasawismaListScreen(embedded: true),

                // SUB-TAB 1: DAFTAR WARGA (KK) 20 POIN
                Column(
                  children: [
                    // Search Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari nama warga / kepala keluarga...',
                          hintStyle:
                              GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => _reload(),
                      ),
                    ),

                    // List of Warga
                    Expanded(
                      child: FutureBuilder<List<Keluarga>>(
                        future: _future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Gagal memuat data: ${snapshot.error}',
                                  style: GoogleFonts.plusJakartaSans()),
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
                                  Text('Belum ada data warga',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final k = list[index];
                              final hasLocation = k.latitude != null && k.longitude != null;
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
                                  onTap: () => _openForm(keluarga: k),
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
                                              child: Icon(Icons.person_rounded, color: primary),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    k.namaKepalaKeluarga,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${k.alamat} • RT ${k.rt}/RW ${k.rw}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
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
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            _Chip(text: 'NIK/KK: ${k.noKtpKk.isNotEmpty ? k.noKtpKk : "-"}', color: primary),
                                            _Chip(text: 'Pekerjaan: ${k.pekerjaan}', color: Colors.grey[700]!),
                                            if (hasLocation)
                                              _Chip(
                                                text: '📍 Ada Titik Peta',
                                                color: const Color(0xFF059669),
                                              ),
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

                // SUB-TAB 2: REKAP IBU & ANAK DASA WISMA
                const RekapIbuAnakListScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem(int index, String title, IconData icon, Color primary) {
    final isSelected = _subTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? primary : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? primary : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
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
