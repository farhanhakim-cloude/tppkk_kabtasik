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

  // Daftar field angka yang relevan per kategori — ini yang bikin form dinamis
  List<String> get fieldAngka {
    switch (this) {
      case PokjaKategori.pokja1:
        return [
          'Jumlah Kegiatan Gotong Royong',
          'Jumlah Keluarga Berpartisipasi',
          'Jumlah Kegiatan Keagamaan',
          'Jumlah Peserta Penyuluhan',
        ];
      case PokjaKategori.pokja2:
        return [
          'Jumlah Warga Buta Aksara Terentaskan',
          'Jumlah Kelompok UP2K Aktif',
          'Jumlah Peserta Pelatihan Keterampilan',
          'Jumlah Anggota Koperasi Baru',
        ];
      case PokjaKategori.pokja3:
        return [
          'Jumlah Keluarga Tanam Pekarangan',
          'Jumlah Rumah Tidak Layak Huni Terdata',
          'Jumlah Keluarga Ikut Penyuluhan Pangan',
          'Jumlah Keluarga Dibina Tata Laksana RT',
        ];
      case PokjaKategori.pokja4:
        return [
          'Jumlah Balita Ditimbang',
          'Jumlah Ibu Hamil Diperiksa',
          'Jumlah Rumah dengan Jamban Sehat',
          'Jumlah Kegiatan Kerja Bakti Lingkungan',
        ];
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
  final String ceritaSingkat;
  final PokjaKategori kategori;
  final Map<String, int> dataAngka; // label field -> nilai
  final String? fotoPath;
  final DateTime tanggal;
  final StatusKegiatan status;

  CatatanKegiatan({
    required this.id,
    required this.judul,
    required this.ceritaSingkat,
    required this.kategori,
    required this.dataAngka,
    this.fotoPath,
    required this.tanggal,
    this.status = StatusKegiatan.terkirim,
  });
}