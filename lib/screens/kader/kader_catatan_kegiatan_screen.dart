// lib/screens/kader/kader_catatan_kegiatan_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../catatan_kegiatan_form_screen.dart';

class KaderCatatanKegiatanScreen extends StatefulWidget {
  final PokjaKategori? pokjaDefault;

  const KaderCatatanKegiatanScreen({super.key, this.pokjaDefault});

  @override
  State<KaderCatatanKegiatanScreen> createState() => _KaderCatatanKegiatanScreenState();
}

class _KaderCatatanKegiatanScreenState extends State<KaderCatatanKegiatanScreen> {
  final _service = CatatanKegiatanService();
  PokjaKategori? _selectedFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.pokjaDefault;
  }

  Color _getPokjaColor(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return const Color(0xFF2563EB); // Royal Blue
      case PokjaKategori.pokja2:
        return const Color(0xFF059669); // Emerald
      case PokjaKategori.pokja3:
        return const Color(0xFFD97706); // Amber
      case PokjaKategori.pokja4:
        return const Color(0xFFDC2626); // Rose
    }
  }

  void _openForm({CatatanKegiatan? catatan, PokjaKategori? pokjaAwal}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatatanKegiatanFormScreen(
          catatan: catatan,
          pokjaAwal: pokjaAwal ?? _selectedFilter,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Catatan Kegiatan Pokja',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<List<CatatanKegiatan>>(
        future: _service.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D9488)),
            );
          }
          final allList = snapshot.data ?? [];
          final filteredList = allList.where((item) {
            if (_selectedFilter != null && item.kategori != _selectedFilter) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final matchJudul = item.judul.toLowerCase().contains(q);
              final matchDesa = (item.desa ?? '').toLowerCase().contains(q);
              final matchKec = item.kecamatan.toLowerCase().contains(q);
              return matchJudul || matchDesa || matchKec;
            }
            return true;
          }).toList();

          return Column(
        children: [
          // Filter Pokja Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Cari kegiatan, desa, atau kecamatan...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Pokja Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(null, 'Semua Pokja'),
                      const SizedBox(width: 8),
                      _buildFilterChip(PokjaKategori.pokja1, 'Pokja I'),
                      const SizedBox(width: 8),
                      _buildFilterChip(PokjaKategori.pokja2, 'Pokja II'),
                      const SizedBox(width: 8),
                      _buildFilterChip(PokjaKategori.pokja3, 'Pokja III'),
                      const SizedBox(width: 8),
                      _buildFilterChip(PokjaKategori.pokja4, 'Pokja IV'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // List Data
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final color = _getPokjaColor(item.kategori);

                      return InkWell(
                        onTap: () => _openForm(catatan: item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.kategori.label,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.judul,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.deskripsiSingkat,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${item.desa ?? '-'}, Kec. ${item.kecamatan}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFCBD5E1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(pokjaAwal: _selectedFilter ?? PokjaKategori.pokja1),
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Input Kegiatan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(PokjaKategori? pokja, String label) {
    final isSelected = _selectedFilter == pokja;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = pokja),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF64748B),
      ),
      selectedColor: const Color(0xFF0D9488),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined, size: 48, color: Color(0xFF0D9488)),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Catatan Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan tombol "Input Kegiatan" di bawah untuk melaporkan kegiatan pokja.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
