// lib/screens/industri_rumah_tangga_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/industri_rumah_tangga.dart';
import '../services/industri_rumah_tangga_service.dart';

class IndustriRumahTanggaFormScreen extends StatefulWidget {
  final IndustriRumahTangga? data;

  const IndustriRumahTanggaFormScreen({super.key, this.data});

  @override
  State<IndustriRumahTanggaFormScreen> createState() =>
      _IndustriRumahTanggaFormScreenState();
}

class _IndustriRumahTanggaFormScreenState
    extends State<IndustriRumahTanggaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = IndustriRumahTanggaService();

  static const Color _primary = Color(0xFF7C3AED);
  static const Color _primaryLight = Color(0xFFF5F3FF);

  // ── Identitas ──
  late final TextEditingController _namaKKCtrl;
  late final TextEditingController _rtCtrl;
  late final TextEditingController _rwCtrl;
  late final TextEditingController _dasaWismaCtrl;
  late final TextEditingController _catatanCtrl;

  String _bulan = 'Januari';
  String _tahun = '2026';

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _tahunList = ['2024', '2025', '2026', '2027'];

  // ── Item Industri ──
  final List<_ItemState> _items = [];
  bool _saving = false;
  bool get _isEdit => widget.data != null;

  // Kategori dengan daftar komoditi bawaan masing-masing
  static const Map<String, List<String>> _kategoriKomoditi = {
    'Makanan & Minuman': [
      'Keripik Singkong', 'Keripik Pisang', 'Tempe', 'Tahu', 'Kue Kering',
      'Dodol', 'Sirup', 'Jamu', 'Emping', 'Sale Pisang', 'Rendang',
      'Abon', 'Opak', 'Rengginang', 'Lainnya'
    ],
    'Kerajinan Tangan': [
      'Anyaman Bambu', 'Anyaman Rotan', 'Batik Tulis', 'Batik Cap',
      'Tenun', 'Tas Rajut', 'Gerabah', 'Ukiran Kayu', 'Sulam',
      'Boneka', 'Miniatur', 'Lainnya'
    ],
    'Tekstil & Pakaian': [
      'Jahit Baju', 'Konveksi', 'Bordir', 'Sablon', 'Celana',
      'Pakaian Anak', 'Mukena', 'Hijab', 'Lainnya'
    ],
    'Pertanian / Hasil Bumi': [
      'Sayuran', 'Buah-buahan', 'Palawija', 'Padi', 'Jagung',
      'Singkong', 'Ubi Jalar', 'Kacang-kacangan', 'Rempah-rempah', 'Lainnya'
    ],
    'Peternakan': [
      'Ayam Kampung', 'Itik/Bebek', 'Kambing', 'Sapi', 'Kelinci',
      'Telur Ayam', 'Telur Itik', 'Ikan Lele', 'Ikan Mas', 'Lainnya'
    ],
    'Perikanan': [
      'Ikan Asin', 'Udang', 'Terasi', 'Ikan Bandeng', 'Ikan Patin',
      'Ikan Nila', 'Kerupuk Ikan', 'Lainnya'
    ],
    'Jasa': [
      'Salon / Kecantikan', 'Laundry', 'Jahit & Reparasi', 'Bengkel Motor',
      'Warung Makan', 'Katering', 'Foto Copy', 'Isi Ulang Air',
      'Les Privat', 'Lainnya'
    ],
    'Lainnya': ['Lainnya'],
  };

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _namaKKCtrl = TextEditingController(text: d?.namaKepalaKeluarga ?? '');
    _rtCtrl = TextEditingController(text: d?.rt ?? '');
    _rwCtrl = TextEditingController(text: d?.rw ?? '');
    _dasaWismaCtrl = TextEditingController(text: d?.dasaWisma ?? '');
    _catatanCtrl = TextEditingController(text: d?.catatan ?? '');
    _bulan = d?.bulan ?? 'Januari';
    _tahun = d?.tahun ?? '2026';

    if (d != null && d.items.isNotEmpty) {
      for (final item in d.items) {
        _items.add(_ItemState(
          kategori: item.kategori,
          komoditi: item.komoditi,
          volume: item.volume,
        ));
      }
    } else {
      _items.add(_ItemState()); // 1 item kosong
    }
  }

  @override
  void dispose() {
    _namaKKCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dasaWismaCtrl.dispose();
    _catatanCtrl.dispose();
    for (final item in _items) item.dispose();
    super.dispose();
  }

  void _tambahItem() {
    HapticFeedback.selectionClick();
    setState(() => _items.add(_ItemState()));
  }

  void _hapusItem(int i) {
    if (_items.length <= 1) return;
    HapticFeedback.selectionClick();
    setState(() {
      _items[i].dispose();
      _items.removeAt(i);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final valid = _items.where((it) => it.kategori != null && it.komoditi.isNotEmpty).toList();
    if (valid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Isi minimal 1 data industri (kategori & komoditi wajib)',
            style: GoogleFonts.plusJakartaSans()),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    try {
      final industriItems = valid.map((it) => IndustriItem(
            kategori: it.kategori ?? '',
            komoditi: it.komoditi,
            volume: it.volumeCtrl.text.trim(),
          )).toList();

      final payload = IndustriRumahTangga(
        id: widget.data?.id ?? '0',
        namaKepalaKeluarga: _namaKKCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dasaWisma: _dasaWismaCtrl.text.trim(),
        bulan: _bulan,
        tahun: _tahun,
        items: industriItems,
        catatan: _catatanCtrl.text.trim(),
      );

      if (_isEdit) {
        await _service.update(payload);
      } else {
        await _service.add(payload);
      }

      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          _isEdit ? 'Data berhasil diperbarui' : 'Data industri berhasil disimpan',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan: $e', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
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
              _isEdit ? 'Edit Data Industri' : 'Tambah Industri Rumah Tangga',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Pencatatan Komoditi & Volume Usaha',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5)),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('Simpan',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primary)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // ── IDENTITAS PELAKU ──
            _sectionHeader(Icons.person_rounded, 'Identitas Pelaku Usaha',
                'Data kepala keluarga & lokasi'),
            const SizedBox(height: 14),

            _field(
              ctrl: _namaKKCtrl,
              label: 'Nama Kepala Keluarga',
              hint: 'Masukkan nama kepala keluarga',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    ctrl: _rtCtrl,
                    label: 'RT',
                    hint: '001',
                    icon: Icons.location_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    ctrl: _rwCtrl,
                    label: 'RW',
                    hint: '003',
                    icon: Icons.location_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _field(
              ctrl: _dasaWismaCtrl,
              label: 'Dasa Wisma',
              hint: 'Nama kelompok Dasa Wisma',
              icon: Icons.holiday_village_outlined,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    label: 'Bulan',
                    value: _bulan,
                    items: _bulanList,
                    onChanged: (v) => setState(() => _bulan = v!),
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    label: 'Tahun',
                    value: _tahun,
                    items: _tahunList,
                    onChanged: (v) => setState(() => _tahun = v!),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── DAFTAR INDUSTRI ──
            _sectionHeader(Icons.storefront_rounded, 'Daftar Industri Rumah Tangga',
                'Pilih kategori lalu isi komoditi & volume'),
            const SizedBox(height: 14),

            ...List.generate(_items.length, (i) => _buildItemCard(i)),

            const SizedBox(height: 10),

            // Tombol Tambah
            OutlinedButton.icon(
              onPressed: _tambahItem,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text(
                'Tambah Usaha Lainnya',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(color: _primary.withValues(alpha: 0.4), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 24),

            // Catatan
            _field(
              ctrl: _catatanCtrl,
              label: 'Catatan Tambahan (Opsional)',
              hint: 'Tambahkan catatan jika diperlukan...',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        _isEdit ? 'Perbarui Data' : 'Simpan Data Industri',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final kategoriList = _kategoriKomoditi.keys.toList();
    final komoditiList = item.kategori != null
        ? _kategoriKomoditi[item.kategori!] ?? []
        : <String>[];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.kategori != null
              ? _primary.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: item.kategori != null ? 1.5 : 1,
        ),
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
          // Header kartu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: item.kategori != null ? _primaryLight : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.kategori != null
                        ? _primary.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 16,
                    color: item.kategori != null ? _primary : Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usaha ${index + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: item.kategori != null
                          ? _primary
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                if (_items.length > 1)
                  GestureDetector(
                    onTap: () => _hapusItem(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 14, color: Colors.red[400]),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Pilih Kategori ──
                _labelText('Kategori Usaha'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kategoriList.map((k) {
                    final selected = item.kategori == k;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (item.kategori == k) {
                            item.kategori = null;
                            item.komoditi = '';
                          } else {
                            item.kategori = k;
                            item.komoditi = '';
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? _primary : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? _primary : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.check_circle_rounded,
                                    size: 13, color: Colors.white),
                              ),
                            Text(
                              k,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // ── Pilih Komoditi (muncul setelah kategori dipilih) ──
                if (item.kategori != null) ...[
                  const SizedBox(height: 16),
                  _labelText('Komoditi / Jenis Produk'),
                  const SizedBox(height: 8),
                  komoditiList.isEmpty
                      ? _fieldInline(
                          hint: 'Masukkan nama komoditi',
                          value: item.komoditi,
                          onChanged: (v) => setState(() => item.komoditi = v),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...komoditiList.where((k) => k != 'Lainnya').map((k) {
                              final sel = item.komoditi == k;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => item.komoditi = sel ? '' : k);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sel
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (sel)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Icon(Icons.check_rounded,
                                              size: 12, color: Colors.white),
                                        ),
                                      Text(
                                        k,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: sel
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            // Chip "Lainnya" → muncul text field
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  // Jika bukan salah satu dari preset, tetap di "Lainnya"
                                  final isPreset = komoditiList
                                      .where((k) => k != 'Lainnya')
                                      .contains(item.komoditi);
                                  if (isPreset || item.komoditi.isEmpty) {
                                    item.komoditi = ' '; // trigger ke text field
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (!komoditiList
                                              .where((k) => k != 'Lainnya')
                                              .contains(item.komoditi) &&
                                          item.komoditi.isNotEmpty)
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: (!komoditiList
                                                .where((k) => k != 'Lainnya')
                                                .contains(item.komoditi) &&
                                            item.komoditi.isNotEmpty)
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  'Lainnya...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: (!komoditiList
                                                .where((k) => k != 'Lainnya')
                                                .contains(item.komoditi) &&
                                            item.komoditi.isNotEmpty)
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                  // TextField muncul jika "Lainnya" atau isian bebas
                  if (!komoditiList
                          .where((k) => k != 'Lainnya')
                          .contains(item.komoditi) &&
                      item.komoditi.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _fieldInline(
                      hint: 'Ketik nama komoditi lainnya...',
                      value: item.komoditi.trim(),
                      onChanged: (v) => setState(() => item.komoditi = v),
                    ),
                  ],

                  // ── Volume ──
                  const SizedBox(height: 16),
                  _labelText('Volume / Jumlah Produksi'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: item.volumeCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 50 kg/bulan, 100 pcs, 200 liter...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.scale_outlined,
                            size: 18, color: Color(0xFF7C3AED)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _fieldInline({
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        initialValue: value.trim(),
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.edit_outlined,
              size: 17, color: Color(0xFF7C3AED)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A))),
            Text(subtitle,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5, color: const Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: _primary),
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: Colors.grey[400]),
          labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: const Color(0xFF64748B)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: _primary),
          labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: const Color(0xFF64748B)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: items
            .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ── State per item industri ──
class _ItemState {
  String? kategori;
  String komoditi;
  final TextEditingController volumeCtrl;

  _ItemState({this.kategori, this.komoditi = '', String volume = ''})
      : volumeCtrl = TextEditingController(text: volume);

  void dispose() => volumeCtrl.dispose();
}
