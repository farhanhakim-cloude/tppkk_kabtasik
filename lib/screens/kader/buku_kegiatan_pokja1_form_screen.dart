// lib/screens/kader/buku_kegiatan_pokja1_form_screen.dart
// Form input Buku Kegiatan Pokja I — LAMPIRAN 4.13
// Kolom: 1 NO | 2 NAMA | 3 JABATAN | 4 TANGGAL | 5 TEMPAT | 6 URAIAN | 7 TANDA TANGAN
// Alur: kirim via CatatanKegiatanService (POST laporan-kegiatan, kategori_pokja=I)
// → status pending "Menunggu Verifikasi", TIDAK publish,
// muncul di halaman verifikasi admin kabupaten + super admin.
// Gaya dinas: biru 0072BC, ink 1A2B3C, muted 5B6B7C, garis E1E7EE, paper F4F6F9,
// radius 12, font PlusJakartaSans. Tanpa BLoC (setState).

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/desa_options.dart';
import '../../main.dart';
import '../../models/buku_kegiatan_pokja1.dart';
import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../../services/wilayah_service.dart';

class BukuKegiatanPokja1FormScreen extends StatefulWidget {
  final CatatanKegiatan? existing;

  const BukuKegiatanPokja1FormScreen({super.key, this.existing});

  @override
  State<BukuKegiatanPokja1FormScreen> createState() =>
      _BukuKegiatanPokja1FormScreenState();
}

class _RowControllers {
  final TextEditingController nama = TextEditingController();
  final TextEditingController jabatan = TextEditingController();
  final TextEditingController tempat = TextEditingController();
  final TextEditingController uraian = TextEditingController();
  DateTime? tanggal;

  void dispose() {
    nama.dispose();
    jabatan.dispose();
    tempat.dispose();
    uraian.dispose();
  }
}

class _BukuKegiatanPokja1FormScreenState
    extends State<BukuKegiatanPokja1FormScreen> {
  // Palet dinas selaras dasawisma & kader dashboard.
  static const Color _biru = Color(0xFF0072BC);
  static const Color _ink = Color(0xFF1A2B3C);
  static const Color _muted = Color(0xFF5B6B7C);
  static const Color _line = Color(0xFFE1E7EE);
  static const Color _paper = Color(0xFFF4F6F9);

  final _formKey = GlobalKey<FormState>();
  final _service = CatatanKegiatanService();
  final _wilayahService = WilayahService();

  final _desaCtrl = TextEditingController();
  String? _kecamatan;
  String? _kecError;
  List<String> _desaOptions = [];
  bool _loadingDesa = false;

  final List<_RowControllers> _rows = [];
  bool _saving = false;
  bool _isDarkMode = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _prefill();
  }

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _desaCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _prefill() async {
    final ex = widget.existing;
    if (ex != null) {
      _kecamatan = ex.kecamatan.isNotEmpty ? ex.kecamatan : null;
      _desaCtrl.text = ex.desa ?? '';
      final rows = BukuKegiatanPokja1.fromDataAngka(ex.dataAngka);
      for (final row in rows.isEmpty ? const [BukuKegiatanRow()] : rows) {
        final c = _RowControllers()
          ..nama.text = row.nama
          ..jabatan.text = row.jabatan
          ..tempat.text = row.tempat
          ..uraian.text = row.uraian
          ..tanggal = row.tanggal;
        _rows.add(c);
      }
      if (_kecamatan != null && _kecamatan!.isNotEmpty) {
        await _loadDesa(_kecamatan!);
      }
      if (mounted) setState(() {});
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_data') ?? '{}';
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final kec = (data['kecamatan'] ?? '').toString();
      final desa = (data['desa'] ?? data['kelurahan'] ?? '').toString();
      if (CatatanKegiatan.daftar39Kecamatan.contains(kec)) {
        _kecamatan = kec;
        await _loadDesa(kec);
      }
      _desaCtrl.text = desa;
    } catch (_) {}
    _addRow();
    if (mounted) setState(() {});
  }

  Future<void> _loadDesa(String kecamatan, {bool resetDesa = false}) async {
    setState(() => _loadingDesa = true);
    try {
      // API dulu (tetap segar bila backend menambah endpoint wilayah),
      // fallback ke peta statis DATA_DESA backend (constants/desa_options.dart)
      // agar dropdown desa SELALU tersedia per kecamatan.
      final apiList = await _wilayahService.getDesa(kecamatan);
      final list = apiList.isNotEmpty
          ? apiList
          : (kDesaByKecamatan[kecamatan] ?? const <String>[]);
      if (!mounted) return;
      // Abaikan hasil basi bila user sudah pindah kecamatan lain.
      if (kecamatan != _kecamatan) {
        setState(() => _loadingDesa = false);
        return;
      }
      setState(() {
        _desaOptions = list;
        _loadingDesa = false;
        if (resetDesa) {
          final cur = _desaCtrl.text.trim().toLowerCase();
          if (cur.isNotEmpty &&
              !list.any((d) => d.toLowerCase() == cur)) {
            _desaCtrl.clear();
          }
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingDesa = false);
    }
  }

  void _pilihKecamatan(String kec) {
    setState(() {
      _kecamatan = kec;
      _kecError = null;
      _desaOptions = [];
    });
    _loadDesa(kec, resetDesa: true);
  }

  void _showKecamatanPicker() {
    var filtered = List<String>.from(CatatanKegiatan.daftar39Kecamatan);
    final searchCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1E242D) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setModal) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _line,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Kecamatan',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white : _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '39 kecamatan Kab. Tasikmalaya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari kecamatan...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: _paper,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setModal(
                      () => filtered = CatatanKegiatan.daftar39Kecamatan
                          .where((k) => k
                              .toLowerCase()
                              .contains(v.toLowerCase().trim()))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: _paper),
                      itemBuilder: (_, i) {
                        final kec = filtered[i];
                        final sel = kec == _kecamatan;
                        return ListTile(
                          dense: true,
                          title: Text(
                            kec,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                              color: sel
                                  ? _biru
                                  : (_isDarkMode ? Colors.white : _ink),
                            ),
                          ),
                          trailing: sel
                              ? const Icon(Icons.check_circle_rounded,
                                  color: _biru, size: 20)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            _pilihKecamatan(kec);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDesaPicker() {
    if (_desaOptions.isEmpty || _loadingDesa) return;
    var filtered = List<String>.from(_desaOptions);
    final searchCtrl = TextEditingController();
    final kec = _kecamatan ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1E242D) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setModal) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _line,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Desa',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white : _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Desa di Kec. $kec • ${filtered.length} desa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari desa...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: _paper,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setModal(
                      () => filtered = _desaOptions
                          .where((d) => d
                              .toLowerCase()
                              .contains(v.toLowerCase().trim()))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: _paper),
                      itemBuilder: (_, i) {
                        final desa = filtered[i];
                        final sel = desa.toLowerCase() ==
                            _desaCtrl.text.trim().toLowerCase();
                        return ListTile(
                          dense: true,
                          title: Text(
                            desa,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                              color: sel
                                  ? _biru
                                  : (_isDarkMode ? Colors.white : _ink),
                            ),
                          ),
                          trailing: sel
                              ? const Icon(Icons.check_circle_rounded,
                                  color: _biru, size: 20)
                              : null,
                          onTap: () {
                            setState(() => _desaCtrl.text = desa);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addRow() {
    setState(() => _rows.add(_RowControllers()));
  }

  void _removeRow(int i) {
    if (_rows.length <= 1) {
      _snack('Minimal 1 baris kegiatan.');
      return;
    }
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickTanggal(int i) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _rows[i].tanggal ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _rows[i].tanggal = picked);
  }

  List<BukuKegiatanRow> _collectRows() => [
        for (final c in _rows)
          BukuKegiatanRow(
            nama: c.nama.text,
            jabatan: c.jabatan.text,
            tanggal: c.tanggal,
            tempat: c.tempat.text,
            uraian: c.uraian.text,
          ),
      ];

  Future<void> _simpan() async {
    if (_saving) return;
    if (_kecamatan == null || _kecamatan!.trim().isEmpty) {
      setState(() => _kecError = 'Wajib pilih kecamatan');
    }
    if (!_formKey.currentState!.validate()) return;
    if (_kecamatan == null || _kecamatan!.trim().isEmpty) return;
    final rows = _collectRows();
    if (rows.isEmpty) {
      _snack('Tambah minimal 1 baris kegiatan.');
      return;
    }
    for (var i = 0; i < rows.length; i++) {
      if (!rows[i].isValid) {
        _snack('Baris ${i + 1} belum lengkap (nama, tanggal, tempat, uraian wajib).');
        return;
      }
    }

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      final desa = _desaCtrl.text.trim();
      final kec = _kecamatan!.trim();
      final catatan = CatatanKegiatan(
        id: widget.existing?.id ?? 0,
        judul:
            BukuKegiatanPokja1.buildJudul(desa: desa, kecamatan: kec),
        deskripsiSingkat: BukuKegiatanPokja1.buildDeskripsi(rows),
        kategori: PokjaKategori.pokja1,
        dataAngka: BukuKegiatanPokja1.toDataAngka(rows),
        kecamatan: kec,
        desa: desa.isEmpty ? null : desa,
        tanggal: rows.first.tanggal ?? DateTime.now(),
      );
      await _service.kirim(catatan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Terkirim. Menunggu verifikasi admin kabupaten (tidak dipublish).'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _snack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    final bg = isDark ? const Color(0xFF10141D) : _paper;
    final card = isDark ? const Color(0xFF1E242D) : Colors.white;
    final text = isDark ? Colors.white : _ink;
    final sub = isDark ? const Color(0xFF8E9BAE) : _muted;
    final border = isDark ? const Color(0xFF2A3342) : _line;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? card : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? 'Edit Buku Kegiatan' : 'Buku Kegiatan Pokja I',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 16, color: text),
            ),
            Text(
              'Lampiran 4.13 • Masuk verifikasi admin kabupaten',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sub),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            _infoCard(card, border, text, sub),
            const SizedBox(height: 12),
            _wilayahCard(card, border, text, sub),
            const SizedBox(height: 12),
            ...List.generate(_rows.length, (i) => _rowCard(i, card, border, text, sub)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Tambah Baris',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _biru,
                side: const BorderSide(color: _biru),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
            const SizedBox(height: 14),
            _previewTable(card, border, text, sub),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _simpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _biru,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      _isEdit ? 'Simpan Perubahan' : 'Kirim ke Admin Kabupaten',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800, fontSize: 14),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(Color card, Color border, Color text, Color sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _biru.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: _biru, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BUKU KEGIATAN — LAMPIRAN 4.13',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, fontSize: 13, color: text)),
                const SizedBox(height: 4),
                Text(
                  'Isi per baris: nama, jabatan, tanggal, tempat, uraian. '
                  'Kolom tanda tangan dikosongkan (diisi basah saat cetak). '
                  'Data terkirim sebagai laporan Pokja I berstatus pending.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: sub, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pola sama seperti form Pokja lain: ketuk → bottom-sheet + cari.
  // Kecamatan: 39 kecamatan Kab. Tasikmalaya. Desa: mengikuti kecamatan
  // (API bila ada, fallback peta statis DATA_DESA backend); ketik manual
  // hanya bila keduanya kosong.
  Widget _wilayahCard(Color card, Color border, Color text, Color sub) {
    final kec = (_kecamatan ?? '').trim();
    final desaAdaDaftar = _desaOptions.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wilayah',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 13, color: text)),
          const SizedBox(height: 10),
          InkWell(
            onTap: _showKecamatanPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _kecError != null ? Colors.red : border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 18, color: _biru),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kecamatan *',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: sub)),
                        const SizedBox(height: 2),
                        Text(
                          kec.isEmpty ? 'Pilih kecamatan' : kec,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kec.isEmpty ? sub : text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: sub),
                ],
              ),
            ),
          ),
          if (_kecError != null) ...[
            const SizedBox(height: 6),
            Text(_kecError!,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: Colors.red)),
          ],
          const SizedBox(height: 10),
          TextFormField(
            controller: _desaCtrl,
            readOnly: desaAdaDaftar,
            onTap: desaAdaDaftar ? _showDesaPicker : null,
            decoration: _deco(
              desaAdaDaftar
                  ? 'Desa / Kelurahan * (ketuk untuk pilih)'
                  : 'Desa / Kelurahan *',
              sub,
              border,
            ).copyWith(
              suffixIcon: _loadingDesa
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : desaAdaDaftar
                      ? Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: sub)
                      : null,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (desaAdaDaftar ? 'Wajib pilih desa' : 'Wajib isi desa')
                : null,
          ),
          if (desaAdaDaftar)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Desa di Kec. $kec • ${_desaOptions.length} desa',
                style:
                    GoogleFonts.plusJakartaSans(fontSize: 11, color: sub),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _deco(String label, Color sub, Color border) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _rowCard(int i, Color card, Color border, Color text, Color sub) {
    final c = _rows[i];
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _biru.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${i + 1}',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _biru)),
              ),
              const SizedBox(width: 8),
              Text('Baris ${i + 1}',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 13, color: text)),
              const Spacer(),
              IconButton(
                tooltip: 'Hapus baris',
                onPressed: () => _removeRow(i),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: c.nama,
                  decoration: _deco('Nama *', sub, border),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Wajib diisi'
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: c.jabatan,
                  decoration: _deco('Jabatan', sub, border),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickTanggal(i),
                  child: InputDecorator(
                    decoration: _deco('Tanggal *', sub, border),
                    child: Text(
                      c.tanggal == null ? 'Pilih tanggal' : fmt(c.tanggal!),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: c.tanggal == null ? sub : text),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: c.tempat,
                  decoration: _deco('Tempat *', sub, border),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Wajib diisi'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: c.uraian,
            decoration: _deco('Uraian kegiatan *', sub, border),
            maxLines: 2,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _previewTable(Color card, Color border, Color text, Color sub) {
    final rows = _collectRows();
    TextStyle head = GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800, fontSize: 11, color: text);
    TextStyle cell =
        GoogleFonts.plusJakartaSans(fontSize: 11, color: text, height: 1.4);

    Widget h(String s, {double w = 110}) => Container(
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          alignment: Alignment.center,
          child: Text(s, style: head, textAlign: TextAlign.center),
        );
    Widget d(String s, {double w = 110}) => Container(
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          alignment: Alignment.centerLeft,
          child: Text(s.isEmpty ? '—' : s, style: cell),
        );

    String fmtShort(DateTime? dt) => dt == null
        ? ''
        : '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text('Pratinjau output — BUKU KEGIATAN',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: text)),
                ),
                Text('LAMPIRAN 4.13',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: sub)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text(
              'Kolom tanda tangan dikosongkan — sama seperti format Kemendagri & PKK Pusat.',
              style:
                  GoogleFonts.plusJakartaSans(fontSize: 11, color: sub),
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Table(
              border: TableBorder.all(color: border),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                      color: _biru.withValues(alpha: 0.08)),
                  children: [
                    h('NO', w: 44),
                    h('NAMA', w: 130),
                    h('JABATAN', w: 110),
                    h('TANGGAL', w: 100),
                    h('TEMPAT', w: 120),
                    h('URAIAN', w: 180),
                    h('TANDA TANGAN', w: 110),
                  ],
                ),
                TableRow(
                  children: [
                    h('1', w: 44),
                    h('2', w: 130),
                    h('3', w: 110),
                    h('4', w: 100),
                    h('5', w: 120),
                    h('6', w: 180),
                    h('7', w: 110),
                  ],
                ),
                for (var i = 0; i < rows.length; i++)
                  TableRow(
                    children: [
                      Container(
                        width: 44,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        alignment: Alignment.center,
                        child: Text('${i + 1}', style: cell),
                      ),
                      d(rows[i].nama.trim(), w: 130),
                      d(rows[i].jabatan.trim(), w: 110),
                      d(fmtShort(rows[i].tanggal), w: 100),
                      d(rows[i].tempat.trim(), w: 120),
                      d(rows[i].uraian.trim(), w: 180),
                      d('', w: 110),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(
              'Kementerian Dalam Negeri & Tim Penggerak PKK Pusat',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: sub),
            ),
          ),
        ],
      ),
    );
  }
}
