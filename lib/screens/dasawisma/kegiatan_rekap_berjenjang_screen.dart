import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../services/daftar_warga_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/pemanfaatan_tanah_service.dart';
import '../../services/industri_rumah_tangga_service.dart';
import 'input_terpadu_screen.dart';

// Rekap Berjenjang Kegiatan Warga — SATU layar ringkasan otomatis.
// Semua angka = SUM dari data API (bukan input manual), dikelompokkan per
// dusun + baris JUMLAH. Kolom mengikuti sheet Data Kegiatan Lampiran.
// Sumber: Daftar Warga (KK) + 3 tabel detail yang sudah approved.
// Catatan: yang masih Menunggu persetujuan BELUM masuk angka rekap.

class _RekapDusun {
  final String dusun;
  final Set<String> rw = {};
  final Set<String> rt = {};
  final Set<String> dasaWisma = {};
  int krt = 0;
  int kk = 0;
  int l = 0;
  int p = 0;
  int balitaL = 0;
  int balitaP = 0;
  int pus = 0;
  int wus = 0;
  int hamil = 0;
  int menyusui = 0;
  int lansia = 0;
  int butaL = 0;
  int butaP = 0;
  int sehat = 0;
  int kurangSehat = 0;
  int sampah = 0;
  int spal = 0;
  int stiker = 0;
  int pdam = 0;
  int sumur = 0;
  int sungai = 0;
  int dllAir = 0;
  int jamban = 0;
  int beras = 0;
  int nonBeras = 0;
  int up2k = 0;
  int pekarangan = 0;
  int industri = 0;
  int kesling = 0;

  _RekapDusun(this.dusun);

  List<int> get angka => [
        rw.length,
        rt.length,
        dasaWisma.length,
        krt,
        kk,
        l,
        p,
        balitaL,
        balitaP,
        pus,
        wus,
        hamil,
        menyusui,
        lansia,
        butaL,
        butaP,
        sehat,
        kurangSehat,
        sampah,
        spal,
        stiker,
        pdam,
        sumur,
        sungai,
        dllAir,
        jamban,
        beras,
        nonBeras,
        up2k,
        pekarangan,
        industri,
        kesling,
      ];
}

class KegiatanRekapBerjenjangScreen extends StatefulWidget {
  final bool embedded;
  const KegiatanRekapBerjenjangScreen({super.key, this.embedded = false});

  @override
  State<KegiatanRekapBerjenjangScreen> createState() =>
      _KegiatanRekapBerjenjangScreenState();
}

class _KegiatanRekapBerjenjangScreenState
    extends State<KegiatanRekapBerjenjangScreen> {
  static const Color _primary = Color(0xFF0072BC);

  static const List<String> _kolom = [
    'Jml RW',
    'Jml RT',
    'Jml Dasa Wisma',
    'Jml KRT',
    'Jml KK',
    'L',
    'P',
    'Balita L',
    'Balita P',
    'PUS',
    'WUS',
    'Hamil',
    'Menyusui',
    'Lansia',
    'Buta L',
    'Buta P',
    'Sehat',
    'Kurang Sehat',
    'Sampah',
    'SPAL',
    'Stiker P4K',
    'PDAM',
    'Sumur',
    'Sungai',
    'DLL',
    'Jamban',
    'Beras',
    'Non Beras',
    'UP2K',
    'Pekarangan',
    'Industri RT',
    'Kesling',
  ];

  bool _loading = true;
  String? _error;
  List<_RekapDusun> _rows = [];
  int _pending = 0;
  int _approved = 0;
  int _kkMenunggu = 0;

  /// Normalisasi kunci wilayah: "Durian Runtuh" == "DURIAN RUNTUH",
  /// "01" == "1" — agar tidak jadi baris ganda.
  String _normWil(String v) {
    final t = v.trim().toLowerCase();
    final n = int.tryParse(t);
    if (n != null) return '$n';
    return t;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<DataKeluargaDasawisma> kk = [];
      var keg = <dynamic>[];
      var tanah = <dynamic>[];
      var industri = <dynamic>[];
      String? gagal;
      try {
        kk = await DaftarWargaService().getAll();
      } catch (e) {
        gagal = 'Daftar Warga: $e';
      }
      try {
        keg = await KegiatanWargaService().getAll();
      } catch (e) {
        gagal = '${gagal ?? ''} Kegiatan: $e';
      }
      try {
        tanah = await PemanfaatanTanahService().getAll();
      } catch (e) {
        gagal = '${gagal ?? ''} Pekarangan: $e';
      }
      try {
        industri = await IndustriRumahTanggaService().getAll();
      } catch (e) {
        gagal = '${gagal ?? ''} Industri: $e';
      }
      if (!mounted) return;
      if (kk.isEmpty && keg.isEmpty && tanah.isEmpty && industri.isEmpty) {
        setState(() {
          _loading = false;
          _error = gagal ?? 'Belum ada data.';
        });
        return;
      }

      final map = <String, _RekapDusun>{};
      _RekapDusun row(String dusun) {
        final key = _normWil(dusun).isEmpty ? 'tanpa dusun' : _normWil(dusun);
        return map.putIfAbsent(
            key, () => _RekapDusun(dusun.trim().isEmpty ? 'Tanpa Dusun' : dusun.trim()));
      }

      // Hanya KK yang sudah disetujui masuk angka (selaras server).
      // Yang menunggu tampil terpisah di header agar tidak dikira hilang.
      for (final k in kk.where((e) => e.status == 'approved')) {
        final r = row(k.dusun);
        if (k.rw.isNotEmpty) r.rw.add(_normWil(k.rw));
        if (k.rt.isNotEmpty) r.rt.add(_normWil(k.rt));
        if (k.dasaWisma.isNotEmpty) r.dasaWisma.add(_normWil(k.dasaWisma));
        r.krt += 1;
        r.kk += k.jumlahKk > 0 ? k.jumlahKk : 1;
        r.l += k.jumlahLakiLaki;
        r.p += k.jumlahPerempuan;
        r.balitaL += k.jumlahBalitaL;
        r.balitaP += k.jumlahBalitaP;
        r.pus += k.jumlahPus;
        r.wus += k.jumlahWus;
        r.hamil += k.jumlahIbuHamil;
        r.menyusui += k.jumlahIbuMenyusui;
        r.lansia += k.jumlahLansia;
        r.butaL += k.jumlahTigaButaL;
        r.butaP += k.jumlahTigaButaP;
        if (k.kriteriaRumah == 'Sehat') {
          r.sehat += 1;
        } else {
          r.kurangSehat += 1;
        }
        if (k.memilikiTempatSampah) r.sampah += 1;
        if (k.mempunyaiSpal) r.spal += 1;
        if (k.memilikiStikerP4k) r.stiker += 1;
        switch (k.sumberAir) {
          case 'PDAM':
            r.pdam += 1;
            break;
          case 'Sumur':
            r.sumur += 1;
            break;
          case 'Sungai':
            r.sungai += 1;
            break;
          default:
            r.dllAir += 1;
        }
        if (k.mempunyaiMck) r.jamban += k.jumlahMckSepticTank;
        if (k.makananPokok == 'Beras') {
          r.beras += 1;
        } else {
          r.nonBeras += 1;
        }
      }

      var pending = 0;
      var approved = 0;
      for (final g in keg) {
        if (g.isApproved) {
          approved++;
          final r = row(g.dusun);
          switch (g.kegiatan) {
            case 'up2k':
              r.up2k += 1;
              break;
            case 'pekarangan':
              r.pekarangan += 1;
              break;
            case 'industri':
              r.industri += 1;
              break;
            case 'kesehatan':
              r.kesling += 1;
              break;
          }
        } else if (g.isPending) {
          pending++;
        }
      }
      for (final t in tanah) {
        if (t.isApproved) {
          approved++;
          row(t.dusun).pekarangan += 1;
        } else if (t.isPending) {
          pending++;
        }
      }
      for (final ind in industri) {
        if (ind.isApproved) {
          approved++;
          row(ind.dusun).industri += 1;
        } else if (ind.isPending) {
          pending++;
        }
      }

      final rows = map.values.toList()
        ..sort((a, b) => a.dusun.compareTo(b.dusun));
      final kkPending =
          kk.where((k) => k.status != 'approved').length;
      setState(() {
        _rows = rows;
        _pending = pending;
        _approved = approved;
        _kkMenunggu = kkPending;
        _loading = false;
        _error = gagal;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
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
                  Text('Rekap Berjenjang',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A))),
                  Text('Otomatis per dusun, kolom ikut Lampiran',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
            ),
      body: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final r = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InputTerpaduScreen()),
                  );
                  if (r == true) _loadData();
                },
                icon: const Icon(Icons.bolt_rounded),
                label: Text('Input Terpadu Satu Pintu',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _header() {
    final totalKk = _rows.fold(0, (s, r) => s + r.kk);
    final totalJiwa = _rows.fold(0, (s, r) => s + r.l + r.p);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$totalKk KK · $totalJiwa Jiwa',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${_rows.length} dusun · kegiatan = data Disetujui',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: const Color(0xFF64748B))),
                if (_kkMenunggu > 0)
                  Text('$_kkMenunggu KK menunggu persetujuan',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$_approved Disetujui',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A))),
              Text('$_pending Menunggu',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'Belum ada data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Muat Ulang',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final jumlah = List<int>.filled(_kolom.length, 0);
    for (final r in _rows) {
      final a = r.angka;
      for (var i = 0; i < a.length; i++) {
        jumlah[i] += a[i];
      }
    }

    Widget numCell(int v, {bool bold = false, Color? bg}) => Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: bg,
          alignment: Alignment.center,
          child: Text(
            '$v',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
          ),
        );

    return Column(
      children: [
        if (_error != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Text(
              'Sebagian gagal dimuat: $_error',
              style:
                  GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF7F1D1D)),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: _primary,
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFE6F1F9)),
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 44,
                  headingRowHeight: 56,
                  border: TableBorder.all(
                      color: const Color(0xFFE2E8F0), width: 1),
                  columns: <DataColumn>[
                    const DataColumn(
                        label: Text('No',
                            style: TextStyle(fontWeight: FontWeight.w800))),
                    const DataColumn(
                        label: Text('Dusun',
                            style: TextStyle(fontWeight: FontWeight.w800))),
                    for (final k in _kolom)
                      DataColumn(
                          label: Text(k,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 12))),
                  ],
                  rows: <DataRow>[
                    for (var i = 0; i < _rows.length; i++)
                      DataRow(cells: <DataCell>[
                        DataCell(numCell(i + 1)),
                        DataCell(Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          child: Text(_rows[i].dusun,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        )),
                        for (final v in _rows[i].angka)
                          DataCell(numCell(v)),
                      ]),
                    DataRow(
                      color: WidgetStateProperty.all(
                          const Color(0xFFDCFCE7)),
                      cells: <DataCell>[
                        const DataCell(SizedBox()),
                        DataCell(Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          child: Text('JUMLAH',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, fontWeight: FontWeight.w800)),
                        )),
                        for (final v in jumlah)
                          DataCell(numCell(v, bold: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
