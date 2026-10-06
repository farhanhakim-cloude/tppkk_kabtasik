// lib/models/catatan_kegiatan.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

// ============================================================
// ENUM â€” TAMBAH 3 SHEET POKJA 4
// ============================================================
enum PokjaKategori {
  pokja1,
  pokja2,
  pokja3,
  pokja4,
  pokja4Pyd, // ✅ BARU
  pokja4Posyandu, // ✅ BARU
  pokja4Rekap, // ✅ BARU
  pokja4DataDukung, // ✅ BARU
  pokja4DataProgram, // ✅ BARU
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
      case PokjaKategori.pokja4DataDukung:
        return 'Pokja IV - Data Dukung';
      case PokjaKategori.pokja4DataProgram:
        return 'Pokja IV - Data Program';
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
      case PokjaKategori.pokja4DataDukung:
        return 'Data Dukung';
      case PokjaKategori.pokja4DataProgram:
        return 'Data Program';
    }
  }

  // âœ… KATEGORI_POKJA â€” untuk dikirim ke backend
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
      case PokjaKategori.pokja4DataDukung:
        return 'IV-DATADUKUNG';
      case PokjaKategori.pokja4DataProgram:
        return 'IV-DATAPROGRAM';
    }
  }

  // âœ… CHECKER
  bool get isPokja4Sheet {
    return this == PokjaKategori.pokja4Pyd ||
        this == PokjaKategori.pokja4Posyandu ||
        this == PokjaKategori.pokja4Rekap ||
        this == PokjaKategori.pokja4DataDukung ||
        this == PokjaKategori.pokja4DataProgram;
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
      case PokjaKategori.pokja4DataDukung:
      case PokjaKategori.pokja4DataProgram:
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
      case PokjaKategori.pokja4DataDukung:
        return 'pokja4_data_dukung';
      case PokjaKategori.pokja4DataProgram:
        return 'pokja4_data_program';
    }
  }

  // ============================================================
  // FIELD ANGKA â€” SESUAI DATABASE
  // ============================================================
  List<String> get fieldAngka {
    switch (this) {
      case PokjaKategori.pokja1:
        return [
          // Kader
          'kader_umum', 'kader_khusus',
          // KISAH
          'kisah_kegiatan', 'kisah_volume', 'kisah_metode', 'kisah_sasaran',
          // KILAS
          'kilas_kegiatan', 'kilas_volume', 'kilas_metode', 'kilas_sasaran',
          // KRISAN
          'krisan_kegiatan', 'krisan_volume', 'krisan_metode', 'krisan_sasaran',
          // KIAT
          'kiat_kegiatan', 'kiat_volume', 'kiat_metode', 'kiat_sasaran',
          // KISAK
          'kisak_kegiatan', 'kisak_volume', 'kisak_metode', 'kisak_sasaran',
          // PKBN
          'pkbn_kegiatan', 'pkbn_volume', 'pkbn_metode', 'pkbn_sasaran',
          // Keterangan
          'keterangan',
        ];
      case PokjaKategori.pokja2:
        return [
          'kelompok_warga_buta',
          'warga_buta_l',
          'warga_buta_p',
          'kelompok_belajar_paket_a',
          'warga_belajar_paket_a_l',
          'warga_belajar_paket_a_p',
          'kelompok_belajar_paket_b',
          'warga_belajar_paket_b_l',
          'warga_belajar_paket_b_p',
          'kelompok_belajar_paket_c',
          'warga_belajar_paket_c_l',
          'warga_belajar_paket_c_p',
          'kf',
          'warga_belajar_kf_l',
          'warga_belajar_kf_p',
          'kelompok_paud',
          'paud_l',
          'paud_p',
          'kelompok_taman_bacaan',
          'taman_bacaan_l',
          'taman_bacaan_p',
          'kelompok_bkb',
          'peserta_bkb_l',
          'peserta_bkb_p',
          'ape_bkb',
          'kelompok_simulasi_bkb',
          'kelompok_simulasi_bkb_l',
          'kelompok_simulasi_bkb_p',
          'tutor_kf',
          'tutor_kf_l',
          'tutor_kf_p',
          'tutor_paud',
          'tutor_paud_l',
          'tutor_paud_p',
          'kader_bkb',
          'kader_bkb_l',
          'kader_bkb_p',
          'kader_koperasi',
          'kader_koperasi_l',
          'kader_koperasi_p',
          'kader_keterampilan',
          'kader_keterampilan_l',
          'kader_keterampilan_p',
          'up2k_pemula_kelompok',
          'up2k_pemula_peserta_l',
          'up2k_pemula_peserta_p',
          'up2k_madya_kelompok',
          'up2k_madya_peserta_l',
          'up2k_madya_peserta_p',
          'up2k_utama_kelompok',
          'up2k_utama_peserta_l',
          'up2k_utama_peserta_p',
          'up2k_mandiri_kelompok',
          'up2k_mandiri_peserta_l',
          'up2k_mandiri_peserta_p',
          'koperasi_berbadan_hukum',
          'anggota_koperasi_l',
          'anggota_koperasi_p',
          'ibu_set_bkb',
          'lp3_pkk',
          'lp3_pkk_l',
          'lp3_pkk_p',
          'tp3_pkk',
          'tp3_pkk_l',
          'tp3_pkk_p',
          'damas_pkk',
          'damas_pkk_l',
          'damas_pkk_p',
          'keterangan',
        ];
      case PokjaKategori.pokja3:
        return [
          'rumah_sehat',
          'rumah_tidak_sehat',
          'pemanfaatan_pekarangan',
          'industri_rumah_tangga',
        ];
      case PokjaKategori.pokja4:
        // âœ… FIX: 25 kolom â€” match dengan backend
        return [
          'posyandu',
          'akseptor_kb',
          'phbs',
          'jamban_keluarga',
          'kader_kesehatan',
          'kader_gizi',
          'kader_kesling',
          'kader_phbs',
          'kader_kb',
          'imunisasi',
          'pkg',
          'tbc',
          'spal',
          'tps',
          'mck',
          'air_pdam',
          'air_sumur',
          'air_lainnya',
          'jumlah_pus',
          'jumlah_wus',
          'akseptor_kb_l',
          'akseptor_kb_p',
          'tabungan_keluarga',
          'asuransi_kesehatan',
          'program_kesehatan',
          'program_lingkungan',
          'program_perencanaan',
        ];
      case PokjaKategori.pokja4Pyd:
        // âœ… BARU: 21 kolom Kunjungan PYD
        return [
          'bulan',
          'tahun',
          'bayi_0_12_l',
          'bayi_0_12_p',
          'bayi_0_12_laki_l',
          'bayi_0_12_laki_p',
          'balita_1_5_l',
          'balita_1_5_p',
          'balita_1_5_laki_l',
          'balita_1_5_laki_p',
          'wus',
          'pus',
          'ibu_hamil',
          'ibu_menyusui',
          'bayi_lahir',
          'bayi_meninggal',
          'kematian_ibu',
          'petugas_kader',
          'petugas_plkb',
          'petugas_medis',
          'keterangan',
        ];
      case PokjaKategori.pokja4Posyandu:
        // âœ… BARU: 40 kolom Kegiatan Posyandu
        return [
          'bulan',
          'tahun',
          'ibu_hamil',
          'ibu_hamil_diperiksa',
          'ibu_hamil_dapat_fe',
          'menyusui',
          'kb_iud',
          'kb_mow',
          'kb_mop',
          'kb_implan',
          'kb_pil',
          'kb_suntik',
          'kb_kondom',
          'balita_l',
          'balita_p',
          'balita_kia_l',
          'balita_kia_p',
          'balita_ditimbang_l',
          'balita_ditimbang_p',
          'balita_naik_l',
          'balita_naik_p',
          'vit_a_1',
          'vit_a_2',
          'imunisasi_tt_1',
          'imunisasi_tt_2',
          'imunisasi_bcg',
          'imunisasi_dpt_1',
          'imunisasi_dpt_2',
          'imunisasi_dpt_3',
          'imunisasi_polio_1',
          'imunisasi_polio_2',
          'imunisasi_polio_3',
          'imunisasi_polio_4',
          'imunisasi_campak',
          'imunisasi_hepatitis_1',
          'imunisasi_hepatitis_2',
          'imunisasi_hepatitis_3',
          'balita_diare',
          'balita_oralit',
          'keterangan',
        ];
      case PokjaKategori.pokja4Rekap:
        // âœ… BARU: 19 kolom Rekapitulasi
        return [
          'tahun',
          'ibu_hamil',
          'ibu_melahirkan',
          'ibu_nifas',
          'ibu_meninggal',
          'bayi_lahir_l',
          'bayi_lahir_p',
          'akte_ada',
          'akte_tidak',
          'bayi_meninggal_l',
          'bayi_meninggal_p',
          'balita_meninggal_l',
          'balita_meninggal_p',
          'keterangan',
        ];
      case PokjaKategori.pokja4DataDukung:
        return [
          'jumlah_penduduk',
          'jumlah_kk',
          'jumlah_rumah',
          'jumlah_laki',
          'jumlah_perempuan',
          'jumlah_usia_produktif',
          'jumlah_pus',
          'jumlah_ibu_hamil',
          'jumlah_bayi_0_2',
          'jumlah_bayi_asi',
          'jumlah_balita',
          'jumlah_anak',
          'jumlah_lansia',
          'jumlah_kb_aktif',
          'jumlah_ibu_menyusui',
          'jumlah_keluarga_sejahtera',
          'jumlah_keluarga_pra_sejahtera',
          'jumlah_mbr',
          'jumlah_kader_pkk_rt_rw',
          'jumlah_kader_pkk_kesehatan',
          'jumlah_dasa_wisma',
          'jumlah_kader_dasa_wisma',
          'jumlah_posyandu_aktif',
          'jumlah_bidan_desa',
          'jumlah_bank_sampah',
          'jumlah_posko_bencana',
        ];
      case PokjaKategori.pokja4DataProgram:
        return [
          // I. Stunting
          'bayi_prematur',
          'bayi_bblr',
          'balita_kurang_gizi',
          'balita_stunting',
          'bayi_balita_periksa',
          'ibu_lahir_jarak_dekat',
          'hamil_tidak_direncanakan',
          // II. PHBS
          'penduduk_tbc',
          'rumah_jamban_sehat',
          'rumah_bak_air',
          'kasus_diare',
          'keluarga_sadar_gizi',
          'rumah_tanpa_asap_rokok',
          'penduduk_babs',
          // III. Kesehatan Keluarga
          'ibu_hamil_periksa',
          'ayah_merokok',
          'kematian_ibu_nifas',
          'kanker_serviks',
          'bayi_balita_imunisasi',
          'bayi_balita_sakit',
          'kematian_bayi_balita',
          // IV. Siaga Kebakaran
          'kebakaran_rumah_tangga',
          'rumah_listrik_standar',
          'rumah_alat_pemadam',
          'rumah_semi_permanen',
          'rumah_kotak_p3k',
          'rumah_info_mitigasi_kebakaran',
          'kader_edukasi_kebakaran',
          // V. Mitigasi Bencana Alam
          'relawan_bencana_alam',
          'rumah_info_mitigasi_alam',
          'kader_edukasi_alam',
          'fasilitas_posko_bencana',
          'relawan_bencana_alam_2',
          'rumah_tas_siaga',
          'kerusakan_fasilitas_umum',
          // VI. Peduli Lingkungan
          'keluarga_bak_sampah',
          'keluarga_anggota_bank_sampah',
          'keluarga_spal',
          'kasus_banjir',
          'bak_sampah_desa',
          'rumah_sehat',
          'kasus_klb',
          // VII. Keluarga Sehat Berkualitas
          'keluarga_2_anak',
          'penduduk_berobat',
          'penyakit_menular',
          'penyakit_tidak_menular',
          'bayi_lahir_sehat',
          'bayi_cukup_bulan',
          'keluarga_gangguan_jiwa',
          // VIII. Keuangan Sehat
          'keluarga_asuransi',
          'kk_pengangguran',
          'kk_tidak_tetap',
          'kk_penghasilan_tetap',
          'ibu_hamil_tabulin',
          'keluarga_tabungan',
          'keluarga_aset_investasi',
          // IX. Pasangan Usia Subur (PUS)
          'ibu_melahirkan_bayi_sehat',
          'wanita_peserta_kb',
          'pria_peserta_kb',
          'pus_masalah_reproduksi',
          'pus_nikah_di_bawah_19',
          'wus_hamil_beresiko',
          'pus_penyakit_seksual',
        ];
    }
  }

  // Label untuk field
  String getLabelForField(String field) {
    switch (field) {
      case 'kader_umum': return 'Kader Umum';
      case 'kader_khusus': return 'Kader Khusus';
      case 'kisah_kegiatan': return 'KISAH (Kegiatan)';
      case 'kisah_volume': return 'KISAH (Volume)';
      case 'kisah_metode': return 'KISAH (Metode)';
      case 'kisah_sasaran': return 'KISAH (Sasaran)';
      case 'kilas_kegiatan': return 'KILAS (Kegiatan)';
      case 'kilas_volume': return 'KILAS (Volume)';
      case 'kilas_metode': return 'KILAS (Metode)';
      case 'kilas_sasaran': return 'KILAS (Sasaran)';
      case 'krisan_kegiatan': return 'KRISAN (Kegiatan)';
      case 'krisan_volume': return 'KRISAN (Volume)';
      case 'krisan_metode': return 'KRISAN (Metode)';
      case 'krisan_sasaran': return 'KRISAN (Sasaran)';
      case 'kiat_kegiatan': return 'KIAT (Kegiatan)';
      case 'kiat_volume': return 'KIAT (Volume)';
      case 'kiat_metode': return 'KIAT (Metode)';
      case 'kiat_sasaran': return 'KIAT (Sasaran)';
      case 'kisak_kegiatan': return 'KISAK (Kegiatan)';
      case 'kisak_volume': return 'KISAK (Volume)';
      case 'kisak_metode': return 'KISAK (Metode)';
      case 'kisak_sasaran': return 'KISAK (Sasaran)';
      case 'pkbn_kegiatan': return 'PKBN (Kegiatan)';
      case 'pkbn_volume': return 'PKBN (Volume)';
      case 'pkbn_metode': return 'PKBN (Metode)';
      case 'pkbn_sasaran': return 'PKBN (Sasaran)';
      case 'posyandu':
        return 'Jumlah Posyandu';
      case 'akseptor_kb':
        return 'Akseptor KB';
      case 'phbs':
        return 'PHBS';
      case 'jamban_keluarga':
        return 'Jamban Keluarga';
      case 'kader_kesehatan':
        return 'Kader Kesehatan';
      case 'kader_gizi':
        return 'Kader Gizi';
      case 'kader_kesling':
        return 'Kader Kesling';
      case 'kader_phbs':
        return 'Kader PHBS';
      case 'kader_kb':
        return 'Kader KB';
      case 'imunisasi':
        return 'Imunisasi';
      case 'pkg':
        return 'PKG';
      case 'tbc':
        return 'TBC';
      case 'spal':
        return 'SPAL';
      case 'tps':
        return 'TPS';
      case 'mck':
        return 'MCK';
      case 'air_pdam':
        return 'Air PDAM';
      case 'air_sumur':
        return 'Air Sumur';
      case 'air_lainnya':
        return 'Air Lainnya';
      case 'jumlah_pus':
        return 'Jumlah PUS';
      case 'jumlah_wus':
        return 'Jumlah WUS';
      case 'akseptor_kb_l':
        return 'Akseptor KB L';
      case 'akseptor_kb_p':
        return 'Akseptor KB P';
      case 'tabungan_keluarga':
        return 'Tabungan Keluarga';
      case 'asuransi_kesehatan':
        return 'Asuransi Kesehatan';
      case 'program_kesehatan':
        return 'Program Kesehatan';
      case 'program_lingkungan':
        return 'Program Lingkungan';
      case 'program_perencanaan':
        return 'Program Perencanaan';
      case 'kelompok_warga_buta': return 'Warga Buta - Jml KLP';
      case 'warga_buta_l': return 'Warga Buta (L)';
      case 'warga_buta_p': return 'Warga Buta (P)';
      case 'kelompok_belajar_paket_a': return 'Kelompok Belajar Paket A';
      case 'warga_belajar_paket_a_l': return 'Warga Belajar Paket A (L)';
      case 'warga_belajar_paket_a_p': return 'Warga Belajar Paket A (P)';
      case 'kelompok_belajar_paket_b': return 'Kelompok Belajar Paket B';
      case 'warga_belajar_paket_b_l': return 'Warga Belajar Paket B (L)';
      case 'warga_belajar_paket_b_p': return 'Warga Belajar Paket B (P)';
      case 'kelompok_belajar_paket_c': return 'Kelompok Belajar Paket C';
      case 'warga_belajar_paket_c_l': return 'Warga Belajar Paket C (L)';
      case 'warga_belajar_paket_c_p': return 'Warga Belajar Paket C (P)';
      case 'kf': return 'Keaksaraan Fungsional (KF)';
      case 'warga_belajar_kf_l': return 'Warga Belajar KF (L)';
      case 'warga_belajar_kf_p': return 'Warga Belajar KF (P)';
      case 'kelompok_paud': return 'PAUD - Jml KLP';
      case 'paud_l': return 'PAUD Sejenis (L)';
      case 'paud_p': return 'PAUD Sejenis (P)';
      case 'kelompok_taman_bacaan': return 'Taman Bacaan - Jml KLP';
      case 'taman_bacaan_l': return 'Taman Bacaan (L)';
      case 'taman_bacaan_p': return 'Taman Bacaan (P)';
      case 'kelompok_bkb': return 'BKB - Jml KLP';
      case 'kelompok_bkb_l': return 'BKB - Jml KLP (L)';
      case 'kelompok_bkb_p': return 'BKB - Jml KLP (P)';
      case 'peserta_bkb_l': return 'Peserta BKB (L)';
      case 'peserta_bkb_p': return 'Peserta BKB (P)';
      case 'ape_bkb': return 'APE BKB';
      case 'kelompok_simulasi_bkb': return 'BKB - Simulasi Jml KLP';
      case 'kelompok_simulasi_bkb_l': return 'Simulasi BKB (L)';
      case 'kelompok_simulasi_bkb_p': return 'Simulasi BKB (P)';
      case 'tutor_kf': return 'Tutor KF Jml';
      case 'tutor_kf_l': return 'Tutor KF (L)';
      case 'tutor_kf_p': return 'Tutor KF (P)';
      case 'tutor_paud': return 'Tutor PAUD Jml';
      case 'tutor_paud_l': return 'Tutor PAUD (L)';
      case 'tutor_paud_p': return 'Tutor PAUD (P)';
      case 'kader_bkb': return 'Kader BKB Jml';
      case 'kader_bkb_l': return 'Kader BKB (L)';
      case 'kader_bkb_p': return 'Kader BKB (P)';
      case 'kader_koperasi': return 'Kader Koperasi Jml';
      case 'kader_koperasi_l': return 'Kader Koperasi (L)';
      case 'kader_koperasi_p': return 'Kader Koperasi (P)';
      case 'kader_keterampilan': return 'Kader Keterampilan Jml';
      case 'kader_keterampilan_l': return 'Kader Keterampilan (L)';
      case 'kader_keterampilan_p': return 'Kader Keterampilan (P)';
      case 'up2k_pemula_kelompok': return 'UP2K Pemula Kelompok';
      case 'up2k_pemula_peserta_l': return 'UP2K Pemula Peserta (L)';
      case 'up2k_pemula_peserta_p': return 'UP2K Pemula Peserta (P)';
      case 'up2k_madya_kelompok': return 'UP2K Madya Kelompok';
      case 'up2k_madya_peserta_l': return 'UP2K Madya Peserta (L)';
      case 'up2k_madya_peserta_p': return 'UP2K Madya Peserta (P)';
      case 'up2k_utama_kelompok': return 'UP2K Utama Kelompok';
      case 'up2k_utama_peserta_l': return 'UP2K Utama Peserta (L)';
      case 'up2k_utama_peserta_p': return 'UP2K Utama Peserta (P)';
      case 'up2k_mandiri_kelompok': return 'UP2K Mandiri Kelompok';
      case 'up2k_mandiri_peserta_l': return 'UP2K Mandiri Peserta (L)';
      case 'up2k_mandiri_peserta_p': return 'UP2K Mandiri Peserta (P)';
      case 'anggota_koperasi_l': return 'Anggota Koperasi (L)';
      case 'anggota_koperasi_p': return 'Anggota Koperasi (P)';
      case 'ibu_set_bkb': return 'Ibu SET BKB';
      case 'lp3_pkk': return 'LP3 PKK Jml';
      case 'lp3_pkk_l': return 'LP3 PKK (L)';
      case 'lp3_pkk_p': return 'LP3 PKK (P)';
      case 'tp3_pkk': return 'TP3 PKK Jml';
      case 'tp3_pkk_l': return 'TP3 PKK (L)';
      case 'tp3_pkk_p': return 'TP3 PKK (P)';
      case 'damas_pkk': return 'Damas PKK Jml';
      case 'damas_pkk_l': return 'Damas PKK (L)';
      case 'damas_pkk_p': return 'Damas PKK (P)';
      case 'keterangan': return 'Keterangan';
      default:
        return field;
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
  String get label =>
      this == StatusKegiatan.dibaca ? 'Sudah Dibaca' : 'Terkirim';
}

// ============================================================
// MODEL
// ============================================================
class CatatanKegiatan {
  final int id;
  final String judul;
  final String deskripsiSingkat;
  final PokjaKategori kategori;
  final Map<String, dynamic> dataAngka; // âœ… dynamic â€” bisa int + string
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
  }) : deskripsiSingkat = deskripsiSingkat ?? ceritaSingkat ?? '',
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
  // TO JSON â€” untuk kirim ke backend
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsiSingkat,
      'kategori_pokja': kategori.kategoriPokja, // âœ… FIX: string
      'data_angka': dataAngka,
      'kecamatan': kecamatan,
      'desa_kelurahan': desa,
      'foto_path': fotoPath,
      'tanggal': tanggal.toIso8601String(),
      'status': status.index,
    };
  }

  // ============================================================
  // FROM JSON â€” untuk baca dari backend
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
      parsedTanggal =
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else if (json['tanggal'] != null) {
      parsedTanggal =
          DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now();
    }

    return CatatanKegiatan(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      judul:
          json['judul']?.toString() ??
          json['judul_kegiatan']?.toString() ??
          json['title']?.toString() ??
          '',
      deskripsiSingkat:
          json['deskripsi']?.toString() ??
          json['deskripsi_singkat']?.toString() ??
          json['keterangan']?.toString() ??
          '',
      kategori: parseKategori(
        json['kategori_pokja'] ?? json['kategori'] ?? 'I',
      ),
      dataAngka: dataAngka,
      kecamatan:
          json['kecamatan']?.toString() ??
          json['nama_kecamatan']?.toString() ??
          '',
      desa:
          json['desa']?.toString() ??
          json['desa_kelurahan']?.toString() ??
          json['kelurahan']?.toString(),
      fotoPath:
          json['foto']?.toString() ??
          json['foto_path']?.toString() ??
          json['foto_url']?.toString(),
      tanggal: parsedTanggal,
      status: json['status'] == 'dibaca' || json['status'] == 1
          ? StatusKegiatan.dibaca
          : StatusKegiatan.terkirim,
    );
  }

  // ============================================================
  // KIRIM KE BACKEND â€” POST /api/laporan-kegiatan
  // ============================================================
  static Future<Map<String, dynamic>> kirimKeBackend({
    required String token,
    required CatatanKegiatan catatan,
  }) async {
    final payload = {
      'judul': catatan.judul,
      'deskripsi': catatan.deskripsiSingkat,
      'kategori_pokja': catatan.kategori.kategoriPokja, // âœ… IV, IV-PYD, dll
      'data_angka': catatan.dataAngka,
      'kecamatan': catatan.kecamatan,
      'desa_kelurahan': catatan.desa,
    };

    final response = await http.post(
      Uri.parse(
        '${AppConstants.baseUrl}/api/laporan-kegiatan',
      ), // âœ… FIX: endpoint
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
