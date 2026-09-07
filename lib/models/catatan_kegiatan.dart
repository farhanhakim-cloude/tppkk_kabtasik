// lib/models/catatan_kegiatan.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

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

  String get apiEndpoint {
    switch (this) {
      case PokjaKategori.pokja1:
        return '/api/pokja1';
      case PokjaKategori.pokja2:
        return '/api/pokja2';
      case PokjaKategori.pokja3:
        return '/api/pokja3';
      case PokjaKategori.pokja4:
        return '/api/pokja4';
    }
  }

  String get tableName {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'pokja_ones';
      case PokjaKategori.pokja2:
        return 'pokja_twos';
      case PokjaKategori.pokja3:
        return 'pokja_threes';
      case PokjaKategori.pokja4:
        return 'pokja_fours';
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
          'pendidikan_l', 'pendidikan_p',
          'keterampilan_l', 'keterampilan_p',
          'koperasi_l', 'koperasi_p',
          'kader_pokja2_l', 'kader_pokja2_p',
        ];
      case PokjaKategori.pokja3:
        return [
          'pangan_l', 'pangan_p',
          'sandang_l', 'sandang_p',
          'perumahan_l', 'perumahan_p',
          'kader_pokja3_l', 'kader_pokja3_p',
        ];
      case PokjaKategori.pokja4:
        return [
          'kesehatan_l', 'kesehatan_p',
          'lingkungan_l', 'lingkungan_p',
          'perencanaan_l', 'perencanaan_p',
          'kader_pokja4_l', 'kader_pokja4_p',
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
      case 'pendidikan_l': return 'Pendidikan Laki-laki';
      case 'pendidikan_p': return 'Pendidikan Perempuan';
      case 'keterampilan_l': return 'Keterampilan Laki-laki';
      case 'keterampilan_p': return 'Keterampilan Perempuan';
      case 'koperasi_l': return 'Koperasi Laki-laki';
      case 'koperasi_p': return 'Koperasi Perempuan';
      case 'kader_pokja2_l': return 'Kader Pokja II Laki-laki';
      case 'kader_pokja2_p': return 'Kader Pokja II Perempuan';
      
      // Pokja 3
      case 'pangan_l': return 'Pangan Laki-laki';
      case 'pangan_p': return 'Pangan Perempuan';
      case 'sandang_l': return 'Sandang Laki-laki';
      case 'sandang_p': return 'Sandang Perempuan';
      case 'perumahan_l': return 'Perumahan Laki-laki';
      case 'perumahan_p': return 'Perumahan Perempuan';
      case 'kader_pokja3_l': return 'Kader Pokja III Laki-laki';
      case 'kader_pokja3_p': return 'Kader Pokja III Perempuan';
      
      // Pokja 4
      case 'kesehatan_l': return 'Kesehatan Laki-laki';
      case 'kesehatan_p': return 'Kesehatan Perempuan';
      case 'lingkungan_l': return 'Lingkungan Laki-laki';
      case 'lingkungan_p': return 'Lingkungan Perempuan';
      case 'perencanaan_l': return 'Perencanaan Laki-laki';
      case 'perencanaan_p': return 'Perencanaan Perempuan';
      case 'kader_pokja4_l': return 'Kader Pokja IV Laki-laki';
      case 'kader_pokja4_p': return 'Kader Pokja IV Perempuan';
      
      default: return field;
    }
  }

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
  // CREATE POKJA 1
  // ============================================================
  static Future<Map<String, dynamic>> createPokja1({
    required String token,
    required String judulKegiatan,
    required String deskripsi,
    required String kecamatan,
    required String namaKecamatan,
    int? pkbnL,
    int? pkbnP,
    int? pkdrtL,
    int? pkdrtP,
    int? polaAsuhL,
    int? polaAsuhP,
    int? lansiaL,
    int? lansiaP,
    int? kaderPokja1L,
    int? kaderPokja1P,
  }) async {
    final data = {
      'judul_kegiatan': judulKegiatan,
      'deskripsi': deskripsi,
      'kategori': 'Pokja I',
      'kecamatan': kecamatan,
      'nama_kecamatan': namaKecamatan,
      'pkbn_l': pkbnL ?? 0,
      'pkbn_p': pkbnP ?? 0,
      'pkdrt_l': pkdrtL ?? 0,
      'pkdrt_p': pkdrtP ?? 0,
      'pola_asuh_l': polaAsuhL ?? 0,
      'pola_asuh_p': polaAsuhP ?? 0,
      'lansia_l': lansiaL ?? 0,
      'lansia_p': lansiaP ?? 0,
      'kader_pokja1_l': kaderPokja1L ?? 0,
      'kader_pokja1_p': kaderPokja1P ?? 0,
    };

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/pokja1'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal menambahkan data Pokja 1: ${response.statusCode}',
        'body': response.body,
      };
    }
  }

  // ============================================================
  // CREATE POKJA 2
  // ============================================================
  static Future<Map<String, dynamic>> createPokja2({
    required String token,
    required String judulKegiatan,
    required String deskripsi,
    required String kecamatan,
    required String namaKecamatan,
    int? pendidikanL,
    int? pendidikanP,
    int? keterampilanL,
    int? keterampilanP,
    int? koperasiL,
    int? koperasiP,
    int? kaderPokja2L,
    int? kaderPokja2P,
  }) async {
    final data = {
      'judul_kegiatan': judulKegiatan,
      'deskripsi': deskripsi,
      'kategori': 'Pokja II',
      'kecamatan': kecamatan,
      'nama_kecamatan': namaKecamatan,
      'pendidikan_l': pendidikanL ?? 0,
      'pendidikan_p': pendidikanP ?? 0,
      'keterampilan_l': keterampilanL ?? 0,
      'keterampilan_p': keterampilanP ?? 0,
      'koperasi_l': koperasiL ?? 0,
      'koperasi_p': koperasiP ?? 0,
      'kader_pokja2_l': kaderPokja2L ?? 0,
      'kader_pokja2_p': kaderPokja2P ?? 0,
    };

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/pokja2'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal menambahkan data Pokja 2: ${response.statusCode}',
        'body': response.body,
      };
    }
  }

  // ============================================================
  // CREATE POKJA 3
  // ============================================================
  static Future<Map<String, dynamic>> createPokja3({
    required String token,
    required String judulKegiatan,
    required String deskripsi,
    required String kecamatan,
    required String namaKecamatan,
    int? panganL,
    int? panganP,
    int? sandangL,
    int? sandangP,
    int? perumahanL,
    int? perumahanP,
    int? kaderPokja3L,
    int? kaderPokja3P,
  }) async {
    final data = {
      'judul_kegiatan': judulKegiatan,
      'deskripsi': deskripsi,
      'kategori': 'Pokja III',
      'kecamatan': kecamatan,
      'nama_kecamatan': namaKecamatan,
      'pangan_l': panganL ?? 0,
      'pangan_p': panganP ?? 0,
      'sandang_l': sandangL ?? 0,
      'sandang_p': sandangP ?? 0,
      'perumahan_l': perumahanL ?? 0,
      'perumahan_p': perumahanP ?? 0,
      'kader_pokja3_l': kaderPokja3L ?? 0,
      'kader_pokja3_p': kaderPokja3P ?? 0,
    };

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/pokja3'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal menambahkan data Pokja 3: ${response.statusCode}',
        'body': response.body,
      };
    }
  }

  // ============================================================
  // CREATE POKJA 4
  // ============================================================
  static Future<Map<String, dynamic>> createPokja4({
    required String token,
    required String judulKegiatan,
    required String deskripsi,
    required String kecamatan,
    required String namaKecamatan,
    int? kesehatanL,
    int? kesehatanP,
    int? lingkunganL,
    int? lingkunganP,
    int? perencanaanL,
    int? perencanaanP,
    int? kaderPokja4L,
    int? kaderPokja4P,
  }) async {
    final data = {
      'judul_kegiatan': judulKegiatan,
      'deskripsi': deskripsi,
      'kategori': 'Pokja IV',
      'kecamatan': kecamatan,
      'nama_kecamatan': namaKecamatan,
      'kesehatan_l': kesehatanL ?? 0,
      'kesehatan_p': kesehatanP ?? 0,
      'lingkungan_l': lingkunganL ?? 0,
      'lingkungan_p': lingkunganP ?? 0,
      'perencanaan_l': perencanaanL ?? 0,
      'perencanaan_p': perencanaanP ?? 0,
      'kader_pokja4_l': kaderPokja4L ?? 0,
      'kader_pokja4_p': kaderPokja4P ?? 0,
    };

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/pokja4'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal menambahkan data Pokja 4: ${response.statusCode}',
        'body': response.body,
      };
    }
  }

  // ============================================================
  // CREATE POKJA GENERIC (PAKAI API ENDPOINT DARI ENUM)
  // ============================================================
  static Future<Map<String, dynamic>> createPokja({
    required String token,
    required PokjaKategori kategori,
    required String judulKegiatan,
    required String deskripsi,
    required String kecamatan,
    required String namaKecamatan,
    Map<String, int>? dataAngka,
  }) async {
    Map<String, dynamic> payload = {
      'judul_kegiatan': judulKegiatan,
      'deskripsi': deskripsi,
      'kategori': kategori.shortLabel,
      'kecamatan': kecamatan,
      'nama_kecamatan': namaKecamatan,
    };

    // Tambahkan data angka
    if (dataAngka != null) {
      payload.addAll(dataAngka);
    }

    // Tambahkan field angka dengan default 0
    for (var field in kategori.fieldAngka) {
      if (!payload.containsKey(field)) {
        payload[field] = 0;
      }
    }

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${kategori.apiEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal menambahkan data ${kategori.shortLabel}: ${response.statusCode}',
        'body': response.body,
      };
    }
  }

  // ============================================================
  // GET ALL POKJA
  // ============================================================
  static Future<Map<String, dynamic>> getAllPokja(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/pokja/all'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'message': 'Gagal mengambil data'};
    }
  }

  // ============================================================
  // GET BY KECAMATAN
  // ============================================================
  static Future<Map<String, dynamic>> getPokjaByKecamatan(
    String token,
    String kecamatan,
  ) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/pokja/kecamatan/$kecamatan'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'message': 'Gagal mengambil data'};
    }
  }

  // ============================================================
  // GET POKJA BY TYPE
  // ============================================================
  static Future<Map<String, dynamic>> getPokjaByType(
    String token,
    PokjaKategori kategori,
  ) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${kategori.apiEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal mengambil data ${kategori.shortLabel}',
      };
    }
  }

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