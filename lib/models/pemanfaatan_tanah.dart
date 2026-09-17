// lib/models/pemanfaatan_tanah.dart
// Sesuai Sheet "PEMANFAATAN TANAH PEKARANGAN / AKU HATINYA PKK"

class PemanfaatanItem {
  final String kategori; // Peternakan, Perikanan, Warung Hidup, TOGA, Tanaman Keras Lainnya
  final String komoditi;
  final String jumlah; // angka + satuan

  PemanfaatanItem({
    required this.kategori,
    required this.komoditi,
    required this.jumlah,
  });

  PemanfaatanItem copyWith({
    String? kategori,
    String? komoditi,
    String? jumlah,
  }) {
    return PemanfaatanItem(
      kategori: kategori ?? this.kategori,
      komoditi: komoditi ?? this.komoditi,
      jumlah: jumlah ?? this.jumlah,
    );
  }
}

class PemanfaatanTanah {
  final String id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String tahun;
  final List<PemanfaatanItem> items;
  final String catatan;

  PemanfaatanTanah({
    required this.id,
    required this.dasaWisma,
    required this.rt,
    required this.rw,
    this.dusun = '',
    required this.desa,
    required this.kecamatan,
    this.kabupaten = 'Kabupaten Tasikmalaya',
    required this.tahun,
    required this.items,
    this.catatan = '',
  });

  PemanfaatanTanah copyWith({
    String? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? tahun,
    List<PemanfaatanItem>? items,
    String? catatan,
  }) {
    return PemanfaatanTanah(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kabupaten: kabupaten ?? this.kabupaten,
      tahun: tahun ?? this.tahun,
      items: items ?? this.items,
      catatan: catatan ?? this.catatan,
    );
  }

  int get totalKomoditi => items.length;
  String get ringkasanKategori {
    final unik = items.map((e) => e.kategori).where((k) => k.isNotEmpty).toSet();
    return unik.isEmpty ? '-' : unik.join(', ');
  }
}
