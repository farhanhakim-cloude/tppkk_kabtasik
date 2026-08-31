import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/catatan_kegiatan.dart';
import '../services/catatan_kegiatan_service.dart';

class CatatanKegiatanFormScreen extends StatefulWidget {
  final CatatanKegiatan? catatan;

  const CatatanKegiatanFormScreen({super.key, this.catatan});

  @override
  State<CatatanKegiatanFormScreen> createState() => _CatatanKegiatanFormScreenState();
}

class _CatatanKegiatanFormScreenState extends State<CatatanKegiatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CatatanKegiatanService();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _desaController = TextEditingController();

  PokjaKategori _kategori = PokjaKategori.pokja1;
  String _selectedKecamatan = 'Singaparna';
  File? _fotoFile;
  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.catatan != null) {
      final c = widget.catatan!;
      _judulController.text = c.judul;
      _deskripsiController.text = c.deskripsiSingkat;
      _desaController.text = c.desa ?? '';
      _kategori = c.kategori;
      _selectedKecamatan = c.kecamatan;
      _tanggal = c.tanggal;
      if (c.fotoPath != null) {
        _fotoFile = File(c.fotoPath!);
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _desaController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    HapticFeedback.lightImpact();
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3B82F6)),
                ),
                title: Text('Ambil dari Kamera',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                ),
                title: Text('Pilih dari Galeri',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (sumber == null) return;
    try {
      final gambar = await _picker.pickImage(source: sumber, imageQuality: 75, maxWidth: 1280);
      if (gambar != null) {
        setState(() => _fotoFile = File(gambar.path));
      }
    } catch (_) {
      // Fallback jika tidak ada akses kamera
    }
  }

  void _showKecamatanPicker() {
    HapticFeedback.selectionClick();
    final searchCtrl = TextEditingController();
    List<String> filteredList = List.from(CatatanKegiatan.daftar39Kecamatan);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Wilayah Kecamatan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '39 Kecamatan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Daftar kecamatan di Kabupaten Tasikmalaya',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[500]),
                ),
                const SizedBox(height: 14),
                // Search Box
                TextField(
                  controller: searchCtrl,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari nama kecamatan...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setModalState(() {
                      filteredList = CatatanKegiatan.daftar39Kecamatan
                          .where((k) => k.toLowerCase().contains(val.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 12),
                // List of Kecamatans
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, idx) {
                      final kec = filteredList[idx];
                      final isSelected = kec == _selectedKecamatan;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B82F6).withOpacity(0.12)
                                : const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[400],
                          ),
                        ),
                        title: Text(
                          kec,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 20)
                            : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedKecamatan = kec);
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
    );
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _tanggal = picked);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final item = CatatanKegiatan(
      id: widget.catatan?.id ?? 0,
      judul: _judulController.text.trim(),
      deskripsiSingkat: _deskripsiController.text.trim(),
      kategori: _kategori,
      kecamatan: _selectedKecamatan,
      desa: _desaController.text.trim().isEmpty ? null : _desaController.text.trim(),
      fotoPath: _fotoFile?.path,
      tanggal: _tanggal,
    );

    await _service.save(item);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Catatan kegiatan Pokja berhasil disimpan',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Color _getPokjaColor(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return const Color(0xFF3B82F6); // Blue
      case PokjaKategori.pokja2:
        return const Color(0xFF8B5CF6); // Purple
      case PokjaKategori.pokja3:
        return const Color(0xFF10B981); // Emerald
      case PokjaKategori.pokja4:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
          widget.catatan != null ? 'Edit Catatan Pokja' : 'Tambah Catatan Pokja',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── 1. FOTO KEGIATAN ──
            Text(
              'Foto Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unggah dokumentasi foto pelaksanaan kegiatan',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pilihFoto,
              child: Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _fotoFile != null ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                    width: _fotoFile != null ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _fotoFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_fotoFile!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                      onPressed: _pilihFoto,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  CircleAvatar(
                                    backgroundColor: Colors.red.withOpacity(0.85),
                                    radius: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                      onPressed: () => setState(() => _fotoFile = null),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_a_photo_rounded, color: primary, size: 30),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ketuk untuk Ambil / Unggah Foto Kegiatan',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Kamera atau Galeri ponsel',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey[400]),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 22),

            // ── 2. PILIH KATEGORI POKJA ──
            Text(
              'Kategori Pokja',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih kelompok kerja (Pokja I - IV) yang sesuai',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: PokjaKategori.values.map((pokja) {
                final isSelected = _kategori == pokja;
                final color = _getPokjaColor(pokja);
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _kategori = pokja);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withOpacity(isSelected ? 0.9 : 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              pokja.shortLabel.replaceAll('Pokja ', ''),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pokja.shortLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isSelected ? color : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                pokja == PokjaKategori.pokja1
                                    ? 'Gotong Royong'
                                    : pokja == PokjaKategori.pokja2
                                        ? 'Pendidikan & UP2K'
                                        : pokja == PokjaKategori.pokja3
                                            ? 'Pangan & Sandang'
                                            : 'Kesehatan & Lingk.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // ── 3. PILIHAN WILAYAH KECAMATAN (39 KECAMATAN) ──
            Text(
              'Wilayah Kecamatan (39 Kecamatan)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih lokasi kecamatan tempat kegiatan berlangsung',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _showKecamatanPicker,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_city_rounded,
                          color: Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kecamatan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _selectedKecamatan,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Ubah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF3B82F6), size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Optional Desa
            TextFormField(
              controller: _desaController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Desa / Kelurahan (Opsional)',
                hintText: 'Contoh: Desa Cipakat',
                prefixIcon: const Icon(Icons.holiday_village_outlined, size: 20),
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ── 4. JUDUL KEGIATAN ──
            Text(
              'Judul Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _judulController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Contoh: Sosialisasi Pencegahan Stunting Pokja IV',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul kegiatan wajib diisi' : null,
            ),
            const SizedBox(height: 22),

            // ── 5. DESKRIPSI SINGKAT ──
            Text(
              'Deskripsi Singkat Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _deskripsiController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan rincian singkat pelaksanaan kegiatan, hasil yang dicapai, dan jumlah peserta...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi singkat wajib diisi' : null,
            ),
            const SizedBox(height: 22),

            // ── 6. TANGGAL KEGIATAN ──
            InkWell(
              onTap: _pilihTanggal,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Color(0xFF3B82F6), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Kegiatan',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500])),
                          Text(
                            '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Pilih',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ── 7. TOMBOL SIMPAN ──
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpan,
                icon: _isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Simpan Catatan Pokja',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
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