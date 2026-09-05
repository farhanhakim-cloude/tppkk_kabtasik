import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kesehatan.dart';
import '../services/kesehatan_service.dart';
import 'kesehatan_form_screen.dart';

class KesehatanListScreen extends StatefulWidget {
  final bool embedded;
  const KesehatanListScreen({super.key, this.embedded = false});

  @override
  State<KesehatanListScreen> createState() => _KesehatanListScreenState();
}

class _KesehatanListScreenState extends State<KesehatanListScreen>
    with SingleTickerProviderStateMixin {
  final _service = KesehatanService();
  final _searchController = TextEditingController();

  late TabController _tabController;
  late Future<List<DataKesehatan>> _future;

  // Single unified Blue color theme
  static const Color _primaryBlue = Color(0xFF0D9488);

  final _kategoriList = [
    KategoriKesehatan.ibuHamil,
    KategoriKesehatan.ibuMenyusui,
    KategoriKesehatan.balita,
    KategoriKesehatan.anak,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _reload();
    });
    _future = _service.getAll(filter: _kategoriList[0]);
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(filter: _kategoriList[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({DataKesehatan? data}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KesehatanFormScreen(
          data: data,
          kategoriAwal: _kategoriList[_tabController.index],
        ),
      ),
    );
    if (result == true) _reload();
  }

  IconData _getCategoryIcon(KategoriKesehatan kat) {
    switch (kat) {
      case KategoriKesehatan.ibuHamil:
        return Icons.pregnant_woman_rounded;
      case KategoriKesehatan.ibuMenyusui:
        return Icons.water_drop_rounded;
      case KategoriKesehatan.balita:
        return Icons.child_care_rounded;
      case KategoriKesehatan.anak:
        return Icons.face_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentKategori = _kategoriList[_tabController.index];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text('Kesehatan Ibu & Anak (KIA)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openForm(),
        backgroundColor: _primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Catat ${currentKategori.label}',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── HEADER HERO ──
          if (widget.embedded)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kesehatan Ibu & Anak',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pemantauan tumbuh kembang & posyandu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari nama ibu, anak, atau RT/RW...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, size: 20, color: _primaryBlue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // ── UNIFIED BLUE CATEGORY PILLS ──
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.only(right: 8),
              tabs: _kategoriList.map((kat) {
                final isSelected = kat == currentKategori;
                return Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _primaryBlue : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: _primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(kat),
                          size: 16,
                          color: isSelected ? Colors.white : _primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          kat.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── LIST OF HEALTH DATA ──
          Expanded(
            child: FutureBuilder<List<DataKesehatan>>(
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

                var list = snapshot.data ?? [];
                final query = _searchController.text.toLowerCase().trim();
                if (query.isNotEmpty) {
                  list = list.where((d) {
                    return d.namaIbu.toLowerCase().contains(query) ||
                        d.namaAnak.toLowerCase().contains(query) ||
                        d.rt.contains(query) ||
                        d.rw.contains(query);
                  }).toList();
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getCategoryIcon(currentKategori),
                              size: 48, color: _primaryBlue.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Belum Ada Data ${currentKategori.label}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketuk tombol tambah untuk mencatat data baru',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final d = list[index];
                    final isChild = d.kategori == KategoriKesehatan.balita ||
                        d.kategori == KategoriKesehatan.anak;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _openForm(data: d),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar Icon (Unified Blue)
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1D4ED8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryBlue.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getCategoryIcon(d.kategori),
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            isChild ? d.namaAnak : d.namaIbu,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        if (isChild && d.statusGizi != '-')
                                          _StatusGiziBadge(status: d.statusGizi),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      isChild
                                          ? 'Ibu: ${d.namaIbu} • Usia: ${d.usiaKehamilanAtauAnak}'
                                          : 'Usia: ${d.usiaKehamilanAtauAnak}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'RT ${d.rt}/RW ${d.rw}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: _primaryBlue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            d.kategori.label,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: _primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded,
                                  color: Colors.grey[400], size: 20),
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

class _StatusGiziBadge extends StatelessWidget {
  final String status;
  const _StatusGiziBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
      ),
      child: Text(
        'Gizi $status',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}