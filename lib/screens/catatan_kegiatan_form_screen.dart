// lib/screens/catatan_kegiatan_form_screen.dart

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

  // Controllers untuk data angka pokja (diinisialisasi di initState)
  final Map<String, TextEditingController> _angkaCtrl = {};

  // Index kegiatan yang dipilih per pokja (default 0 = pilihan pertama)
  final Map<PokjaKategori, int> _selectedKegiatanIdx = {
    PokjaKategori.pokja1: 0,
    PokjaKategori.pokja2: 0,
    PokjaKategori.pokja3: 0,
    PokjaKategori.pokja4: 0,
  };

  PokjaKategori _kategori = PokjaKategori.pokja1;
  String _selectedKecamatan = 'Singaparna';
  File? _fotoFile;
  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua controller untuk semua field angka pokja
    final allFields = [
      ...PokjaKategori.pokja1.fieldAngka,
      ...PokjaKategori.pokja2.fieldAngka,
      ...PokjaKategori.pokja3.fieldAngka,
      ...PokjaKategori.pokja4.fieldAngka,
    ];
    for (final f in allFields) {
      _angkaCtrl[f] = TextEditingController();
    }

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
      // Isi nilai angka dari data yang ada
      for (final f in allFields) {
        final val = c.dataAngka[f];
        if (val != null && val != 0) {
          _angkaCtrl[f]!.text = val.toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _desaController.dispose();
    for (final c in _angkaCtrl.values) {
      c.dispose();
    }
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
                Text(
                  'Pilih Wilayah Kecamatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daftar 39 kecamatan di Kabupaten Tasikmalaya',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari kecamatan...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (q) {
                    setModalState(() {
                      filteredList = CatatanKegiatan.daftar39Kecamatan
                          .where((k) => k.toLowerCase().contains(q.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final kec = filteredList[index];
                      final isSelected = kec == _selectedKecamatan;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        title: Text(
                          kec,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 20)
                            : null,
                        onTap: () {
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
    HapticFeedback.selectionClick();
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

    try {
      // Kumpulkan data angka dari controller
      final Map<String, int> dataAngka = {};
      for (final entry in _angkaCtrl.entries) {
        final val = int.tryParse(entry.value.text.trim());
        if (val != null) dataAngka[entry.key] = val;
      }

      final item = CatatanKegiatan(
        id: widget.catatan?.id ?? 0,
        judul: _judulController.text.trim(),
        deskripsiSingkat: _deskripsiController.text.trim(),
        kategori: _kategori,
        dataAngka: dataAngka,
        kecamatan: _selectedKecamatan,
        desa: _desaController.text.trim().isEmpty ? null : _desaController.text.trim(),
        fotoPath: _fotoFile?.path,
        tanggal: _tanggal,
      );

      await _service.kirim(item);

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
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal: ${e.toString().replaceFirst('Exception: ', '')}',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getPokjaColor(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return const Color(0xFF3B82F6); // Blue
      case PokjaKategori.pokja2:
        return const Color(0xFF10B981); // Emerald
      case PokjaKategori.pokja3:
        return const Color(0xFFF59E0B); // Amber
      case PokjaKategori.pokja4:
        return const Color(0xFFEF4444); // Red
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Section input data angka: pilih kegiatan dulu, lalu isi angka
  // ─────────────────────────────────────────────────────────────
  Widget _buildDataAngkaSection() {
    final color = _getPokjaColor(_kategori);
    final colorBg = color.withOpacity(0.08);

    // Definisi kegiatan per pokja
    final List<_PokjaGroup> groups;
    switch (_kategori) {
      case PokjaKategori.pokja1:
        groups = [
          _PokjaGroup('PKBN', ['pkbn_l', 'pkbn_p']),
          _PokjaGroup('PKDRT', ['pkdrt_l', 'pkdrt_p']),
          _PokjaGroup('Pola Asuh', ['pola_asuh_l', 'pola_asuh_p']),
          _PokjaGroup('Lansia', ['lansia_l', 'lansia_p']),
          _PokjaGroup('Kader Pokja I', ['kader_pokja1_l', 'kader_pokja1_p']),
        ];
        break;
      case PokjaKategori.pokja2:
        groups = [
          _PokjaGroup('Warga Buta Aksara', ['warga_buta_l', 'warga_buta_p']),
          _PokjaGroup('Kelompok Belajar', [
            'kelompok_belajar_paket_a',
            'kelompok_belajar_paket_b',
            'kelompok_belajar_paket_c',
          ]),
          _PokjaGroup('KF', ['kf']),
          _PokjaGroup('PAUD', ['paud']),
          _PokjaGroup('Koperasi', ['koperasi_berbadan_hukum']),
        ];
        break;
      case PokjaKategori.pokja3:
        groups = [
          _PokjaGroup('Rumah Sehat', ['rumah_sehat']),
          _PokjaGroup('Rumah Tidak Sehat', ['rumah_tidak_sehat']),
          _PokjaGroup('Pemanfaatan Pekarangan', ['pemanfaatan_pekarangan']),
          _PokjaGroup('Industri Rumah Tangga', ['industri_rumah_tangga']),
        ];
        break;
      case PokjaKategori.pokja4:
        groups = [
          _PokjaGroup('Posyandu', ['posyandu']),
          _PokjaGroup('Akseptor KB', ['akseptor_kb']),
          _PokjaGroup('PHBS', ['phbs']),
          _PokjaGroup('Jamban Keluarga', ['jamban_keluarga']),
        ];
        break;
    }

    final selectedIdx = _selectedKegiatanIdx[_kategori]!;
    final selectedGroup = groups[selectedIdx];

    // Sub-label per field
    String subLabel(String field) {
      if (field.endsWith('_l')) return 'Laki-laki (L)';
      if (field.endsWith('_p')) return 'Perempuan (P)';
      if (field.endsWith('_paket_a')) return 'Paket A';
      if (field.endsWith('_paket_b')) return 'Paket B';
      if (field.endsWith('_paket_c')) return 'Paket C';
      return 'Jumlah';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Judul seksi ──
        Text(
          'Kegiatan ${_kategori.shortLabel}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih jenis kegiatan, lalu isi data jumlah peserta',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 12),

        // ── Chip pilih kegiatan ──
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(groups.length, (i) {
            final isActive = i == selectedIdx;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedKegiatanIdx[_kategori] = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? color : const Color(0xFFCBD5E1),
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  groups[i].label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // ── Card input angka untuk kegiatan yang dipilih ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Container(
            key: ValueKey('${_kategori}_$selectedIdx'),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul kegiatan terpilih
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_note_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedGroup.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Input fields
                ...selectedGroup.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            subLabel(field),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _angkaCtrl[field],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '0',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: color.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: color.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: color, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
            InkWell(
              onTap: _pilihFoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: _fotoFile != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_fotoFile!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ganti Foto',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_a_photo_rounded,
                                color: Color(0xFF3B82F6), size: 28),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Pilih atau Ambil Foto',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kamera atau Galeri ponsel',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[400]),
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
              childAspectRatio: 2.4,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color.withOpacity(isSelected ? 0.9 : 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              pokja.shortLabel.replaceAll('Pokja ', ''),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pokja.shortLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
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

            // ── 2b. KEGIATAN & DATA ANGKA POKJA ──
            _buildDataAngkaSection(),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ubah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 2),
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

/// Helper class: mendefinisikan satu grup kolom dalam tabel data angka pokja.
class _PokjaGroup {
  final String label;
  final List<String> fields;
  const _PokjaGroup(this.label, this.fields);
}