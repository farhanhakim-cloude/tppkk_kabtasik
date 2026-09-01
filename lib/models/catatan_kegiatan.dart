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
  // 🔥 LABEL UNTUK TAMPILAN DI FORM
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
  // 🔥 KONVERSI DARI STRING KE ENUM
  // ============================================================
  static PokjaKategori fromString(String value) {
    switch (value) {
      case 'I':
        return PokjaKategori.pokja1;
      case 'II':
        return PokjaKategori.pokja2;
      case 'III':
        return PokjaKategori.pokja3;
      case 'IV':
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
  final String ceritaSingkat;
  final PokjaKategori kategori;
  final Map<String, int> dataAngka;
  final String kecamatan;
  final String? fotoPath;
  final DateTime tanggal;
  final StatusKegiatan status;

  CatatanKegiatan({
    required this.id,
    required this.judul,
    required this.ceritaSingkat,
    required this.kategori,
    required this.dataAngka,
    required this.kecamatan,
    this.fotoPath,
    required this.tanggal,
    this.status = StatusKegiatan.terkirim,
  });

  // ============================================================
  // fromJson
  // ============================================================
  factory CatatanKegiatan.fromJson(Map<String, dynamic> json) {
    Map<String, int> dataAngka = {};
    if (json['data_angka'] != null) {
      if (json['data_angka'] is Map) {
        dataAngka = Map<String, int>.from(json['data_angka']);
      } else if (json['data_angka'] is String) {
        try {
          final decoded = jsonDecode(json['data_angka']);
          if (decoded is Map) {
            dataAngka = Map<String, int>.from(decoded);
          }
        } catch (_) {}
      }
    }

    return CatatanKegiatan(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      ceritaSingkat: json['deskripsi'] ?? json['cerita_singkat'] ?? '',
      kategori: PokjaKategoriLabel.fromString(json['kategori_pokja'] ?? 'I'),
      dataAngka: dataAngka,
      kecamatan: json['kecamatan'] ?? '',
      fotoPath: json['foto'] ?? json['foto_path'],
      tanggal: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      status: json['status'] == 'dibaca'
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
      'kategori': kategori.index,
      'data_angka': dataAngka,
      'kecamatan': kecamatan,
      'foto_path': fotoPath,
      'tanggal': tanggal.toIso8601String(),
      'status': status.index,
    };
  }
}