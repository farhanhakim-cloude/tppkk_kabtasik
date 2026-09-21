// lib/models/catatan_kegiatan.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

// ============================================================
// ENUM — TAMBAH 3 SHEET POKJA 4
// ============================================================
enum PokjaKategori {
  pokja1,
  pokja2,
  pokja3,
  pokja4,
  pokja4Pyd,       // ✅ BARU
  pokja4Posyandu,  // ✅ BARU
  pokja4Rekap,     // ✅ BARU
}

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
      case PokjaKategori.pokja4Pyd:
        return 'Pokja IV - Kunjungan PYD';
      case PokjaKategori.pokja4Posyandu:
        return 'Pokja IV - Kegiatan Posyandu';
      case PokjaKategori.pokja4Rekap:
        return 'Pokja IV - Rekapitulasi';
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
      case PokjaKategori.pokja4Pyd:
        return 'Kunjungan PYD';
      case PokjaKategori.pokja4Posyandu:
        return 'Kegiatan Posyandu';
      case PokjaKategori.pokja4Rekap:
        return 'Rekapitulasi';
    }
  }

  // ✅ KATEGORI_POKJA — untuk dikirim ke backend
  String get kategoriPokja {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'I';
      case PokjaKategori.pokja2:
        return 'II';
      case PokjaKategori.pokja3:
        return 'III';
      case PokjaKategori.pokja4:
        return 'IV';
      case PokjaKategori.pokja4Pyd:
        return 'IV-PYD';
      case PokjaKategori.pokja4Posyandu:
        return 'IV-POSYANDU';
      case PokjaKategori.pokja4Rekap:
        return 'IV-REKAP';
    }
  }

  // ✅ CHECKER
  bool get isPokja4Sheet {
    return this == PokjaKategori.pokja4Pyd ||
        this == PokjaKategori.pokja4Posyandu ||
        this == PokjaKategori.pokja4Rekap;
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
      case PokjaKategori.pokja4Pyd:
      case PokjaKategori.pokja4Posyandu:
      case PokjaKategori.pokja4Rekap:
        return '/api/pokja4'; // placeholder — ga dipakai POST
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
      case PokjaKategori.pokja4Pyd:
        return 'pokja4_kunjungan_pyd';
      case PokjaKategori.pokja4Posyandu:
        return 'pokja4_kegiatan_posyandu';
      case PokjaKategori.pokja4Rekap:
        return 'pokja4_rekapitulasi';
    }
  }

  // ============================================================
  // FIELD ANGKA — SESUAI DATABASE
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
          'kf', 'paud', 'koperasi_berbadan_hukum',
        ];
      case PokjaKategori.pokja3:
        return [
          'rumah_sehat', 'rumah_tidak_sehat',
          'pemanfaatan_pekarangan', 'industri_rumah_tangga',
        ];
      case PokjaKategori.pokja4:
        // ✅ FIX: 25 kolom — match dengan backend
        return [
          'posyandu', 'akseptor_kb', 'phbs', 'jamban_keluarga',
          'kader_kesehatan', 'kader_gizi', 'kader_kesling', 'kader_phbs', 'kader_kb',
          'imunisasi', 'pkg', 'tbc',
          'spal', 'tps', 'mck',
          'air_pdam', 'air_sumur', 'air_lainnya',
          'jumlah_pus', 'jumlah_wus',
          'akseptor_kb_l', 'akseptor_kb_p',
          'tabungan_keluarga', 'asuransi_kesehatan',
          'program_kesehatan', 'program_lingkungan', 'program_perencanaan',
        ];
      case PokjaKategori.pokja4Pyd:
        // ✅ BARU: 21 kolom Kunjungan PYD
        return [
          'bulan', 'tahun',
          'bayi_0_12_l', 'bayi_0_12_p',
          'bayi_0_12_laki_l', 'bayi_0_12_laki_p',
          'balita_1_5_l', 'balita_1_5_p',
          'balita_1_5_laki_l', 'balita_1_5_laki_p',
          'wus', 'pus', 'ibu_hamil', 'ibu_menyusui',
          'bayi_lahir', 'bayi_meninggal', 'kematian_ibu',
          'petugas_kader', 'petugas_plkb', 'petugas_medis',
          'keterangan',
        ];
      case PokjaKategori.pokja4Posyandu:
        // ✅ BARU: 40 kolom Kegiatan Posyandu
        return [
          'bulan', 'tahun',
          'ibu_hamil', 'ibu_hamil_diperiksa', 'ibu_hamil_dapat_fe', 'menyusui',
          'kb_iud', 'kb_mow', 'kb_mop', 'kb_implan', 'kb_pil', 'kb_suntik', 'kb_kondom',
          'balita_l', 'balita_p', 'balita_kia_l', 'balita_kia_p',
          'balita_ditimbang_l', 'balita_ditimbang_p',
          'balita_naik_l', 'balita_naik_p',
          'vit_a_1', 'vit_a_2',
          'imunisasi_tt_1', 'imunisasi_tt_2', 'imunisasi_bcg',
          'imunisasi_dpt_1', 'imunisasi_dpt_2', 'imunisasi_dpt_3',
          'imunisasi_polio_1', 'imunisasi_polio_2',
          'imunisasi_polio_3', 'imunisasi_polio_4',
          'imunisasi_campak',
          'imunisasi_hepatitis_1', 'imunisasi_hepatitis_2', 'imunisasi_hepatitis_3',
          'balita_diare', 'balita_oralit',
          'keterangan',
        ];
      case PokjaKategori.pokja4Rekap:
        // ✅ BARU: 19 kolom Rekapitulasi
        return [
          'tahun',
          'ibu_hamil', 'ibu_melahirkan', 'ibu_nifas', 'ibu_meninggal',
          'bayi_lahir_l', 'bayi_lahir_p',
          'akte_ada', 'akte_tidak',
          'bayi_meninggal_l', 'bayi_meninggal_p',
          'balita_meninggal_l', 'balita_meninggal_p',
          'keterangan',
        ];
    }
  }

  // Label untuk field
  String getLabelForField(String field) {
    switch (field) {
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
      case 'posyandu': return 'Jumlah Posyandu';
      case 'akseptor_kb': return 'Akseptor KB';
      case 'phbs': return 'PHBS';
      case 'jamban_keluarga': return 'Jamban Keluarga';
      case 'kader_kesehatan': return 'Kader Kesehatan';
      case 'kader_gizi': return 'Kader Gizi';
      case 'kader_kesling': return 'Kader Kesling';
      case 'kader_phbs': return 'Kader PHBS';
      case 'kader_kb': return 'Kader KB';
      case 'imunisasi': return 'Imunisasi';
      case 'pkg': return 'PKG';
      case 'tbc': return 'TBC';
      case 'spal': return 'SPAL';
      case 'tps': return 'TPS';
      case 'mck': return 'MCK';
      case 'air_pdam': return 'Air PDAM';
      case 'air_sumur': return 'Air Sumur';
      case 'air_lainnya': return 'Air Lainnya';
      case 'jumlah_pus': return 'Jumlah PUS';
      case 'jumlah_wus': return 'Jumlah WUS';
      case 'akseptor_kb_l': return 'Akseptor KB L';
      case 'akseptor_kb_p': return 'Akseptor KB P';
      case 'tabungan_keluarga': return 'Tabungan Keluarga';
      case 'asuransi_kesehatan': return 'Asuransi Kesehatan';
      case 'program_kesehatan': return 'Program Kesehatan';
      case 'program_lingkungan': return 'Program Lingkungan';
      case 'program_perencanaan': return 'Program Perencanaan';
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
      case 'IV-PYD':
      case 'pokja4Pyd':
        return PokjaKategori.pokja4Pyd;
      case 'IV-POSYANDU':
      case 'pokja4Posyandu':
        return PokjaKategori.pokja4Posyandu;
      case 'IV-REKAP':
      case 'pokja4Rekap':
        return PokjaKategori.pokja4Rekap;
      default:
        return PokjaKategori.pokja1;
    }
  }
}

enum StatusKegiatan { terkirim, dibaca }

extension StatusKegiatanLabel on StatusKegiatan {
  String get label => this == StatusKegiatan.dibaca ? 'Sudah Dibaca' : 'Terkirim';
}

// ============================================================
// MODEL
// ============================================================
class CatatanKegiatan {
  final int id;
  final String judul;
  final String deskripsiSingkat;
  final PokjaKategori kategori;
  final Map<String, dynamic> dataAngka;  // ✅ dynamic — bisa int + string
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
    Map<String, dynamic>? dataAngka,
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
    'Bantarkalong', 'Bojongasih', 'Bojonggambir', 'Ciawi', 'Cibalong',
    'Cigalontang', 'Cikalong', 'Cikatomas', 'Cineam', 'Cipatujah',
    'Cisayong', 'Culamega', 'Gunungtanjung', 'Jamanis', 'Jatiwaras',
    'Kadipaten', 'Karangjaya', 'Karangnunggal', 'Leuwisari', 'Mangunreja',
    'Manonjaya', 'Padakembang', 'Pagerageung', 'Pancatengah', 'Parungponteng',
    'Puspahiang', 'Rajapolah', 'Salawu', 'Salopa', 'Sariwangi',
    'Singaparna', 'Sodonghilir', 'Sukahening', 'Sukaraja', 'Sukarame',
    'Sukaratu', 'Sukaresik', 'Tanjungjaya', 'Taraju',
  ];

  // ============================================================
  // TO JSON — untuk kirim ke backend
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsiSingkat,
      'kategori_pokja': kategori.kategoriPokja,   // ✅ FIX: string
      'data_angka': dataAngka,
      'kecamatan': kecamatan,
      'desa_kelurahan': desa,
      'foto_path': fotoPath,
      'tanggal': tanggal.toIso8601String(),
      'status': status.index,
    };
  }

  // ============================================================
  // FROM JSON — untuk baca dari backend
  // ============================================================
  factory CatatanKegiatan.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataAngka = {};
    if (json['data_angka'] != null) {
      if (json['data_angka'] is Map) {
        dataAngka = Map<String, dynamic>.from(json['data_angka'] as Map);
      } else if (json['data_angka'] is String) {
        try {
          final decoded = jsonDecode(json['data_angka']);
          if (decoded is Map) {
            dataAngka = Map<String, dynamic>.from(decoded);
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
      judul: json['judul']?.toString() ??
          json['judul_kegiatan']?.toString() ??
          json['title']?.toString() ??
          '',
      deskripsiSingkat: json['deskripsi']?.toString() ??
          json['deskripsi_singkat']?.toString() ??
          json['keterangan']?.toString() ??
          '',
      kategori: parseKategori(
        json['kategori_pokja'] ?? json['kategori'] ?? 'I',
      ),
      dataAngka: dataAngka,
      kecamatan: json['kecamatan']?.toString() ??
          json['nama_kecamatan']?.toString() ??
          '',
      desa: json['desa']?.toString() ??
          json['desa_kelurahan']?.toString() ??
          json['kelurahan']?.toString(),
      fotoPath: json['foto']?.toString() ??
          json['foto_path']?.toString() ??
          json['foto_url']?.toString(),
      tanggal: parsedTanggal,
      status: json['status'] == 'dibaca' || json['status'] == 1
          ? StatusKegiatan.dibaca
          : StatusKegiatan.terkirim,
    );
  }

  // ============================================================
  // KIRIM KE BACKEND — POST /api/laporan-kegiatan
  // ============================================================
  static Future<Map<String, dynamic>> kirimKeBackend({
    required String token,
    required CatatanKegiatan catatan,
  }) async {
    final payload = {
      'judul': catatan.judul,
      'deskripsi': catatan.deskripsiSingkat,
      'kategori_pokja': catatan.kategori.kategoriPokja,   // ✅ IV, IV-PYD, dll
      'data_angka': catatan.dataAngka,
      'kecamatan': catatan.kecamatan,
      'desa_kelurahan': catatan.desa,
    };

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/laporan-kegiatan'),  // ✅ FIX: endpoint
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
        'message': 'Gagal kirim laporan: ${response.statusCode}',
        'body': response.body,
      };
    }
  }
}