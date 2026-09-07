import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/data_keluarga_dasawisma.dart';
import '../services/data_keluarga_dasawisma_service.dart';

class DataKeluargaDasawismaFormScreen extends StatefulWidget {
  final DataKeluargaDasawisma? data;
  const DataKeluargaDasawismaFormScreen({super.key, this.data});

  @override
  State<DataKeluargaDasawismaFormScreen> createState() => _DataKeluargaDasawismaFormScreenState();
}

class _DataKeluargaDasawismaFormScreenState extends State<DataKeluargaDasawismaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DataKeluargaDasawismaService();

  late TextEditingController _dasaWismaCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  late TextEditingController _desaCtrl;
  late TextEditingController _kecamatanCtrl;
  late TextEditingController _namaKepalaRtCtrl;
  late TextEditingController _jmlLakiCtrl;
  late TextEditingController _jmlPerempuanCtrl;

  // Rekapitulasi 1-2
  late TextEditingController _jmlKkCtrl;
  late TextEditingController _jmlBalitaCtrl;
  late TextEditingController _jmlAnakCtrl;
  late TextEditingController _jmlPusCtrl;
  late TextEditingController _jmlWusCtrl;
  late TextEditingController _jmlTigaButaCtrl;
  late TextEditingController _jmlBumilCtrl;
  late TextEditingController _jmlBusuiCtrl;
  late TextEditingController _jmlLansiaCtrl;

  // Tabel Anggota List
  List<AnggotaKeluargaItem> _anggotaList = [];

  // Poin 3-10
  String _makananPokok = 'Beras';
  bool _mempunyaiMck = true;
  late TextEditingController _jmlMckCtrl;
  String _sumberAir = 'Sumur';
  bool _memilikiTempatSampah = true;
  bool _mempunyaiSpal = true;
  String _kriteriaRumah = 'Sehat';
  bool _aktifitasUp2k = false;
  late TextEditingController _jenisUsahaUp2kCtrl;
  bool _aktifitasKesling = true;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _dasaWismaCtrl = TextEditingController(text: d?.dasaWisma ?? 'Mawar 01');
    _rtCtrl = TextEditingController(text: d?.rt ?? '01');
    _rwCtrl = TextEditingController(text: d?.rw ?? '05');
    _desaCtrl = TextEditingController(text: d?.desa ?? 'Singaparna');
    _kecamatanCtrl = TextEditingController(text: d?.kecamatan ?? 'Singaparna');
    _namaKepalaRtCtrl = TextEditingController(text: d?.namaKepalaRumahTangga ?? '');
    _jmlLakiCtrl = TextEditingController(text: d?.jumlahLakiLaki.toString() ?? '2');
    _jmlPerempuanCtrl = TextEditingController(text: d?.jumlahPerempuan.toString() ?? '2');

    _jmlKkCtrl = TextEditingController(text: d?.jumlahKk.toString() ?? '1');
    _jmlBalitaCtrl = TextEditingController(text: d?.jumlahBalita.toString() ?? '1');
    _jmlAnakCtrl = TextEditingController(text: d?.jumlahAnak.toString() ?? '1');
    _jmlPusCtrl = TextEditingController(text: d?.jumlahPus.toString() ?? '1');
    _jmlWusCtrl = TextEditingController(text: d?.jumlahWus.toString() ?? '1');
    _jmlTigaButaCtrl = TextEditingController(text: d?.jumlahTigaButa.toString() ?? '0');
    _jmlBumilCtrl = TextEditingController(text: d?.jumlahIbuHamil.toString() ?? '0');
    _jmlBusuiCtrl = TextEditingController(text: d?.jumlahIbuMenyusui.toString() ?? '1');
    _jmlLansiaCtrl = TextEditingController(text: d?.jumlahLansia.toString() ?? '0');

    _anggotaList = d != null ? List.from(d.anggotaList) : [];

    _makananPokok = d?.makananPokok ?? 'Beras';
    _mempunyaiMck = d?.mempunyaiMck ?? true;
    _jmlMckCtrl = TextEditingController(text: d?.jumlahMckSepticTank.toString() ?? '1');
    _sumberAir = d?.sumberAir ?? 'Sumur';
    _memilikiTempatSampah = d?.memilikiTempatSampah ?? true;
    _mempunyaiSpal = d?.mempunyaiSpal ?? true;
    _kriteriaRumah = d?.kriteriaRumah ?? 'Sehat';
    _aktifitasUp2k = d?.aktifitasUp2k ?? false;
    _jenisUsahaUp2kCtrl = TextEditingController(text: d?.jenisUsahaUp2k ?? '');
    _aktifitasKesling = d?.aktifitasKesehatanLingkungan ?? true;
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _desaCtrl.dispose();
    _kecamatanCtrl.dispose();
    _namaKepalaRtCtrl.dispose();
    _jmlLakiCtrl.dispose();
    _jmlPerempuanCtrl.dispose();
    _jmlKkCtrl.dispose();
    _jmlBalitaCtrl.dispose();
    _jmlAnakCtrl.dispose();
    _jmlPusCtrl.dispose();
    _jmlWusCtrl.dispose();
    _jmlTigaButaCtrl.dispose();
    _jmlBumilCtrl.dispose();
    _jmlBusuiCtrl.dispose();
    _jmlLansiaCtrl.dispose();
    _jmlMckCtrl.dispose();
    _jenisUsahaUp2kCtrl.dispose();
    super.dispose();
  }

  void _tambahAnggotaDialog({int? editIndex}) {
    final item = editIndex != null ? _anggotaList[editIndex] : null;
    final noRegCtrl = TextEditingController(text: item?.noReg ?? '00${_anggotaList.length + 1}');
    final namaCtrl = TextEditingController(text: item?.nama ?? '');
    String statusDalamKeluarga = item?.statusDalamKeluarga ?? 'Suami';
    String statusKawin = item?.statusPerkawinan ?? 'Kawin';
    String jk = item?.jenisKelamin ?? 'L';
    final tglUmurCtrl = TextEditingController(text: item?.tanggalLahirUmur ?? '');
    String pendidikan = item?.pendidikan ?? 'SMA/SMK/Sederajat';
    final pekerjaanCtrl = TextEditingController(text: item?.pekerjaan ?? 'Swasta');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                editIndex == null ? 'Tambah Anggota Keluarga' : 'Edit Anggota Keluarga',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: noRegCtrl, decoration: const InputDecoration(labelText: 'No. REG')),
                    const SizedBox(height: 10),
                    TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Anggota Keluarga *')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: statusDalamKeluarga,
                      decoration: const InputDecoration(labelText: 'Status Dalam Keluarga'),
                      items: ['Suami', 'Istri', 'Anak', 'Menantu', 'Orang Tua', 'Keluarga Lain'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (v) => setDlgState(() => statusDalamKeluarga = v!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: statusKawin,
                      decoration: const InputDecoration(labelText: 'Status Perkawinan'),
                      items: ['Kawin', 'Tidak Kawin'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (v) => setDlgState(() => statusKawin = v!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Jenis Kelamin: '),
                        Radio<String>(value: 'L', groupValue: jk, onChanged: (v) => setDlgState(() => jk = v!)),
                        const Text('L'),
                        Radio<String>(value: 'P', groupValue: jk, onChanged: (v) => setDlgState(() => jk = v!)),
                        const Text('P'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: tglUmurCtrl, decoration: const InputDecoration(labelText: 'Tanggal Lahir / Umur')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: pendidikan,
                      decoration: const InputDecoration(labelText: 'Pendidikan'),
                      items: ['Tidak Tamat SD', 'SD/MI', 'SMP/Sederajat', 'SMA/SMK/Sederajat', 'Diploma', 'S1', 'S2', 'S3'].map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (v) => setDlgState(() => pendidikan = v!),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: pekerjaanCtrl, decoration: const InputDecoration(labelText: 'Pekerjaan')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans())),
                ElevatedButton(
                  onPressed: () {
                    if (namaCtrl.text.trim().isEmpty) return;
                    final newItem = AnggotaKeluargaItem(
                      noReg: noRegCtrl.text.trim(),
                      nama: namaCtrl.text.trim(),
                      statusDalamKeluarga: statusDalamKeluarga,
                      statusPerkawinan: statusKawin,
                      jenisKelamin: jk,
                      tanggalLahirUmur: tglUmurCtrl.text.trim(),
                      pendidikan: pendidikan,
                      pekerjaan: pekerjaanCtrl.text.trim(),
                    );
                    setState(() {
                      if (editIndex != null) {
                        _anggotaList[editIndex] = newItem;
                      } else {
                        _anggotaList.add(newItem);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final record = DataKeluargaDasawisma(
      id: widget.data?.id ?? 0,
      dasaWisma: _dasaWismaCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecamatanCtrl.text.trim(),
      namaKepalaRumahTangga: _namaKepalaRtCtrl.text.trim(),
      jumlahLakiLaki: int.tryParse(_jmlLakiCtrl.text) ?? 0,
      jumlahPerempuan: int.tryParse(_jmlPerempuanCtrl.text) ?? 0,
      jumlahKk: int.tryParse(_jmlKkCtrl.text) ?? 1,
      jumlahBalita: int.tryParse(_jmlBalitaCtrl.text) ?? 0,
      jumlahAnak: int.tryParse(_jmlAnakCtrl.text) ?? 0,
      jumlahPus: int.tryParse(_jmlPusCtrl.text) ?? 0,
      jumlahWus: int.tryParse(_jmlWusCtrl.text) ?? 0,
      jumlahTigaButa: int.tryParse(_jmlTigaButaCtrl.text) ?? 0,
      jumlahIbuHamil: int.tryParse(_jmlBumilCtrl.text) ?? 0,
      jumlahIbuMenyusui: int.tryParse(_jmlBusuiCtrl.text) ?? 0,
      jumlahLansia: int.tryParse(_jmlLansiaCtrl.text) ?? 0,
      anggotaList: _anggotaList,
      makananPokok: _makananPokok,
      mempunyaiMck: _mempunyaiMck,
      jumlahMckSepticTank: int.tryParse(_jmlMckCtrl.text) ?? 1,
      sumberAir: _sumberAir,
      memilikiTempatSampah: _memilikiTempatSampah,
      mempunyaiSpal: _mempunyaiSpal,
      kriteriaRumah: _kriteriaRumah,
      aktifitasUp2k: _aktifitasUp2k,
      jenisUsahaUp2k: _aktifitasUp2k ? _jenisUsahaUp2kCtrl.text.trim() : '',
      aktifitasKesehatanLingkungan: _aktifitasKesling,
    );

    await _service.save(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data Keluarga Dasawisma berhasil disimpan!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.data == null ? 'Input Data Keluarga Dasawisma' : 'Edit Data Keluarga Dasawisma',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER HEADER DOCUMENT TITLE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATA KELUARGA (DASAWISMA)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Formulir Rekapitulasi Data Anggota Keluarga & Kriteria Rumah Tangga',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── HEADER IDENTITAS ──
              _buildSectionTitle(Icons.location_on_rounded, 'Identitas Dasa Wisma', primary),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _dasaWismaCtrl,
                        decoration: const InputDecoration(labelText: 'Dasa Wisma *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _rtCtrl, decoration: const InputDecoration(labelText: 'RT'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _rwCtrl, decoration: const InputDecoration(labelText: 'RW'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _desaCtrl, decoration: const InputDecoration(labelText: 'Desa'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _kecamatanCtrl, decoration: const InputDecoration(labelText: 'Kecamatan'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _namaKepalaRtCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Kepala Rumah Tangga *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _jmlLakiCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Anggota Laki-laki'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _jmlPerempuanCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Anggota Perempuan'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── 1-2: REKAPITULASI KATEGORI ──
              _buildSectionTitle(Icons.analytics_rounded, '1-2. Rekapitulasi Jumlah Anggota', primary),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(controller: _jmlKkCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '1. Jumlah KK')),
                      const SizedBox(height: 12),
                      Text('2. Jumlah Kategori Anggota:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _jmlBalitaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Balita'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _jmlAnakCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Anak'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _jmlPusCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PUS (Pasangan Usia Subur)'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _jmlWusCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'WUS (Wanita Usia Subur)'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _jmlTigaButaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '3 Buta (Baca, Tulis, Hitung)'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _jmlBumilCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ibu Hamil'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _jmlBusuiCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ibu Menyusui'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _jmlLansiaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'LANSIA'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── TABEL ANGGOTA KELUARGA ──
              _buildSectionTitle(Icons.people_alt_rounded, 'Tabel Daftar Anggota Keluarga (Kolom 1-10)', primary),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daftar Anggota (${_anggotaList.length})', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          OutlinedButton.icon(
                            onPressed: () => _tambahAnggotaDialog(),
                            icon: const Icon(Icons.add, size: 16),
                            label: Text('Tambah Row', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_anggotaList.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text('Belum ada anggota keluarga ditambahkan. Ketuk "+ Tambah Row"', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500])),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _anggotaList.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, idx) {
                            final m = _anggotaList[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${idx + 1}. ${m.nama} (${m.jenisKelamin})', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              subtitle: Text(
                                'Status: ${m.statusDalamKeluarga} • ${m.statusPerkawinan}\nLahir: ${m.tanggalLahirUmur} • Educ: ${m.pendidikan}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _tambahAnggotaDialog(editIndex: idx)),
                                  IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setState(() => _anggotaList.removeAt(idx))),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // ── 3-10: FASILITAS & RUMAH TANGGA ──
              _buildSectionTitle(Icons.home_work_rounded, '3-10. Kriteria Rumah & Lingkungan', primary),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Makanan Pokok
                      Text('3. Makanan Pokok Sehari-hari:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      Row(
                        children: ['Beras', 'Non Beras'].map((m) {
                          final isSel = _makananPokok == m;
                          return ChoiceChip(
                            label: Text(m),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(color: isSel ? primary : Colors.grey[700], fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                            onSelected: (v) { if (v) setState(() => _makananPokok = m); },
                          );
                        }).toList(),
                      ),
                      const Divider(),

                      // 4. MCK
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('4. Mempunyai Sarana MCK & Septic Tank?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _mempunyaiMck,
                        onChanged: (v) => setState(() => _mempunyaiMck = v),
                      ),
                      if (_mempunyaiMck)
                        TextFormField(controller: _jmlMckCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Septic Tank (Buah)')),
                      const Divider(),

                      // 5. Sumber Air
                      Text('5. Sumber Air Keluarga:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      Wrap(
                        spacing: 6,
                        children: ['PDAM', 'Sumur', 'Sungai', 'Lainnya'].map((sa) {
                          final isSel = _sumberAir == sa;
                          return ChoiceChip(
                            label: Text(sa),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(color: isSel ? primary : Colors.grey[700], fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                            onSelected: (v) { if (v) setState(() => _sumberAir = sa); },
                          );
                        }).toList(),
                      ),
                      const Divider(),

                      // 6. Tempat Sampah
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('6. Memiliki Tempat Pembuangan Sampah?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _memilikiTempatSampah,
                        onChanged: (v) => setState(() => _memilikiTempatSampah = v),
                      ),
                      const Divider(),

                      // 7. SPAL
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('7. Mempunyai SPAL (Pembuangan Air Limbah)?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _mempunyaiSpal,
                        onChanged: (v) => setState(() => _mempunyaiSpal = v),
                      ),
                      const Divider(),

                      // 8. Kriteria Rumah
                      Text('8. Kriteria Rumah:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      Row(
                        children: ['Sehat', 'Kurang Sehat'].map((k) {
                          final isSel = _kriteriaRumah == k;
                          return ChoiceChip(
                            label: Text(k),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(color: isSel ? primary : Colors.grey[700], fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                            onSelected: (v) { if (v) setState(() => _kriteriaRumah = k); },
                          );
                        }).toList(),
                      ),
                      const Divider(),

                      // 9. UP2K
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('9. Aktifitas UP2K (Usaha Peningkatan Pendapatan)?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _aktifitasUp2k,
                        onChanged: (v) => setState(() => _aktifitasUp2k = v),
                      ),
                      if (_aktifitasUp2k)
                        TextFormField(controller: _jenisUsahaUp2kCtrl, decoration: const InputDecoration(labelText: 'Jenis Usaha UP2K')),
                      const Divider(),

                      // 10. Kesehatan Lingkungan
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('10. Aktifitas Kegiatan Usaha Kesehatan Lingkungan?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _aktifitasKesling,
                        onChanged: (v) => setState(() => _aktifitasKesling = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.data == null ? 'Simpan Data Keluarga Dasawisma' : 'Simpan Perubahan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
