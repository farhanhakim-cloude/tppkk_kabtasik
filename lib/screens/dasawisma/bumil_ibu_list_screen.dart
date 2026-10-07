import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/bumil_ibu.dart';
import '../../services/bumil_service.dart';
import 'bumil_ibu_form_screen.dart';

class BumilIbuListScreen extends StatefulWidget {
  final bool embedded;
  const BumilIbuListScreen({super.key, this.embedded = false});
  @override
  State<BumilIbuListScreen> createState() => _BumilIbuListScreenState();
}

class _BumilIbuListScreenState extends State<BumilIbuListScreen>
    with SingleTickerProviderStateMixin {
  final _service = BumilService();
  final _searchController = TextEditingController();
  List<BumilIbu> _data = [];
  BumilSummary _summary = BumilSummary();
  bool _loading = true;
  String? _error;
  String _query = '';
  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;
  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryLight = Color(0xFFF0F9FF);
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getAll(query: _query, tahun: _tahun, bulan: _bulan),
        _service.getSummary(tahun: _tahun, bulan: _bulan),
      ]);
      if (!mounted) return;
      setState(() {
        _data = results[0] as List<BumilIbu>;
        _summary = results[1] as BumilSummary;
        _loading = false;
      });
      _animController
        ..reset()
        ..forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _delete(BumilIbu d) async {
    if (d.isApproved) {
      _snack('Data yang sudah disetujui tidak dapat dihapus.', error: true);
      return;
    }
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Hapus Data?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
              content: Text(
                  'Data "${d.nama}" (${d.bulanLabel}) akan dihapus.',
                  style: GoogleFonts.poppins(fontSize: 13.5)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Batal',
                        style: GoogleFonts.poppins(color: Colors.grey[600]))),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('Hapus',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700)))
              ],
            ));
    if (confirm == true) {
      try {
        await _service.delete(d.id);
        if (!mounted) return;
        _snack('Data berhasil dihapus.');
        _loadData();
      } catch (e) {
        if (!mounted) return;
        _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
      }
    }
  }

  Future<void> _openForm({BumilIbu? data}) async {
    if (data != null && data.isApproved) {
      _snack('Data yang sudah disetujui tidak dapat diubah.', error: true);
      return;
    }
    final r = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => BumilIbuFormScreen(data: data)));
    if (r == true) _loadData();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      backgroundColor: error ? Colors.red[700] : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _statusBadge(BumilIbu d) {
    late Color bg, fg;
    late IconData icon;
    if (d.isApproved) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      icon = Icons.check_circle_rounded;
    } else if (d.isRejected) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      icon = Icons.error_outline_rounded;
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(d.statusLabel,
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }

  Widget _statusIbuChip(BumilIbu d) {
    const map = {
      'hamil': [Color(0xFFFCE7F3), Color(0xFFBE185D), 'Hamil'],
      'melahirkan': [Color(0xFFDBEAFE), Color(0xFF1D4ED8), 'Melahirkan'],
      'nifas': [Color(0xFFE0E7FF), Color(0xFF4338CA), 'Nifas'],
      'meninggal': [Color(0xFFF3F4F6), Color(0xFF4B5563), 'Meninggal'],
    };
    final c = map[d.statusIbu] ?? map['hamil']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: c[0] as Color, borderRadius: BorderRadius.circular(20)),
      child: Text(c[2] as String,
          style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c[1] as Color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme:
                  const IconThemeData(color: Color(0xFF0F172A)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bumil per Ibu',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Hamil, melahirkan, nifas per bulan',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-bumil-ibu-list',
          onPressed: () async {
            HapticFeedback.mediumImpact();
            _openForm();
          },
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.add_rounded),
          label: Text('Tambah Data',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      body: Column(children: [
        _buildSummary(),
        _buildFilter(),
        const SizedBox(height: 10),
        Expanded(child: _buildBody()),
      ]));
  }

  Widget _buildSummary() {
    Widget item(String label, int v, Color c) => Expanded(
            child: Column(children: [
          Text('$v',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w900, color: c)),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
        ]));
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Text('${BumilIbu.namaBulan[_bulan]} $_tahun',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            item('Hamil', _summary.hamil, Colors.white),
            item('Lahir', _summary.melahirkan, Colors.white),
            item('Nifas', _summary.nifas, Colors.white),
            item('Bayi Lhr', _summary.bayiLahir, Colors.white),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            item('Ibu Mgl', _summary.meninggal, Colors.white70),
            item('Bayi Mgl', _summary.bayiMeninggal, Colors.white70),
            item('Balita Mgl', _summary.balitaMeninggal, Colors.white70),
            item('Total', _data.length, Colors.white70),
          ]),
        ]));
  }

  Widget _buildFilter() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: DropdownButtonFormField<int>(
                  initialValue: _bulan,
                  decoration: const InputDecoration(
                      labelText: 'Bulan',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero),
                  items: BumilIbu.namaBulan.entries
                      .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value,
                              style: GoogleFonts.poppins(fontSize: 13))))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _bulan = v);
                    _loadData();
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: DropdownButtonFormField<int>(
                  initialValue: _tahun,
                  decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero),
                  items: [2024, 2025, 2026, 2027]
                      .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y',
                              style: GoogleFonts.poppins(fontSize: 13))))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _tahun = v);
                    _loadData();
                  },
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]),
              child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    _query = v;
                    _loadData();
                  },
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                      hintText: 'Cari nama ibu / bayi...',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[400]),
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
                              })
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14)))),
        ]));
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_error != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                        child: const Icon(Icons.cloud_off_outlined,
                            size: 44, color: Color(0xFFB91C1C))),
                    const SizedBox(height: 16),
                    Text('Gagal memuat data',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('Coba Lagi',
                            style:
                                GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)))),
                  ])));
    }
    if (_data.isEmpty) {
      return Center(
          child:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: _primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.pregnant_woman_rounded,
                size: 48, color: _primary)),
        const SizedBox(height: 16),
        Text(
            _query.isNotEmpty
                ? 'Tidak ditemukan'
                : 'Belum ada data bulan ini',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569))),
        const SizedBox(height: 8),
        Text(
            _query.isNotEmpty
                ? 'Coba kata kunci berbeda'
                : 'Tekan "Tambah Data" untuk mencatat\nibu bulan ini',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFF94A3B8)))
      ]));
    }
    return RefreshIndicator(
        color: _primary,
        onRefresh: _loadData,
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: _data.length,
            itemBuilder: (ctx, i) => _buildCard(_data[i], i)));
  }

  Widget _buildCard(BumilIbu d, int index) {
    return AnimatedBuilder(
        animation: _animController,
        builder: (ctx, child) {
          final delay = (index * 0.08).clamp(0.0, 0.6);
          final anim = CurvedAnimation(
              parent: _animController,
              curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic));
          return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(anim),
                  child: child));
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: d.isRejected
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]),
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  decoration: const BoxDecoration(
                      color: _primaryLight,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.pregnant_woman_rounded,
                            size: 18, color: _primary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(d.nama,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A))),
                          Text(
                              '${d.bulanLabel} ${d.tahun}${d.desa.isNotEmpty ? ' · ${d.desa}' : ''}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B))),
                        ])),
                    _statusBadge(d),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') {
                            _openForm(data: d);
                          } else if (v == 'delete') {
                            _delete(d);
                          } else if (v == 'detail') {
                            _showDetail(d);
                          }
                        },
                        itemBuilder: (_) => [
                              PopupMenuItem(
                                  value: 'detail',
                                  child: Row(children: [
                                    const Icon(Icons.visibility_outlined,
                                        size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    Text('Lihat Detail',
                                        style: GoogleFonts.poppins())
                                  ])),
                              if (!d.isApproved)
                                PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      const Icon(Icons.edit_outlined,
                                          size: 16, color: Color(0xFF0D9488)),
                                      const SizedBox(width: 8),
                                      Text('Edit',
                                          style: GoogleFonts.poppins(
                                              color: Color(0xFF0D9488)))
                                    ])),
                              if (!d.isApproved)
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline,
                                          size: 16, color: Colors.red[600]),
                                      const SizedBox(width: 8),
                                      Text('Hapus',
                                          style: GoogleFonts.poppins(
                                              color: Colors.red[600]))
                                    ])),
                            ]),
                  ])),
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _statusIbuChip(d),
                          if (d.statusIbu == 'melahirkan' &&
                              d.bayiNama.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'Bayi: ${d.bayiNama}${d.bayiJenisKelamin.isNotEmpty ? ' (${d.bayiJenisKelamin})' : ''}${d.bayiAkta == true ? ' · Akta ada' : ''}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        color: const Color(0xFF475569)),
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ]),
                        if (d.kematianKategori.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                              'Meninggal (${d.kematianKategori}): ${d.kematianNama}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: const Color(0xFFB91C1C))),
                        ],
                        if (d.isRejected &&
                            (d.rejectedReason ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFFECACA))),
                              child: Text(
                                  'Perlu diperbaiki: ${d.rejectedReason!}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF7F1D1D)))),
                        ],
                      ])),
            ])));
  }

  void _showDetail(BumilIbu d) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _DetailSheet(data: d));
  }
}

class _DetailSheet extends StatelessWidget {
  final BumilIbu data;
  const _DetailSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, color: const Color(0xFF64748B)))),
          Expanded(
              child: Text(value.isEmpty ? '-' : value,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A)))),
        ]));

    return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, sc) => Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(data.nama,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A))),
                          Text(
                              '${data.statusIbuLabel} · ${data.bulanLabel} ${data.tahun}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B))),
                        ])),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(data.statusLabel,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0D9488)))),
                  ])),
              const Divider(height: 1),
              Expanded(
                  child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.all(20),
                      children: [
                    row('Nama Ibu', data.nama),
                    row('Nama Suami', data.suamiNama),
                    row('Umur', data.umur > 0 ? '${data.umur} th' : '-'),
                    row('Status', data.statusIbuLabel),
                    row('Bulan', '${data.bulanLabel} ${data.tahun}'),
                    if (data.bayiNama.isNotEmpty)
                      row('Bayi',
                          '${data.bayiNama} (${data.bayiJenisKelamin})'),
                    if (data.bayiTanggalLahir != null)
                      row('Tgl Lahir Bayi',
                          '${data.bayiTanggalLahir!.day}/${data.bayiTanggalLahir!.month}/${data.bayiTanggalLahir!.year}'),
                    if (data.bayiAkta != null)
                      row('Akta', data.bayiAkta! ? 'Ada' : 'Tidak ada'),
                    if (data.kematianKategori.isNotEmpty)
                      row('Meninggal',
                          '${data.kematianKategori}: ${data.kematianNama}'),
                    row('Dasa Wisma', data.dasaWisma),
                    row('RT / RW', '${data.rt} / ${data.rw}'),
                    row('Dusun', data.dusun),
                    row('Desa', data.desa),
                    row('Approval', data.statusLabel),
                    if ((data.rejectedReason ?? '').isNotEmpty)
                      row('Alasan Penolakan', data.rejectedReason!),
                  ]))
            ])));
  }
}
