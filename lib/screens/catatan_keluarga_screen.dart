// lib/screens/catatan_keluarga_screen.dart
// Fitur Catatan Keluarga — List & Form terpadu sesuai format resmi PKK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/catatan_keluarga.dart';
import '../services/catatan_keluarga_baru_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LIST SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CatatanKeluargaScreen extends StatefulWidget {
  const CatatanKeluargaScreen({super.key});

  @override
  State<CatatanKeluargaScreen> createState() => _CatatanKeluargaScreenState();
}

class _CatatanKeluargaScreenState extends State<CatatanKeluargaScreen> {
  final _service = CatatanKeluargaBaruService();
  final _searchCtrl = TextEditingController();
  late Future<List<CatatanKeluarga>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load([String q = '']) {
    _future = _service.getAll(query: q.isEmpty ? null : q);
  }

  void _refresh([String q = '']) => setState(() => _load(q));

  void _goForm([CatatanKeluarga? item]) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CatatanKeluargaFormScreen(catatan: item),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ).then((_) => _refresh(_searchCtrl.text));
  }

  Future<void> _delete(CatatanKeluarga item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Data?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Catatan keluarga "${item.namaKepalaKeluarga}" akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.delete(item.id);
      _refresh(_searchCtrl.text);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<CatatanKeluarga>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
                }
                final list = snap.data ?? [];
                if (list.isEmpty) return _buildEmpty();
                return RefreshIndicator(
                  onRefresh: () async => _refresh(_searchCtrl.text),
                  color: const Color(0xFF0D9488),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _buildCard(list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goForm(),
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Catatan Keluarga',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3)),
            Text('TP PKK Kab. Tasikmalaya',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)),
            onPressed: () => _refresh(_searchCtrl.text),
          ),
          const SizedBox(width: 4),
        ],
      );

  Widget _buildSearchBar() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => _refresh(v),
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari nama KK atau Dasa Wisma...',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      _searchCtrl.clear();
                      _refresh();
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
          ),
        ),
      );

  Widget _buildCard(CatatanKeluarga item) {
    final layak = item.kriteriaRumah == 'Layak Huni';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF2), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _goForm(item),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header baris
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.namaKepalaKeluarga,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.holiday_village_rounded, size: 13, color: Color(0xFF0D9488)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text('${item.dasaWisma} • Tahun ${item.tahun}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _goForm(item),
                          icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF0D9488)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () => _delete(item),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE11D48)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE8EDF2)),
                const SizedBox(height: 10),

                // Info singkat baris
                Row(
                  children: [
                    Expanded(child: _infoChip(Icons.people_alt_rounded, '${item.anggota.length} Anggota', const Color(0xFF2563EB))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _infoChip(
                      layak ? Icons.home_rounded : Icons.home_outlined,
                      item.kriteriaRumah,
                      layak ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _infoChip(Icons.water_drop_rounded, item.sumberAir, const Color(0xFF0D9488))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _infoChip(Icons.wc_rounded, 'Jamban: ${item.jambanKeluarga}', const Color(0xFF7C3AED))),
                    const SizedBox(width: 8),
                    Expanded(child: _infoChip(Icons.delete_sweep_rounded, 'Sampah: ${item.tempatSampah}', const Color(0xFFF59E0B))),
                    const SizedBox(width: 8),
                    Expanded(child: _infoChip(Icons.check_circle_rounded, '${_countPkk(item)} Kegiatan PKK', const Color(0xFF0D9488))),
                  ],
                ),

                const SizedBox(height: 10),
                // Lihat detail button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.table_chart_rounded, size: 15, color: Color(0xFF0D9488)),
                      const SizedBox(width: 6),
                      Text('Lihat & Edit Detail Catatan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _countPkk(CatatanKeluarga item) {
    if (item.anggota.isEmpty) return 0;
    // hitung rata-rata kegiatan per anggota
    int total = 0;
    for (final a in item.anggota) {
      if (a.penghayatanPancasila) total++;
      if (a.gotongRoyong) total++;
      if (a.pendidikanKeterampilan) total++;
      if (a.pengembanganKoperasi) total++;
      if (a.pangan) total++;
      if (a.sandang) total++;
      if (a.kesehatan) total++;
      if (a.perencanaanSehat) total++;
    }
    return total;
  }

  Widget _infoChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF0D9488).withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.family_restroom_rounded, size: 48, color: Color(0xFF0D9488)),
            ),
            const SizedBox(height: 16),
            Text('Belum Ada Catatan Keluarga',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text('Tap tombol + untuk menambahkan catatan keluarga baru.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CatatanKeluargaFormScreen extends StatefulWidget {
  final CatatanKeluarga? catatan;
  const CatatanKeluargaFormScreen({super.key, this.catatan});

  @override
  State<CatatanKeluargaFormScreen> createState() => _CatatanKeluargaFormScreenState();
}

class _CatatanKeluargaFormScreenState extends State<CatatanKeluargaFormScreen> {
  final _service = CatatanKeluargaBaruService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Header controllers
  late TextEditingController _namaKKCtrl;
  late TextEditingController _dasaWismaCtrl;
  late TextEditingController _tahunCtrl;

  // Kondisi rumah
  String _kriteriaRumah = 'Layak Huni';
  String _jamban = 'Ada';
  late TextEditingController _jmlJambanCtrl;
  String _sumberAir = 'Sumur';
  String _tempatSampah = 'Ada';

  // Daftar anggota (mutable)
  late List<AnggotaCatatanKeluarga> _anggota;
  int _nextAnggotaId = 100;

  @override
  void initState() {
    super.initState();
    final c = widget.catatan;
    _namaKKCtrl = TextEditingController(text: c?.namaKepalaKeluarga ?? '');
    _dasaWismaCtrl = TextEditingController(text: c?.dasaWisma ?? '');
    _tahunCtrl = TextEditingController(text: c?.tahun ?? DateTime.now().year.toString());
    _kriteriaRumah = c?.kriteriaRumah ?? 'Layak Huni';
    _jamban = c?.jambanKeluarga ?? 'Ada';
    _jmlJambanCtrl = TextEditingController(text: '${c?.jumlahJamban ?? 1}');
    _sumberAir = c?.sumberAir ?? 'Sumur';
    _tempatSampah = c?.tempatSampah ?? 'Ada';
    _anggota = c?.anggota.map((a) => a.copyWith()).toList() ?? [];
  }

  @override
  void dispose() {
    _namaKKCtrl.dispose();
    _dasaWismaCtrl.dispose();
    _tahunCtrl.dispose();
    _jmlJambanCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_anggota.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tambahkan minimal 1 anggota keluarga.', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final item = CatatanKeluarga(
        id: widget.catatan?.id ?? 0,
        namaKepalaKeluarga: _namaKKCtrl.text.trim(),
        dasaWisma: _dasaWismaCtrl.text.trim(),
        tahun: _tahunCtrl.text.trim(),
        kriteriaRumah: _kriteriaRumah,
        jambanKeluarga: _jamban,
        jumlahJamban: int.tryParse(_jmlJambanCtrl.text) ?? 0,
        sumberAir: _sumberAir,
        tempatSampah: _tempatSampah,
        anggota: _anggota,
        tanggalInput: widget.catatan?.tanggalInput ?? DateTime.now(),
      );
      await _service.save(item);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catatan keluarga berhasil disimpan!', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addAnggota() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AnggotaFormSheet(
        onSave: (a) {
          setState(() {
            _anggota.add(a.copyWith(id: _nextAnggotaId++));
          });
        },
      ),
    );
  }

  void _editAnggota(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AnggotaFormSheet(
        anggota: _anggota[index],
        onSave: (a) {
          setState(() {
            _anggota[index] = a;
          });
        },
      ),
    );
  }

  void _deleteAnggota(int index) {
    setState(() => _anggota.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.catatan != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? 'Edit Catatan Keluarga' : 'Tambah Catatan Keluarga',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            Text('Form Resmi PKK', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B))),
          ],
        ),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            )
          else
            const Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: Color(0xFF0D9488))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderSection()),
            SliverToBoxAdapter(child: _buildKriteriaSection()),
            SliverToBoxAdapter(child: _buildAnggotaHeader()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildAnggotaTile(i),
                childCount: _anggota.length,
              ),
            ),
            SliverToBoxAdapter(child: _buildAddAnggotaBtn()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── HEADER SECTION ──────────────────────────────────────────────────────────
  Widget _buildHeaderSection() => _SectionCard(
        title: 'Identitas Catatan',
        icon: Icons.assignment_rounded,
        color: const Color(0xFF0D9488),
        child: Column(
          children: [
            _buildInput('Nama Kepala Keluarga', _namaKKCtrl, Icons.person_rounded, required: true),
            const SizedBox(height: 12),
            _buildInput('Anggota Kelompok Dasa Wisma', _dasaWismaCtrl, Icons.holiday_village_rounded, required: true),
            const SizedBox(height: 12),
            _buildInput('Tahun', _tahunCtrl, Icons.calendar_today_rounded,
                inputType: TextInputType.number, maxLen: 4, required: true),
          ],
        ),
      );

  // ── KRITERIA RUMAH SECTION ───────────────────────────────────────────────────
  Widget _buildKriteriaSection() => _SectionCard(
        title: 'Kondisi Rumah',
        icon: Icons.home_rounded,
        color: const Color(0xFF2563EB),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownRow('Kriteria Rumah', _kriteriaRumah, ['Layak Huni', 'Tidak Layak Huni'], (v) => setState(() => _kriteriaRumah = v!)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildDropdownRow('Jamban Keluarga', _jamban, ['Ada', 'Tidak'], (v) => setState(() => _jamban = v!))),
                const SizedBox(width: 10),
                SizedBox(
                  width: 90,
                  child: _buildInput('Jumlah', _jmlJambanCtrl, Icons.numbers_rounded, inputType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDropdownRow('Sumber Air', _sumberAir, ['PDAM', 'Sumur', 'Lainnya'], (v) => setState(() => _sumberAir = v!)),
            const SizedBox(height: 12),
            _buildDropdownRow('Tempat Sampah', _tempatSampah, ['Ada', 'Tidak'], (v) => setState(() => _tempatSampah = v!)),
          ],
        ),
      );

  // ── ANGGOTA HEADER ───────────────────────────────────────────────────────────
  Widget _buildAnggotaHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 3.5, height: 18, decoration: BoxDecoration(color: const Color(0xFF0D9488), borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 10),
                Text('Daftar Anggota Keluarga',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(color: const Color(0xFF0D9488).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${_anggota.length} orang',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488))),
            ),
          ],
        ),
      );

  // ── ANGGOTA TILE ─────────────────────────────────────────────────────────────
  Widget _buildAnggotaTile(int index) {
    final a = _anggota[index];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF2), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _editAnggota(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: a.jenisKelamin == 'L' ? const Color(0xFF2563EB).withValues(alpha: 0.1) : const Color(0xFFE11D48).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: a.jenisKelamin == 'L' ? const Color(0xFF2563EB) : const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                        Text(
                          '${a.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'} • ${a.statusPerkawinan} • ${a.umur} thn',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editAnggota(index),
                        icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF0D9488)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => _deleteAnggota(index),
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Info bawah
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(a.pendidikan, const Color(0xFF2563EB)),
                  _chip(a.pekerjaan, const Color(0xFF7C3AED)),
                  _chip(a.agama, const Color(0xFF0D9488)),
                  if (a.berkebutuhanKhusus) _chip('Berkebutuhan Khusus', const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 8),
              // PKK indicators
              _buildPkkBadges(a),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
      );

  Widget _buildPkkBadges(AnggotaCatatanKeluarga a) {
    final items = [
      (a.penghayatanPancasila, 'Pancasila'),
      (a.gotongRoyong, 'Gotong Royong'),
      (a.pendidikanKeterampilan, 'Pendidikan'),
      (a.pengembanganKoperasi, 'Koperasi'),
      (a.pangan, 'Pangan'),
      (a.sandang, 'Sandang'),
      (a.kesehatan, 'Kesehatan'),
      (a.perencanaanSehat, 'Prn. Sehat'),
    ];
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: items.map((e) {
        final aktif = e.$1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: aktif ? const Color(0xFF0D9488).withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: aktif ? const Color(0xFF0D9488).withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                aktif ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 11,
                color: aktif ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 3),
              Text(
                e.$2,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, fontWeight: FontWeight.w600, color: aktif ? const Color(0xFF0D9488) : const Color(0xFF94A3B8)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddAnggotaBtn() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: OutlinedButton.icon(
          onPressed: _addAnggota,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D9488),
            side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          icon: const Icon(Icons.person_add_rounded, size: 18),
          label: Text('Tambah Anggota Keluarga',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      );

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Widget _buildInput(String label, TextEditingController ctrl, IconData icon,
      {TextInputType inputType = TextInputType.text, int? maxLen, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF374151))),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl,
          keyboardType: inputType,
          maxLength: maxLen,
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE11D48))),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> opts, ValueChanged<String?> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF374151))),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)))).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ANGGOTA FORM BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _AnggotaFormSheet extends StatefulWidget {
  final AnggotaCatatanKeluarga? anggota;
  final ValueChanged<AnggotaCatatanKeluarga> onSave;
  const _AnggotaFormSheet({this.anggota, required this.onSave});

  @override
  State<_AnggotaFormSheet> createState() => _AnggotaFormSheetState();
}

class _AnggotaFormSheetState extends State<_AnggotaFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaCtrl;
  String _statusKawin = 'Kawin';
  String _jk = 'L';
  late TextEditingController _tempatLahirCtrl;
  late TextEditingController _tglLahirCtrl;
  late TextEditingController _umurCtrl;
  String _agama = 'Islam';
  String _pendidikan = 'SMA/SMK';
  late TextEditingController _pekerjaanCtrl;
  bool _bk = false;
  late TextEditingController _keteranganBKCtrl;
  late TextEditingController _keteranganCtrl;

  // Kegiatan PKK
  bool _pancasila = false;
  bool _gotong = false;
  bool _pendidikanKet = false;
  bool _koperasi = false;
  bool _pangan = false;
  bool _sandang = false;
  bool _kesehatan = false;
  bool _perencanaanSehat = false;

  @override
  void initState() {
    super.initState();
    final a = widget.anggota;
    _namaCtrl = TextEditingController(text: a?.nama ?? '');
    _statusKawin = a?.statusPerkawinan ?? 'Kawin';
    _jk = a?.jenisKelamin ?? 'L';
    _tempatLahirCtrl = TextEditingController(text: a?.tempatLahir ?? '');
    _tglLahirCtrl = TextEditingController(text: a?.tanggalLahir ?? '');
    _umurCtrl = TextEditingController(text: a != null ? '${a.umur}' : '');
    _agama = a?.agama ?? 'Islam';
    _pendidikan = a?.pendidikan ?? 'SMA/SMK';
    _pekerjaanCtrl = TextEditingController(text: a?.pekerjaan ?? '');
    _bk = a?.berkebutuhanKhusus ?? false;
    _keteranganBKCtrl = TextEditingController(text: a?.keteranganBK ?? '');
    _keteranganCtrl = TextEditingController(text: a?.keterangan ?? '');
    _pancasila = a?.penghayatanPancasila ?? false;
    _gotong = a?.gotongRoyong ?? false;
    _pendidikanKet = a?.pendidikanKeterampilan ?? false;
    _koperasi = a?.pengembanganKoperasi ?? false;
    _pangan = a?.pangan ?? false;
    _sandang = a?.sandang ?? false;
    _kesehatan = a?.kesehatan ?? false;
    _perencanaanSehat = a?.perencanaanSehat ?? false;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tglLahirCtrl.dispose();
    _umurCtrl.dispose();
    _pekerjaanCtrl.dispose();
    _keteranganBKCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final result = AnggotaCatatanKeluarga(
      id: widget.anggota?.id ?? 0,
      nama: _namaCtrl.text.trim(),
      statusPerkawinan: _statusKawin,
      jenisKelamin: _jk,
      tempatLahir: _tempatLahirCtrl.text.trim(),
      tanggalLahir: _tglLahirCtrl.text.trim(),
      umur: int.tryParse(_umurCtrl.text) ?? 0,
      agama: _agama,
      pendidikan: _pendidikan,
      pekerjaan: _pekerjaanCtrl.text.trim(),
      berkebutuhanKhusus: _bk,
      keteranganBK: _keteranganBKCtrl.text.trim(),
      penghayatanPancasila: _pancasila,
      gotongRoyong: _gotong,
      pendidikanKeterampilan: _pendidikanKet,
      pengembanganKoperasi: _koperasi,
      pangan: _pangan,
      sandang: _sandang,
      kesehatan: _kesehatan,
      perencanaanSehat: _perencanaanSehat,
      keterangan: _keteranganCtrl.text.trim(),
    );
    widget.onSave(result);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.anggota == null ? 'Tambah Anggota' : 'Edit Anggota',
                            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                        Text('Data per anggota keluarga',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  children: [
                    _sheetSection('Data Diri', Icons.person_rounded, const Color(0xFF0D9488), [
                      _sheetInput('Nama Lengkap', _namaCtrl, required: true),
                      const SizedBox(height: 12),
                      // Jenis Kelamin selector
                      _labelText('Jenis Kelamin'),
                      const SizedBox(height: 6),
                      Row(
                        children: ['L', 'P'].map((v) {
                          final sel = _jk == v;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _jk = v),
                              child: Container(
                                margin: EdgeInsets.only(right: v == 'L' ? 6 : 0),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: sel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0), width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    v == 'L' ? '♂ Laki-laki' : '♀ Perempuan',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF374151)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      _sheetDropdown('Status Perkawinan', _statusKawin, ['Kawin', 'Belum Kawin', 'Janda', 'Duda'],
                          (v) => setState(() => _statusKawin = v!)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _sheetInput('Tempat Lahir', _tempatLahirCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _sheetInput('Tgl Lahir (dd-MM-yyyy)', _tglLahirCtrl)),
                      ]),
                      const SizedBox(height: 12),
                      _sheetInput('Umur (tahun)', _umurCtrl, inputType: TextInputType.number),
                    ]),
                    const SizedBox(height: 12),

                    _sheetSection('Latar Belakang', Icons.school_rounded, const Color(0xFF2563EB), [
                      _sheetDropdown('Agama', _agama, ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Budha', 'Konghuchu', 'Lainnya'],
                          (v) => setState(() => _agama = v!)),
                      const SizedBox(height: 12),
                      _sheetDropdown(
                          'Pendidikan',
                          _pendidikan,
                          ['Tidak Sekolah', 'Tidak Tamat SD', 'SD/MI', 'SMP/Sederajat', 'SMA/SMK', 'Diploma', 'S1', 'S2', 'S3'],
                          (v) => setState(() => _pendidikan = v!)),
                      const SizedBox(height: 12),
                      _sheetInput('Pekerjaan', _pekerjaanCtrl),
                    ]),
                    const SizedBox(height: 12),

                    _sheetSection('Berkebutuhan Khusus', Icons.accessibility_new_rounded, const Color(0xFFF59E0B), [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Memiliki Kebutuhan Khusus',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600)),
                          ),
                          Switch(
                            value: _bk,
                            activeColor: const Color(0xFFF59E0B),
                            onChanged: (v) => setState(() => _bk = v),
                          ),
                        ],
                      ),
                      if (_bk) ...[
                        const SizedBox(height: 10),
                        _sheetInput('Keterangan Kebutuhan Khusus', _keteranganBKCtrl),
                      ],
                    ]),
                    const SizedBox(height: 12),

                    _sheetSection('Kegiatan PKK yang Diikuti', Icons.volunteer_activism_rounded, const Color(0xFF16A34A), [
                      ...[
                        (_pancasila, 'Penghayatan & Pengamalan Pancasila', (v) => setState(() => _pancasila = v!)),
                        (_gotong, 'Gotong Royong', (v) => setState(() => _gotong = v!)),
                        (_pendidikanKet, 'Pendidikan dan Keterampilan', (v) => setState(() => _pendidikanKet = v!)),
                        (_koperasi, 'Pengembangan Kehidupan Berkoperasi', (v) => setState(() => _koperasi = v!)),
                        (_pangan, 'Pangan', (v) => setState(() => _pangan = v!)),
                        (_sandang, 'Sandang', (v) => setState(() => _sandang = v!)),
                        (_kesehatan, 'Kesehatan', (v) => setState(() => _kesehatan = v!)),
                        (_perencanaanSehat, 'Perencanaan Sehat', (v) => setState(() => _perencanaanSehat = v!)),
                      ].map((item) => _pkkCheckItem(item.$1, item.$2, item.$3 as ValueChanged<bool?>)),
                    ]),
                    const SizedBox(height: 12),

                    _sheetSection('Keterangan', Icons.notes_rounded, const Color(0xFF64748B), [
                      _sheetInput('Keterangan tambahan (opsional)', _keteranganCtrl, maxLines: 2),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelText(String t) =>
      Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF374151)));

  Widget _pkkCheckItem(bool val, String label, ValueChanged<bool?> onChanged) => CheckboxListTile(
        value: val,
        onChanged: onChanged,
        activeColor: const Color(0xFF16A34A),
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
        controlAffinity: ListTileControlAffinity.leading,
      );

  Widget _sheetInput(String label, TextEditingController ctrl,
      {bool required = false, TextInputType inputType = TextInputType.text, int maxLines = 1}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelText(label),
          const SizedBox(height: 5),
          TextFormField(
            controller: ctrl,
            keyboardType: inputType,
            maxLines: maxLines,
            validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE11D48))),
            ),
          ),
        ],
      );

  Widget _sheetDropdown(String label, String val, List<String> opts, ValueChanged<String?> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelText(label),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: val,
            isExpanded: true,
            onChanged: onChanged,
            items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)))).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5)),
            ),
          ),
        ],
      );

  Widget _sheetSection(String title, IconData icon, Color color, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF2), width: 1.2),
          boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE8EDF2)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD WIDGET (reusable)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EDF2), width: 1.2),
          boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE8EDF2)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}
