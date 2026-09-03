// lib/models/catatan_kegiatan.dart

import 'dart:convert';

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

  // ============================================================
  // FIELD ANGKA SESUAI DATABASE
  // ============================================================
  List<String> get fieldAngka {
    switch (this) {
      case PokjaKategori.pokja1:
        return [
          'pkbn_l', 'pkbn_p',
          'pkdrt_l', 'pkdrt_p',
          'pola_asuh_l', 'pola_asuh_p',
          'lansia_l', 'lansia_p',
          'kader_pokja1_l', 'kader_pokja1_p',
        ];
      case PokjaKategori.pokja2:
        return [
          'warga_buta_l', 'warga_buta_p',
          'kelompok_belajar_paket_a',
          'kelompok_belajar_paket_b',
          'kelompok_belajar_paket_c',
          'kf',
          'paud',
          'koperasi_berbadan_hukum',
        ];
      case PokjaKategori.pokja3:
        return [
          'rumah_sehat',
          'rumah_tidak_sehat',
          'pemanfaatan_pekarangan',
          'industri_rumah_tangga',
        ];
      case PokjaKategori.pokja4:
        return [
          'posyandu',
          'akseptor_kb',
          'phbs',
          'jamban_keluarga',
        ];
    }
  }

  // ============================================================
  // LABEL UNTUK TAMPILAN DI FORM
  // ============================================================
  String getLabelForField(String field) {
    switch (field) {
      // Pokja 1
      case 'pkbn_l': return 'PKBN Laki-laki';
      case 'pkbn_p': return 'PKBN Perempuan';
      case 'pkdrt_l': return 'PKDRT Laki-laki';
      case 'pkdrt_p': return 'PKDRT Perempuan';
      case 'pola_asuh_l': return 'Pola Asuh Laki-laki';
      case 'pola_asuh_p': return 'Pola Asuh Perempuan';
      case 'lansia_l': return 'Lansia Laki-laki';
      case 'lansia_p': return 'Lansia Perempuan';
      case 'kader_pokja1_l': return 'Kader Pokja I Laki-laki';
      case 'kader_pokja1_p': return 'Kader Pokja I Perempuan';
      
      // Pokja 2
      case 'warga_buta_l': return 'Warga Buta Aksara Laki-laki';
      case 'warga_buta_p': return 'Warga Buta Aksara Perempuan';
      case 'kelompok_belajar_paket_a': return 'Kelompok Belajar Paket A';
      case 'kelompok_belajar_paket_b': return 'Kelompok Belajar Paket B';
      case 'kelompok_belajar_paket_c': return 'Kelompok Belajar Paket C';
      case 'kf': return 'KF (Kegiatan Fungsional)';
      case 'paud': return 'PAUD / Sejenis';
      case 'koperasi_berbadan_hukum': return 'Koperasi Berbadan Hukum';
      
      // Pokja 3
      case 'rumah_sehat': return 'Rumah Sehat';
      case 'rumah_tidak_sehat': return 'Rumah Tidak Sehat';
      case 'pemanfaatan_pekarangan': return 'Pemanfaatan Pekarangan';
      case 'industri_rumah_tangga': return 'Industri Rumah Tangga';
      
      // Pokja 4
      case 'posyandu': return 'Jumlah Posyandu';
      case 'akseptor_kb': return 'Akseptor KB';
      case 'phbs': return 'PHBS (Perilaku Hidup Bersih Sehat)';
      case 'jamban_keluarga': return 'Jamban Keluarga';
      
      default: return field;
    }
  }

  // ============================================================
  // KONVERSI DARI STRING KE ENUM
  // ============================================================
  static PokjaKategori fromString(String value) {
    switch (value) {
      case 'I':
      case 'pokja1':
        return PokjaKategori.pokja1;
      case 'II':
      case 'pokja2':
        return PokjaKategori.pokja2;
      case 'III':
      case 'pokja3':
        return PokjaKategori.pokja3;
      case 'IV':
      case 'pokja4':
        return PokjaKategori.pokja4;
      default:
        return PokjaKategori.pokja1;
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
  final Map<String, int> dataAngka;
  final String kecamatan;
  final String? desa;
  final String? fotoPath;
  final DateTime tanggal;
  final StatusKegiatan status;

  CatatanKegiatan({
    this.id = 0,
    this.judul = '',
    String? deskripsiSingkat,
    String? ceritaSingkat,
    this.kategori = PokjaKategori.pokja1,
    this.dataAngka = const {},
    this.kecamatan = '',
    this.desa,
    this.fotoPath,
    DateTime? tanggal,
    this.status = StatusKegiatan.terkirim,
  })  : deskripsiSingkat = deskripsiSingkat ?? ceritaSingkat ?? '',
        tanggal = tanggal ?? DateTime.now();

  String get ceritaSingkat => deskripsiSingkat;

  static PokjaKategori parseKategori(dynamic value) {
    if (value is PokjaKategori) return value;
    final str = value?.toString() ?? 'I';
    return PokjaKategoriLabel.fromString(str);
  }

  CatatanKegiatan copyWith({
    int? id,
    String? judul,
    String? deskripsiSingkat,
    PokjaKategori? kategori,
    Map<String, int>? dataAngka,
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
      dataAngka: dataAngka ?? this.dataAngka,
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

  // ============================================================
  // fromJson
  // ============================================================
  factory CatatanKegiatan.fromJson(Map<String, dynamic> json) {
    Map<String, int> dataAngka = {};
    if (json['data_angka'] != null) {
      if (json['data_angka'] is Map) {
        dataAngka = (json['data_angka'] as Map).map(
          (k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0),
        );
      } else if (json['data_angka'] is String) {
        try {
          final decoded = jsonDecode(json['data_angka']);
          if (decoded is Map) {
            dataAngka = decoded.map(
              (k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0),
            );
          }
        } catch (_) {}
      }
    }

    DateTime parsedTanggal = DateTime.now();
    if (json['created_at'] != null) {
      parsedTanggal = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else if (json['tanggal'] != null) {
      parsedTanggal = DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now();
    }

    return CatatanKegiatan(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      judul: json['judul']?.toString() ?? '',
      deskripsiSingkat: json['deskripsi']?.toString() ??
          json['cerita_singkat']?.toString() ??
          json['deskripsi_singkat']?.toString() ??
          '',
      kategori: parseKategori(json['kategori_pokja'] ?? json['kategori'] ?? 'I'),
      dataAngka: dataAngka,
      kecamatan: json['kecamatan']?.toString() ?? '',
      desa: json['desa']?.toString(),
      fotoPath: json['foto']?.toString() ?? json['foto_path']?.toString(),
      tanggal: parsedTanggal,
      status: json['status'] == 'dibaca' || json['status'] == 1
          ? StatusKegiatan.dibaca
          : StatusKegiatan.terkirim,
    );
  }

  // ============================================================
  // toJson
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'cerita_singkat': ceritaSingkat,
      'deskripsi': deskripsiSingkat,
      'kategori': kategori.index,
      'data_angka': dataAngka,
      'kecamatan': kecamatan,
      'desa': desa,
      'foto_path': fotoPath,
      'tanggal': tanggal.toIso8601String(),
      'status': status.index,
    };
  }
}