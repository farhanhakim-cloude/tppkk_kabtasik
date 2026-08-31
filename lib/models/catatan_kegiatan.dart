enum PokjaKategori { pokja1, pokja2, pokja3, pokja4 }

extension PokjaKategoriLabel on PokjaKategori {
  String get label {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'Pokja I - Gotong Royong & Pancasila';
      case PokjaKategori.pokja2:
        return 'Pokja II - Pendidikan & Ekonomi';
      case PokjaKategori.pokja3:
        return 'Pokja III - Pangan, Sandang, Papan';
      case PokjaKategori.pokja4:
        return 'Pokja IV - Kesehatan & Lingkungan';
    }
  }

  String get shortLabel {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'Pokja I';
      case PokjaKategori.pokja2:
        return 'Pokja II';
      case PokjaKategori.pokja3:
        return 'Pokja III';
      case PokjaKategori.pokja4:
        return 'Pokja IV';
    }
  }
}

enum StatusKegiatan { terkirim, dibaca }

extension StatusKegiatanLabel on StatusKegiatan {
  String get label => this == StatusKegiatan.dibaca ? 'Sudah Dibaca' : 'Terkirim';
}

class CatatanKegiatan {
  final int id;
  final String judul;
  final String deskripsiSingkat;
  final PokjaKategori kategori;
  final String kecamatan;
  final String? desa;
  final String? fotoPath;
  final DateTime tanggal;
  final StatusKegiatan status;

  CatatanKegiatan({
    required this.id,
    required this.judul,
    required this.deskripsiSingkat,
    required this.kategori,
    required this.kecamatan,
    this.desa,
    this.fotoPath,
    required this.tanggal,
    this.status = StatusKegiatan.terkirim,
  });

  CatatanKegiatan copyWith({
    int? id,
    String? judul,
    String? deskripsiSingkat,
    PokjaKategori? kategori,
    String? kecamatan,
    String? desa,
    String? fotoPath,
    DateTime? tanggal,
    StatusKegiatan? status,
  }) {
    return CatatanKegiatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsiSingkat: deskripsiSingkat ?? this.deskripsiSingkat,
      kategori: kategori ?? this.kategori,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      fotoPath: fotoPath ?? this.fotoPath,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
    );
  }

  static const List<String> daftar39Kecamatan = [
    'Bantarkalong',
    'Bojongasih',
    'Bojonggambir',
    'Ciawi',
    'Cibalong',
    'Cigalontang',
    'Cikalong',
    'Cikatomas',
    'Cineam',
    'Cipatujah',
    'Cisayong',
    'Culamega',
    'Gunungtanjung',
    'Jamanis',
    'Jatiwaras',
    'Kadipaten',
    'Karangjaya',
    'Karangnunggal',
    'Leuwisari',
    'Mangunreja',
    'Manonjaya',
    'Padakembang',
    'Pagerageung',
    'Pancatengah',
    'Parungponteng',
    'Puspahiang',
    'Rajapolah',
    'Salawu',
    'Salopa',
    'Sariwangi',
    'Singaparna',
    'Sodonghilir',
    'Sukahening',
    'Sukaraja',
    'Sukarame',
    'Sukaratu',
    'Sukaresik',
    'Tanjungjaya',
    'Taraju',
  ];
}