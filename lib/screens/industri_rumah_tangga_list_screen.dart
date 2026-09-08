// lib/screens/industri_rumah_tangga_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/industri_rumah_tangga.dart';
import '../services/industri_rumah_tangga_service.dart';
import 'industri_rumah_tangga_form_screen.dart';

class IndustriRumahTanggaListScreen extends StatefulWidget {
  const IndustriRumahTanggaListScreen({super.key});

  @override
  State<IndustriRumahTanggaListScreen> createState() =>
      _IndustriRumahTanggaListScreenState();
}

class _IndustriRumahTanggaListScreenState
    extends State<IndustriRumahTanggaListScreen>
    with SingleTickerProviderStateMixin {
  final _service = IndustriRumahTanggaService();
  final _searchController = TextEditingController();
  List<IndustriRumahTangga> _data = [];
  bool _loading = true;
  String _query = '';

  static const Color _primary = Color(0xFF7C3AED);
  static const Color _primaryLight = Color(0xFFF5F3FF);

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.getAll(query: _query);
    if (mounted) {
      setState(() {
        _data = result;
        _loading = false;
      });
      _animController
        ..reset()
        ..forward();
    }
  }

  Future<void> _delete(IndustriRumahTangga d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Data?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Data industri atas nama ${d.namaKepalaKeluarga} akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.delete(d.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Industri Rumah Tangga',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Data komoditi & volume usaha',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const IndustriRumahTanggaFormScreen(),
            ),
          );
          if (result == true) _loadData();
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah Data',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ── SUMMARY BANNER ──
          FutureBuilder<Map<String, int>>(
            future: _service.getStatistik(),
            builder: (ctx, snap) {
              final total = snap.data?['total'] ?? 0;
              final totalKomoditi = snap.data?['totalKomoditi'] ?? 0;
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pelaku Usaha',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '$total Keluarga',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalKomoditi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Total Komoditi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  _query = v;
                  _loadData();
                },
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari nama, dasa wisma, komoditi...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF64748B), size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            _query = '';
                            _loadData();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── LIST ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _primary))
                : _data.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: _primary,
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: _data.length,
                          itemBuilder: (ctx, i) {
                            return _buildCard(_data[i], i);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(IndustriRumahTangga d, int index) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (ctx, child) {
        final delay = (index * 0.08).clamp(0.0, 0.6);
        final begin = delay;
        final end = (delay + 0.4).clamp(0.0, 1.0);
        final anim = CurvedAnimation(
          parent: _animController,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: _primaryLight,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        size: 18, color: _primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.namaKepalaKeluarga,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'RT ${d.rt}/RW ${d.rw} · ${d.dasaWisma.isEmpty ? "Dasa Wisma" : d.dasaWisma} · ${d.bulan} ${d.tahun}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                IndustriRumahTanggaFormScreen(data: d),
                          ),
                        );
                        if (result == true) _loadData();
                      } else if (v == 'delete') {
                        _delete(d);
                      } else if (v == 'detail') {
                        _showDetail(d);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_outlined,
                                size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Lihat Detail',
                                style: GoogleFonts.plusJakartaSans()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined,
                                size: 16, color: Color(0xFF7C3AED)),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF7C3AED))),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 16, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Text('Hapus',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.red[600])),
                          ],
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.more_vert_rounded,
                        size: 20, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),

            // Tabel Mini (max 3 baris ditampilkan)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header tabel mini
                  Container(
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            'No',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Kategori',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Komoditi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Volume',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Baris data (max 3)
                  ...List.generate(
                    d.items.take(3).length,
                    (i) {
                      final item = d.items[i];
                      final isEven = i % 2 == 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isEven
                              ? const Color(0xFFF8FAFC)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${i + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.kategori.isEmpty ? '-' : item.kategori,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF475569),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.komoditi.isEmpty ? '-' : item.komoditi,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.volume.isEmpty ? '-' : item.volume,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF475569),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Sisa baris jika lebih dari 3
                  if (d.items.length > 3) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showDetail(d),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: _primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+ ${d.items.length - 3} komoditi lainnya • Lihat Semua',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Footer Stats
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xFFEEF2FF))),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    '${d.totalKomoditi} komoditi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  if (d.catatan.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.notes_rounded,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        d.catatan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(IndustriRumahTangga d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetailSheet(data: d),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 48, color: _primary),
          ),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty
                ? 'Tidak ditemukan'
                : 'Belum ada data industri',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _query.isNotEmpty
                ? 'Coba kata kunci yang berbeda'
                : 'Tekan "Tambah Data" untuk menambahkan\ndata industri rumah tangga pertama',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── DETAIL BOTTOM SHEET ──
class _DetailSheet extends StatelessWidget {
  final IndustriRumahTangga data;
  const _DetailSheet({required this.data});

  static const Color _primary = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.namaKepalaKeluarga,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'RT ${data.rt}/RW ${data.rw} · ${data.dasaWisma} · ${data.bulan} ${data.tahun}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${data.totalKomoditi} Komoditi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Tabel Lengkap
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(16),
                children: [
                  // Header tabel
                  Container(
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text('No.',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Kategori',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Komoditi',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Volume',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...List.generate(data.items.length, (i) {
                    final item = data.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: i % 2 == 0
                            ? const Color(0xFFF8FAFC)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text('${i + 1}.',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _primary)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.kategori.isEmpty ? '-' : item.kategori,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: const Color(0xFF475569)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.komoditi.isEmpty ? '-' : item.komoditi,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.volume.isEmpty ? '-' : item.volume,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (data.catatan.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFDDD6FE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_rounded,
                              size: 16, color: _primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data.catatan,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
