// lib/models/industri_rumah_tangga.dart

class IndustriItem {
  final String kategori;
  final String komoditi;
  final String volume;

  IndustriItem({
    required this.kategori,
    required this.komoditi,
    required this.volume,
  });

  IndustriItem copyWith({
    String? kategori,
    String? komoditi,
    String? volume,
  }) {
    return IndustriItem(
      kategori: kategori ?? this.kategori,
      komoditi: komoditi ?? this.komoditi,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toMap() => {
        'kategori': kategori,
        'komoditi': komoditi,
        'volume': volume,
      };

  factory IndustriItem.fromMap(Map<String, dynamic> m) => IndustriItem(
        kategori: m['kategori'] ?? '',
        komoditi: m['komoditi'] ?? '',
        volume: m['volume'] ?? '',
      );
}

class IndustriRumahTangga {
  final String id;
  final String namaKepalaKeluarga;
  final String rt;
  final String rw;
  final String dasaWisma;
  final String bulan;
  final String tahun;
  final List<IndustriItem> items;
  final String catatan;

  IndustriRumahTangga({
    required this.id,
    required this.namaKepalaKeluarga,
    required this.rt,
    required this.rw,
    required this.dasaWisma,
    required this.bulan,
    required this.tahun,
    required this.items,
    this.catatan = '',
  });

  IndustriRumahTangga copyWith({
    String? id,
    String? namaKepalaKeluarga,
    String? rt,
    String? rw,
    String? dasaWisma,
    String? bulan,
    String? tahun,
    List<IndustriItem>? items,
    String? catatan,
  }) {
    return IndustriRumahTangga(
      id: id ?? this.id,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      bulan: bulan ?? this.bulan,
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
