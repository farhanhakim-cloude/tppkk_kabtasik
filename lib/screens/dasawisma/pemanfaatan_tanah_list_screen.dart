import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pemanfaatan_tanah.dart';
import '../../services/pemanfaatan_tanah_service.dart';
import 'pemanfaatan_tanah_form_screen.dart';

class PemanfaatanTanahListScreen extends StatefulWidget {
  final bool embedded;
  const PemanfaatanTanahListScreen({super.key, this.embedded = false});
  @override
  State<PemanfaatanTanahListScreen> createState() =>
      _PemanfaatanTanahListScreenState();
}

class _PemanfaatanTanahListScreenState extends State<PemanfaatanTanahListScreen>
    with SingleTickerProviderStateMixin {
  final _service = PemanfaatanTanahService();
  final _searchController = TextEditingController();
  List<PemanfaatanTanah> _data = [];
  Map<String, int> _stats = {'total': 0, 'totalKk': 0};
  bool _loading = true;
  String? _error;
  String _query = '';
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
        _service.getAll(query: _query),
        _service.getStatistik(),
      ]);
      if (!mounted) return;
      setState(() {
        _data = results[0] as List<PemanfaatanTanah>;
        _stats = results[1] as Map<String, int>;
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

  Future<void> _delete(PemanfaatanTanah d) async {
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
                  'Tanaman "${d.jenisTanaman}" akan dihapus.',
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

  Future<void> _openForm({PemanfaatanTanah? data}) async {
    if (data != null && data.isApproved) {
      _snack('Data yang sudah disetujui tidak dapat diubah.', error: true);
      return;
    }
    final r = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => PemanfaatanTanahFormScreen(data: data)));
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

  Widget _statusBadge(PemanfaatanTanah d) {
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
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemanfaatan Tanah',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A))),
                    Text('Tanaman & hasil pekarangan',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: const Color(0xFF64748B)))
                  ])),
      floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-pemanfaatan-tanah-list',
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
        _buildStats(),
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
                        hintText: 'Cari tanaman, hasil, dusun...',
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
                            horizontal: 16, vertical: 14))))),
        const SizedBox(height: 10),
        Expanded(child: _buildBody()),
      ]));
  }

  Widget _buildStats() {
    final total = _stats['total'] ?? 0;
    final kk = _stats['totalKk'] ?? 0;
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.grass_rounded,
                  color: Colors.white, size: 24)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Total Catatan',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white70)),
                Text('$total Catatan',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white))
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$kk',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            Text('KK Terlibat',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70))
          ])
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
            child:
                const Icon(Icons.grass_outlined, size: 48, color: _primary)),
        const SizedBox(height: 16),
        Text(_query.isNotEmpty ? 'Tidak ditemukan' : 'Belum ada data pekarangan',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569))),
        const SizedBox(height: 8),
        Text(
            _query.isNotEmpty
                ? 'Coba kata kunci berbeda'
                : 'Tekan "Tambah Data" untuk mencatat\npemanfaatan pekarangan pertama',
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

  Widget _buildCard(PemanfaatanTanah d, int index) {
    final subtitle = [
      if (d.dasaWisma.isNotEmpty) d.dasaWisma,
      if (d.desa.isNotEmpty) d.desa,
    ].join(' · ');
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
                        child: const Icon(Icons.grass_rounded,
                            size: 18, color: _primary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(d.jenisTanaman,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A))),
                          Text(subtitle,
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
                          Expanded(
                              child: Text(
                                  '${d.luasM2.toStringAsFixed(d.luasM2.truncateToDouble() == d.luasM2 ? 0 : 2)} m² · ${d.jumlahKk} KK',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A)))),
                        ]),
                        if (d.hasil.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Hasil: ${d.hasil}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: const Color(0xFF64748B)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
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
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline_rounded,
                                        size: 16, color: Color(0xFFB91C1C)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text('Perlu diperbaiki:',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFFB91C1C))),
                                          Text(d.rejectedReason!,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color:
                                                      const Color(0xFF7F1D1D))),
                                        ])),
                                  ])),
                        ],
                      ])),
            ])));
  }

  void _showDetail(PemanfaatanTanah d) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _DetailSheet(data: d));
  }
}

class _DetailSheet extends StatelessWidget {
  final PemanfaatanTanah data;
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
                          Text(data.jenisTanaman,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A))),
                          Text(data.dasaWisma,
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
                    row('Jenis Tanaman', data.jenisTanaman),
                    row('Luas', '${data.luasM2} m²'),
                    row('Jumlah KK', '${data.jumlahKk}'),
                    row('Hasil', data.hasil),
                    row('Dasa Wisma', data.dasaWisma),
                    row('RT / RW', '${data.rt} / ${data.rw}'),
                    row('Dusun', data.dusun),
                    row('Desa', data.desa),
                    row('Kecamatan', data.kecamatan),
                    row('Status', data.statusLabel),
                    if ((data.rejectedReason ?? '').isNotEmpty)
                      row('Alasan Penolakan', data.rejectedReason!),
                  ]))
            ])));
  }
}
