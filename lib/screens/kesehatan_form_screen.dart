import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kesehatan.dart';
import '../services/kesehatan_service.dart';

class KesehatanFormScreen extends StatefulWidget {
  final DataKesehatan? data;
  final KategoriKesehatan kategoriAwal;

  const KesehatanFormScreen({super.key, this.data, required this.kategoriAwal});

  @override
  State<KesehatanFormScreen> createState() => _KesehatanFormScreenState();
}

class _KesehatanFormScreenState extends State<KesehatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KesehatanService();

  static const Color _primaryBlue = Color(0xFF0D9488);

  late KategoriKesehatan _kategori;
  late final TextEditingController _namaIbuController;
  late final TextEditingController _namaAnakController;
  late final TextEditingController _usiaController;
  String _statusGizi = 'Normal';
  late final TextEditingController _rtController;
  late final TextEditingController _rwController;

  bool _saving = false;
  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _kategori = d?.kategori ?? widget.kategoriAwal;
    _namaIbuController = TextEditingController(text: d?.namaIbu ?? '');
    _namaAnakController = TextEditingController(text: d?.namaAnak ?? '');
    _usiaController = TextEditingController(text: d?.usiaKehamilanAtauAnak ?? '');
    _statusGizi = (d?.statusGizi != null && d!.statusGizi != '-') ? d.statusGizi : 'Normal';
    _rtController = TextEditingController(text: d?.rt ?? '');
    _rwController = TextEditingController(text: d?.rw ?? '');
  }

  @override
  void dispose() {
    _namaIbuController.dispose();
    _namaAnakController.dispose();
    _usiaController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final isChild = _kategori == KategoriKesehatan.balita || _kategori == KategoriKesehatan.anak;

    final data = DataKesehatan(
      id: widget.data?.id ?? 0,
      namaIbu: _namaIbuController.text.trim(),
      namaAnak: isChild ? _namaAnakController.text.trim() : '',
      kategori: _kategori,
      usiaKehamilanAtauAnak: _usiaController.text.trim(),
      statusGizi: isChild ? _statusGizi : '-',
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
    );

    if (_isEdit) {
      await _service.update(data);
    } else {
      await _service.add(data);
    }

    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Data KIA berhasil diperbarui' : 'Data KIA berhasil ditambahkan',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus data?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17)),
        content: Text('Data kesehatan ini akan dihapus permanen dari daftar.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(widget.data!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChild = _kategori == KategoriKesehatan.balita || _kategori == KategoriKesehatan.anak;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Data Kesehatan' : 'Tambah Data Kesehatan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── KATEGORI SELECTOR ──
            Text('Kategori Sasaran',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: KategoriKesehatan.values.map((kat) {
                final isSelected = kat == _kategori;
                return ChoiceChip(
                  label: Text(kat.label),
                  selected: isSelected,
                  selectedColor: _primaryBlue,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  side: BorderSide(
                    color: isSelected ? _primaryBlue : const Color(0xFFCBD5E1),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _kategori = kat);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── NAMA IBU ──
            Text('Nama Lengkap Ibu',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaIbuController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Contoh: Siti Aminah',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: _primaryBlue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama ibu wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // ── NAMA ANAK (JIKA BALITA / ANAK) ──
            if (isChild) ...[
              Text('Nama Anak',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaAnakController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: Muhammad Raka',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.child_care_rounded, size: 20, color: _primaryBlue),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama anak wajib diisi' : null,
              ),
              const SizedBox(height: 16),
            ],

            // ── USIA ──
            Text(
              isChild
                  ? 'Usia Anak (Bulan / Tahun)'
                  : _kategori == KategoriKesehatan.ibuHamil
                      ? 'Usia Kehamilan (Minggu)'
                      : 'Usia Bayi Menyusui (Bulan)',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usiaController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: isChild ? 'Contoh: 18 bulan' : 'Contoh: 28 minggu',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: _primaryBlue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Usia wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // ── STATUS GIZI (JIKA BALITA / ANAK) ──
            if (isChild) ...[
              Text('Status Gizi',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Row(
                children: ['Normal', 'Kurang', 'Lebih'].map((st) {
                  final isSel = _statusGizi == st;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _statusGizi = st);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? _primaryBlue.withOpacity(0.12) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? _primaryBlue : const Color(0xFFCBD5E1),
                              width: isSel ? 1.8 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              st,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? _primaryBlue : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ── WILAYAH RT / RW ──
            Text('Wilayah RT & RW',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rtController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'RT',
                      hintText: 'Contoh: 02',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rwController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'RW',
                      hintText: 'Contoh: 05',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── TOMBOL SIMPAN ──
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        _isEdit ? 'Simpan Perubahan' : 'Simpan Data KIA',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}