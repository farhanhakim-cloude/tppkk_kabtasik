// lib/models/buku_kegiatan_pokja1.dart
// Model Buku Kegiatan Pokja I — LAMPIRAN 4.13
// Kolom tabel: 1 NO | 2 NAMA | 3 JABATAN | 4 TANGGAL | 5 TEMPAT | 6 URAIAN | 7 TANDA TANGAN
// Dikirim lewat alur laporan-kegiatan existing (kategori_pokja=I) agar status
// pending — TIDAK publish — dan muncul di halaman verifikasi admin kabupaten
// + super admin. Kolom TTD sengaja dikosongkan (diisi basah saat cetak).

import 'catatan_kegiatan.dart';

class BukuKegiatanRow {
  final String nama;
  final String jabatan;
  final DateTime? tanggal;
  final String tempat;
  final String uraian;

  const BukuKegiatanRow({
    this.nama = '',
    this.jabatan = '',
    this.tanggal,
    this.tempat = '',
    this.uraian = '',
  });

  bool get isValid =>
      nama.trim().isNotEmpty &&
      tanggal != null &&
      tempat.trim().isNotEmpty &&
      uraian.trim().isNotEmpty;

  BukuKegiatanRow copyWith({
    String? nama,
    String? jabatan,
    DateTime? tanggal,
    String? tempat,
    String? uraian,
  }) {
    return BukuKegiatanRow(
      nama: nama ?? this.nama,
      jabatan: jabatan ?? this.jabatan,
      tanggal: tanggal ?? this.tanggal,
      tempat: tempat ?? this.tempat,
      uraian: uraian ?? this.uraian,
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama.trim(),
        'jabatan': jabatan.trim(),
        'tanggal': tanggal == null
            ? ''
            : '${tanggal!.year.toString().padLeft(4, '0')}-'
                '${tanggal!.month.toString().padLeft(2, '0')}-'
                '${tanggal!.day.toString().padLeft(2, '0')}',
        'tempat': tempat.trim(),
        'uraian': uraian.trim(),
      };

  factory BukuKegiatanRow.fromJson(Map<String, dynamic> j) {
    DateTime? t;
    final raw = (j['tanggal'] ?? '').toString();
    if (raw.isNotEmpty) t = DateTime.tryParse(raw);
    return BukuKegiatanRow(
      nama: (j['nama'] ?? '').toString(),
      jabatan: (j['jabatan'] ?? '').toString(),
      tanggal: t,
      tempat: (j['tempat'] ?? '').toString(),
      uraian: (j['uraian'] ?? '').toString(),
    );
  }
}

class BukuKegiatanPokja1 {
  static const String jenisFormulir = 'buku_kegiatan_lampiran_413';
  static const String judulPrefix = 'Buku Kegiatan Pokja I';

  /// Rakit data_angka untuk dikirim sebagai JSON di multipart `data_angka`.
  static Map<String, dynamic> toDataAngka(List<BukuKegiatanRow> rows) => {
        'jenis_formulir': jenisFormulir,
        'buku_kegiatan_count': rows.length,
        'buku_kegiatan': rows.map((e) => e.toJson()).toList(),
      };

  /// Baca kembali baris buku kegiatan dari laporan yang sudah tersimpan.
  static List<BukuKegiatanRow> fromDataAngka(Map<String, dynamic> dataAngka) {
    final raw = dataAngka['buku_kegiatan'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) =>
            BukuKegiatanRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static bool isBukuKegiatan(CatatanKegiatan c) {
    if (c.kategori != PokjaKategori.pokja1) return false;
    return c.dataAngka['jenis_formulir'] == jenisFormulir ||
        c.dataAngka['buku_kegiatan'] is List;
  }

  static String buildJudul({required String desa, required String kecamatan}) {
    final loc = [
      if (desa.trim().isNotEmpty) desa.trim(),
      if (kecamatan.trim().isNotEmpty) kecamatan.trim(),
    ].join(', ');
    return loc.isEmpty ? judulPrefix : '$judulPrefix - $loc';
  }

  static String buildDeskripsi(List<BukuKegiatanRow> rows) {
    if (rows.isEmpty) return 'Lampiran 4.13 Buku Kegiatan Pokja I.';
    final dates = rows
        .map((e) => e.tanggal)
        .whereType<DateTime>()
        .toList()
      ..sort();
    String periode = '';
    if (dates.isNotEmpty) {
      String f(DateTime d) =>
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      periode = dates.length == 1
          ? f(dates.first)
          : '${f(dates.first)} s.d. ${f(dates.last)}';
    }
    final names = rows
        .map((e) => e.nama.trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .join(', ');
    final extra = rows.length > 3 ? ' +${rows.length - 3} lainnya' : '';
    return 'Lampiran 4.13 Buku Kegiatan Pokja I: ${rows.length} baris'
        '${periode.isNotEmpty ? ' ($periode)' : ''}'
        '${names.isNotEmpty ? ' — $names$extra' : ''}. Menunggu verifikasi admin kabupaten.';
  }
}
