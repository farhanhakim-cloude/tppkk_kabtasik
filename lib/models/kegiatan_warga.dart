// lib/models/kegiatan_warga.dart
// Sesuai Sheet "KEGIATAN WARGA" - 7 kegiatan + Y/T + Keterangan

class KegiatanItem {
  final String nama;
  final bool aktif; // Y/T
  final String keterangan; // Jenis kegiatan yang diikuti

  KegiatanItem({
    required this.nama,
    this.aktif = false,
    this.keterangan = '',
  });

  KegiatanItem copyWith({
    String? nama,
    bool? aktif,
    String? keterangan,
  }) {
    return KegiatanItem(
      nama: nama ?? this.nama,
      aktif: aktif ?? this.aktif,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}

class KegiatanWarga {
  final String id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String tahun;
  final List<KegiatanItem> items;

  KegiatanWarga({
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
  });

  KegiatanWarga copyWith({
    String? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? tahun,
    List<KegiatanItem>? items,
  }) {
    return KegiatanWarga(
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
    );
  }

  int get totalAktif => items.where((e) => e.aktif).length;
  int get totalKegiatan => items.length;

  /// Default 7 kegiatan sesuai template Excel
  static List<KegiatanItem> defaultKegiatan() => [
        KegiatanItem(nama: 'Penghayatan dan Pengamalan Pancasila'),
        KegiatanItem(nama: 'Kerjabakti'),
        KegiatanItem(nama: 'Rukun Kematian'),
        KegiatanItem(nama: 'Kegiatan Keagamaan'),
        KegiatanItem(nama: 'Jimpitan'),
        KegiatanItem(nama: 'Arisan'),
        KegiatanItem(nama: 'Lain-lain'),
      ];

  static List<String> get namaKegiatanDefault =>
      defaultKegiatan().map((e) => e.nama).toList();
}
