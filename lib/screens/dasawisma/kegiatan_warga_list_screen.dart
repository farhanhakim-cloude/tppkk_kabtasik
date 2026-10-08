import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/kegiatan_warga.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../widgets/skeleton.dart';
import 'input_terpadu_screen.dart';
import 'kegiatan_warga_form_screen.dart';
import 'kegiatan_warga_gabungan_form_screen.dart';

class KegiatanWargaListScreen extends StatefulWidget {
  final bool embedded;
  const KegiatanWargaListScreen({super.key, this.embedded = false});
  @override
  State<KegiatanWargaListScreen> createState() => _KegiatanWargaListScreenState();
}

class _KegiatanWargaListScreenState extends State<KegiatanWargaListScreen>
    with SingleTickerProviderStateMixin {
  final _service = KegiatanWargaService();
  final _searchController = TextEditingController();
  List<KegiatanWarga> _data = [];
  Map<String, int> _stats = {'total': 0, 'pending': 0, 'approved': 0};
  bool _loading = true;
  String? _error;
  String _query = '';

  static const Color _biru = Color(0xFF0F4C81);
  static const Color _ink = Color(0xFF1A2B3C);
  static const Color _muted = Color(0xFF5B6B7C);
  static const Color _line = Color(0xFFE1E7EE);
  static const Color _paper = Color(0xFFF4F6F9);
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    return msg;
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
        _data = results[0] as List<KegiatanWarga>;
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
        _error = _friendlyError(e);
      });
    }
  }

  Future<void> _delete(KegiatanWarga d) async {
    if (d.isApproved) {
      _snack('Data yang sudah disetujui tidak dapat dihapus.', error: true);
      return;
    }
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Hapus Data?',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              content: Text(
                  'Kegiatan "${d.kegiatanLabel}" (${d.dasaWisma}) akan dihapus.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Batal',
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]))),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('Hapus',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)))
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
        _snack(_friendlyError(e), error: true);
      }
    }
  }

  Future<void> _openForm({KegiatanWarga? data}) async {
    if (data != null && data.isApproved) {
      _snack('Data yang sudah disetujui tidak dapat diubah.', error: true);
      return;
    }
    final r = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => data == null
                ? const KegiatanWargaGabunganFormScreen()
                : KegiatanWargaFormScreen(data: data)));
    if (r == true) _loadData();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      backgroundColor: error ? Colors.red[700] : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // Status gaya dashboard: teks saja.
  Widget _statusText(KegiatanWarga d) {
    late Color c;
    late String t;
    if (d.isApproved) {
      c = const Color(0xFF1B7A4D);
      t = 'Disetujui';
    } else if (d.isRejected) {
      c = const Color(0xFFB42318);
      t = 'Ditolak';
    } else {
      c = const Color(0xFF92600A);
      t = 'Menunggu';
    }
    return Text(t,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w700, color: c));
  }

  String _fmtTanggal(DateTime? t) {
    if (t == null) return '-';
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${t.day} ${bulan[t.month]} ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: _ink),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kegiatan Warga',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink)),
                    Text('UP2K, Pekarangan, Industri, Kesehatan',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: _muted))
                  ])),
      floatingActionButton: widget.embedded
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab-kegiatan-warga-list',
              onPressed: () async {
                HapticFeedback.mediumImpact();
                _openForm();
              },
              backgroundColor: _biru,
              foregroundColor: Colors.white,
              elevation: 0,
              icon: const Icon(Icons.add_rounded),
              label: Text('Tambah Data',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700))),
      body: Column(children: [
        if (widget.embedded) _terpaduBanner(),
        _buildStats(),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _line)),
                child: TextField(
                    controller: _searchController,
                    onChanged: (v) {
                      _query = v;
                      _loadData();
                    },
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: InputDecoration(
                        hintText: 'Cari dasa wisma, desa, kegiatan...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: _muted, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: _muted),
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

  Widget _terpaduBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _biru, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Input dari menu Terpadu (4 langkah). Di sini hanya lihat data.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _ink)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const InputTerpaduScreen())),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
            child: Text('Buka',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _biru)),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line)),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: _biru)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted)),
        ]),
      ),
    );
  }

  Widget _buildStats() {
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0), child: SkeletonStats());
    }
    final total = _stats['total'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final approved = _stats['approved'] ?? 0;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          _statBox('Total', '$total'),
          const SizedBox(width: 8),
          _statBox('Menunggu', '$pending'),
          const SizedBox(width: 8),
          _statBox('Disetujui', '$approved'),
          const SizedBox(width: 8),
          _statBox('Kegiatan', '$total'),
        ]));
  }

  Widget _buildBody() {
    if (_loading) {
      return const SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 100),
          child: SkeletonList(count: 4));
    }
    if (_error != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_outlined,
                        size: 44, color: _muted),
                    const SizedBox(height: 16),
                    Text('Gagal memuat data',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _muted)),
                    const SizedBox(height: 8),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: _muted)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('Coba Lagi',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _biru,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)))),
                  ])));
    }
    if (_data.isEmpty) return _buildEmpty();
    return RefreshIndicator(
        color: _biru,
        onRefresh: _loadData,
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: _data.length,
            itemBuilder: (ctx, i) => _buildCard(_data[i], i)));
  }

  Widget _buildCard(KegiatanWarga d, int index) {
    final subtitle = [
      if (d.rt.isNotEmpty || d.rw.isNotEmpty) 'RT ${d.rt}/RW ${d.rw}',
      if (d.desa.isNotEmpty) d.desa,
      _fmtTanggal(d.tanggal),
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
                  position:
                      Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                          .animate(anim),
                  child: child));
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              d.dasaWisma.isEmpty ? 'Dasa Wisma' : d.dasaWisma,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _ink)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: _muted)),
                        ])),
                    _statusText(d),
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
                                        size: 16, color: _muted),
                                    const SizedBox(width: 8),
                                    Text('Lihat Detail',
                                        style: GoogleFonts.plusJakartaSans())
                                  ])),
                              if (!d.isApproved)
                                PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      const Icon(Icons.edit_outlined,
                                          size: 16, color: _biru),
                                      const SizedBox(width: 8),
                                      Text('Edit',
                                          style: GoogleFonts.plusJakartaSans(
                                              color: _biru))
                                    ])),
                              if (!d.isApproved)
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline,
                                          size: 16, color: Colors.red[600]),
                                      const SizedBox(width: 8),
                                      Text('Hapus',
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Colors.red[600]))
                                    ])),
                            ]),
                  ]),
                  const Divider(height: 20, color: _line),
                  Text(d.kegiatanLabel,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  const SizedBox(height: 2),
                  Text('${d.jumlahPeserta} Peserta',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: _muted)),
                  if (d.keterangan.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(d.keterangan,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: _muted),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _line)),
                        child: Text(
                            'Perlu diperbaiki: ${d.rejectedReason!}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFFB42318)))),
                  ],
                ])));
  }

  void _showDetail(KegiatanWarga d) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _DetailSheet(data: d));
  }

  Widget _buildEmpty() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.diversity_3_outlined, size: 48, color: _muted),
        const SizedBox(height: 16),
        Text(_query.isNotEmpty ? 'Tidak ditemukan' : 'Belum ada data kegiatan warga',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _muted)),
        const SizedBox(height: 8),
        Text(
            _query.isNotEmpty
                ? 'Coba kata kunci berbeda'
                : 'Tekan "Tambah Data" untuk mencatat\nkegiatan warga pertama',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted))
      ]));
}

class _DetailSheet extends StatelessWidget {
  final KegiatanWarga data;
  const _DetailSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, color: const Color(0xFF5B6B7C)))),
          Expanded(
              child: Text(value.isEmpty ? '-' : value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2B3C)))),
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
                      color: const Color(0xFFE1E7EE),
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              data.dasaWisma.isEmpty
                                  ? 'Dasa Wisma'
                                  : data.dasaWisma,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A2B3C))),
                          Text(data.kegiatanLabel,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF5B6B7C))),
                        ])),
                    Text(data.statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F4C81))),
                  ])),
              const Divider(height: 1, color: Color(0xFFE1E7EE)),
              Expanded(
                  child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.all(20),
                      children: [
                    row('Kegiatan', data.kegiatanLabel),
                    row('Jumlah Peserta', '${data.jumlahPeserta}'),
                    row('Tanggal',
                        data.tanggal == null
                            ? '-'
                            : '${data.tanggal!.day}/${data.tanggal!.month}/${data.tanggal!.year}'),
                    row('Dasa Wisma', data.dasaWisma),
                    row('RT / RW', '${data.rt} / ${data.rw}'),
                    row('Dusun', data.dusun),
                    row('Desa', data.desa),
                    row('Kecamatan', data.kecamatan),
                    row('Keterangan', data.keterangan),
                    row('Status', data.statusLabel),
                    if ((data.rejectedReason ?? '').isNotEmpty)
                      row('Alasan Penolakan', data.rejectedReason!),
                    if ((data.approvedByName ?? '').isNotEmpty)
                      row('Disetujui Oleh', data.approvedByName!),
                  ]))
            ])));
  }
}
