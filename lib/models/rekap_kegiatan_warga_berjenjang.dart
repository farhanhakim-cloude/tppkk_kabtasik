// lib/models/rekap_kegiatan_warga_berjenjang.dart
// ✅ HYBRID: Field lama (screen jalan) + field baru (API) + fromJson hybrid

class RekapKegiatanWargaBerjenjangItem {
  final int id;
  final int? wilayahId;
  final String level;
  final String tahun;

  // Wilayah
  final String kabupaten;
  final String provinsi;
  final String kecamatan;
  final String namaKecamatan;
  final String desa;
  final String namaDesa;
  final String dusun;
  final String namaDusun;
  final String rw;
  final String rt;
  final String dasaWisma;

  // ✅ Field lama — biar screen lama jalan
  final String namaDasawisma;
  final String nomorRt;
  final String nomorRw;

  // Jumlah Wilayah Binaan
  final int jumlahDusun;
  final int jumlahRw;
  final int jumlahRt;
  final int jumlahDasawisma;   // ← pakai 's' — sesuai screen lama

  // Jumlah KRT & KK
  final int jumlahKrt;
  final int jumlahKk;

  // Jumlah Anggota Keluarga
  final int totalL;
  final int totalP;
  final int balitaL;
  final int balitaP;
  final int pus;
  final int wus;
  final int ibuHamil;
  final int ibuMenyusui;
  final int lansia;
  final int butaL;
  final int butaP;
  final int berkebutuhanKhusus;  // ← balikin — screen lama

  // Kriteria Rumah
  final int rumahSehat;
  final int rumahTidakSehat;    // ← balikin — screen lama
  final int rumahKurangSehat;   // ← baru — API
  final int tempatSampah;       // ← balikin — screen lama
  final int memilikiTempatSampah; // ← baru — API
  final int spal;               // ← balikin — screen lama
  final int memilikiSpal;       // ← baru — API
  final int memilikiStikerP4k;
  final int jambanMck;          // ← balikin — screen lama
  final int jumlahJambanKeluarga; // ← baru — API

  // Sumber Air Keluarga
  final int airPdam;
  final int airSumur;
  final int airSungai;
  final int airDll;

  // Makanan Pokok
  final int makananBeras;       // ← balikin — screen lama
  final int makananPokokBeras;  // ← baru — API
  final int makananNonBeras;    // ← balikin — screen lama
  final int makananPokokNonBeras; // ← baru — API

  // Warga Mengikuti Kegiatan
  final int kegiatanUp2k;
  final int kegiatanPekarangan;          // ← balikin
  final int kegiatanTanahPekarangan;     // ← baru
  final int kegiatanIndustriRt;          // ← balikin
  final int kegiatanIndustriRumahTangga; // ← baru
  final int kegiatanKesling;             // ← balikin
  final int kegiatanKesehatanLingkungan; // ← baru

  // Keterangan
  final String keterangan;

  RekapKegiatanWargaBerjenjangItem({
    required this.id,
    this.wilayahId,
    this.level = 'rt',
    this.tahun = '2026',
    this.kabupaten = 'Tasikmalaya',
    this.provinsi = 'Jawa Barat',
    this.kecamatan = '',
    this.namaKecamatan = '',
    this.desa = '',
    this.namaDesa = '',
    this.dusun = '',
    this.namaDusun = '',
    this.rw = '',
    this.rt = '',
    this.dasaWisma = '',
    this.namaDasawisma = '',
    this.nomorRt = '',
    this.nomorRw = '',
    this.jumlahDusun = 0,
    this.jumlahRw = 0,
    this.jumlahRt = 0,
    this.jumlahDasawisma = 0,
    this.jumlahKrt = 0,
    this.jumlahKk = 0,
    this.totalL = 0,
    this.totalP = 0,
    this.balitaL = 0,
    this.balitaP = 0,
    this.pus = 0,
    this.wus = 0,
    this.ibuHamil = 0,
    this.ibuMenyusui = 0,
    this.lansia = 0,
    this.butaL = 0,
    this.butaP = 0,
    this.berkebutuhanKhusus = 0,
    this.rumahSehat = 0,
    this.rumahTidakSehat = 0,
    this.rumahKurangSehat = 0,
    this.tempatSampah = 0,
    this.memilikiTempatSampah = 0,
    this.spal = 0,
    this.memilikiSpal = 0,
    this.memilikiStikerP4k = 0,
    this.jambanMck = 0,
    this.jumlahJambanKeluarga = 0,
    this.airPdam = 0,
    this.airSumur = 0,
    this.airSungai = 0,
    this.airDll = 0,
    this.makananBeras = 0,
    this.makananPokokBeras = 0,
    this.makananNonBeras = 0,
    this.makananPokokNonBeras = 0,
    this.kegiatanUp2k = 0,
    this.kegiatanPekarangan = 0,
    this.kegiatanTanahPekarangan = 0,
    this.kegiatanIndustriRt = 0,
    this.kegiatanIndustriRumahTangga = 0,
    this.kegiatanKesling = 0,
    this.kegiatanKesehatanLingkungan = 0,
    this.keterangan = '',
  });

  // ============================================================
  // GETTER
  // ============================================================
  int get totalAnggotaKeluarga => totalL + totalP;
  int get totalBalita => balitaL + balitaP;
  int get totalButa => butaL + butaP;
  int get totalAir => airPdam + airSumur + airSungai + airDll;

  // Payload uses the Laravel table column names.
  Map<String, dynamic> toJson() => {
        'id': id,
        'wilayah_id': wilayahId,
        'level': level,
        'tahun': tahun,
        'kecamatan': kecamatan,
        'nama_kecamatan': namaKecamatan.isNotEmpty ? namaKecamatan : kecamatan,
        'desa': desa,
        'nama_desa': namaDesa.isNotEmpty ? namaDesa : desa,
        'dusun': dusun,
        'nama_dusun': namaDusun.isNotEmpty ? namaDusun : dusun,
        'rw': rw,
        'rt': rt,
        'jumlah_dusun': jumlahDusun,
        'jumlah_rw': jumlahRw,
        'jumlah_rt': jumlahRt,
        'jumlah_dasa_wisma': jumlahDasawisma,
        'jumlah_krt': jumlahKrt,
        'jumlah_kk': jumlahKk,
        'total_l': totalL,
        'total_p': totalP,
        'balita_l': balitaL,
        'balita_p': balitaP,
        'pus': pus,
        'wus': wus,
        'ibu_hamil': ibuHamil,
        'ibu_menyusui': ibuMenyusui,
        'lansia': lansia,
        'buta_l': butaL,
        'buta_p': butaP,
        'rumah_sehat': rumahSehat,
        'rumah_kurang_sehat': rumahKurangSehat,
        'memiliki_tempat_sampah': memilikiTempatSampah,
        'memiliki_spal': memilikiSpal,
        'memiliki_stiker_p4k': memilikiStikerP4k,
        'air_pdam': airPdam,
        'air_sumur': airSumur,
        'air_sungai': airSungai,
        'air_dll': airDll,
        'jumlah_jamban_keluarga': jumlahJambanKeluarga,
        'makanan_pokok_beras': makananPokokBeras,
        'makanan_pokok_non_beras': makananPokokNonBeras,
        'kegiatan_up2k': kegiatanUp2k,
        'kegiatan_tanah_pekarangan': kegiatanTanahPekarangan,
        'kegiatan_industri_rumah_tangga': kegiatanIndustriRumahTangga,
        'kegiatan_kesehatan_lingkungan': kegiatanKesehatanLingkungan,
        'keterangan': keterangan,
      };

  // ============================================================
  // FROM JSON — HYBRID: camelCase ATAU snake_case
  // ============================================================
  factory RekapKegiatanWargaBerjenjangItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      RekapKegiatanWargaBerjenjangItem(
        id: _p(json['id']),
        wilayahId: json['wilayah_id'] != null ? _p(json['wilayah_id']) : null,
        level: json['level']?.toString() ?? 'rt',
        tahun: json['tahun']?.toString() ?? '2026',
        kabupaten: json['kabupaten']?.toString() ?? 'Tasikmalaya',
        provinsi: json['provinsi']?.toString() ?? 'Jawa Barat',
        kecamatan: json['kecamatan']?.toString() ?? '',
        namaKecamatan: (json['namaKecamatan'] ?? json['nama_kecamatan'])?.toString() ?? '',
        desa: json['desa']?.toString() ?? '',
        namaDesa: (json['namaDesa'] ?? json['nama_desa'])?.toString() ?? '',
        dusun: json['dusun']?.toString() ?? '',
        namaDusun: (json['namaDusun'] ?? json['nama_dusun'])?.toString() ?? '',
        rw: json['rw']?.toString() ?? '',
        rt: json['rt']?.toString() ?? '',
        dasaWisma: (json['dasaWisma'] ?? json['dasa_wisma'])?.toString() ?? '',
        namaDasawisma: (json['namaDasawisma'] ?? json['nama_dasawisma'])?.toString() ?? '',
        nomorRt: (json['nomorRt'] ?? json['nomor_rt'] ?? json['rt'])?.toString() ?? '',
        nomorRw: (json['nomorRw'] ?? json['nomor_rw'] ?? json['rw'])?.toString() ?? '',
        jumlahDusun: _p(json['jumlahDusun'] ?? json['jumlah_dusun']),
        jumlahRw: _p(json['jumlahRw'] ?? json['jumlah_rw']),
        jumlahRt: _p(json['jumlahRt'] ?? json['jumlah_rt']),
        jumlahDasawisma: _p(json['jumlahDasawisma'] ?? json['jumlah_dasa_wisma']),
        jumlahKrt: _p(json['jumlahKrt'] ?? json['jumlah_krt']),
        jumlahKk: _p(json['jumlahKk'] ?? json['jumlah_kk']),
        totalL: _p(json['totalL'] ?? json['total_l']),
        totalP: _p(json['totalP'] ?? json['total_p']),
        balitaL: _p(json['balitaL'] ?? json['balita_l']),
        balitaP: _p(json['balitaP'] ?? json['balita_p']),
        pus: _p(json['pus']),
        wus: _p(json['wus']),
        ibuHamil: _p(json['ibuHamil'] ?? json['ibu_hamil']),
        ibuMenyusui: _p(json['ibuMenyusui'] ?? json['ibu_menyusui']),
        lansia: _p(json['lansia']),
        butaL: _p(json['butaL'] ?? json['buta_l']),
        butaP: _p(json['butaP'] ?? json['buta_p']),
        berkebutuhanKhusus: _p(json['berkebutuhanKhusus'] ?? json['berkebutuhan_khusus']),
        rumahSehat: _p(json['rumahSehat'] ?? json['rumah_sehat']),
        rumahTidakSehat: _p(json['rumahTidakSehat'] ?? json['rumah_tidak_sehat'] ?? json['rumah_kurang_sehat']),
        rumahKurangSehat: _p(json['rumahKurangSehat'] ?? json['rumah_kurang_sehat'] ?? json['rumah_tidak_sehat']),
        tempatSampah: _p(json['tempatSampah'] ?? json['tempat_sampah'] ?? json['memiliki_tempat_sampah']),
        memilikiTempatSampah: _p(json['memilikiTempatSampah'] ?? json['memiliki_tempat_sampah'] ?? json['tempat_sampah']),
        spal: _p(json['spal'] ?? json['memiliki_spal']),
        memilikiSpal: _p(json['memilikiSpal'] ?? json['memiliki_spal'] ?? json['spal']),
        memilikiStikerP4k: _p(json['memilikiStikerP4k'] ?? json['memiliki_stiker_p4k']),
        jambanMck: _p(json['jambanMck'] ?? json['jamban_mck'] ?? json['jumlah_jamban_keluarga']),
        jumlahJambanKeluarga: _p(json['jumlahJambanKeluarga'] ?? json['jumlah_jamban_keluarga'] ?? json['jamban_mck']),
        airPdam: _p(json['airPdam'] ?? json['air_pdam']),
        airSumur: _p(json['airSumur'] ?? json['air_sumur']),
        airSungai: _p(json['airSungai'] ?? json['air_sungai']),
        airDll: _p(json['airDll'] ?? json['air_dll']),
        makananBeras: _p(json['makananBeras'] ?? json['makanan_beras'] ?? json['makanan_pokok_beras']),
        makananPokokBeras: _p(json['makananPokokBeras'] ?? json['makanan_pokok_beras'] ?? json['makanan_beras']),
        makananNonBeras: _p(json['makananNonBeras'] ?? json['makanan_non_beras'] ?? json['makanan_pokok_non_beras']),
        makananPokokNonBeras: _p(json['makananPokokNonBeras'] ?? json['makanan_pokok_non_beras'] ?? json['makanan_non_beras']),
        kegiatanUp2k: _p(json['kegiatanUp2k'] ?? json['kegiatan_up2k']),
        kegiatanPekarangan: _p(json['kegiatanPekarangan'] ?? json['kegiatan_pekarangan'] ?? json['kegiatan_tanah_pekarangan']),
        kegiatanTanahPekarangan: _p(json['kegiatanTanahPekarangan'] ?? json['kegiatan_tanah_pekarangan'] ?? json['kegiatan_pekarangan']),
        kegiatanIndustriRt: _p(json['kegiatanIndustriRt'] ?? json['kegiatan_industri_rt'] ?? json['kegiatan_industri_rumah_tangga']),
        kegiatanIndustriRumahTangga: _p(json['kegiatanIndustriRumahTangga'] ?? json['kegiatan_industri_rumah_tangga'] ?? json['kegiatan_industri_rt']),
        kegiatanKesling: _p(json['kegiatanKesling'] ?? json['kegiatan_kesling'] ?? json['kegiatan_kesehatan_lingkungan']),
        kegiatanKesehatanLingkungan: _p(json['kegiatanKesehatanLingkungan'] ?? json['kegiatan_kesehatan_lingkungan'] ?? json['kegiatan_kesling']),
        keterangan: json['keterangan']?.toString() ?? '',
      );

  static int _p(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ============================================================
  // COPY WITH
  // ============================================================
  RekapKegiatanWargaBerjenjangItem copyWith({
    int? id, int? wilayahId, String? level, String? tahun,
    String? kabupaten, String? provinsi,
    String? kecamatan, String? namaKecamatan,
    String? desa, String? namaDesa, String? dusun, String? namaDusun,
    String? rw, String? rt, String? dasaWisma,
    String? namaDasawisma, String? nomorRt, String? nomorRw,
    int? jumlahDusun, int? jumlahRw, int? jumlahRt, int? jumlahDasawisma,
    int? jumlahKrt, int? jumlahKk, int? totalL, int? totalP,
    int? balitaL, int? balitaP, int? pus, int? wus,
    int? ibuHamil, int? ibuMenyusui, int? lansia,
    int? butaL, int? butaP, int? berkebutuhanKhusus,
    int? rumahSehat, int? rumahTidakSehat, int? rumahKurangSehat,
    int? tempatSampah, int? memilikiTempatSampah,
    int? spal, int? memilikiSpal, int? memilikiStikerP4k,
    int? jambanMck, int? jumlahJambanKeluarga,
    int? airPdam, int? airSumur, int? airSungai, int? airDll,
    int? makananBeras, int? makananPokokBeras,
    int? makananNonBeras, int? makananPokokNonBeras,
    int? kegiatanUp2k, int? kegiatanPekarangan, int? kegiatanTanahPekarangan,
    int? kegiatanIndustriRt, int? kegiatanIndustriRumahTangga,
    int? kegiatanKesling, int? kegiatanKesehatanLingkungan,
    String? keterangan,
  }) => RekapKegiatanWargaBerjenjangItem(
        id: id ?? this.id,
        wilayahId: wilayahId ?? this.wilayahId,
        level: level ?? this.level,
        tahun: tahun ?? this.tahun,
        kabupaten: kabupaten ?? this.kabupaten,
        provinsi: provinsi ?? this.provinsi,
        kecamatan: kecamatan ?? this.kecamatan,
        namaKecamatan: namaKecamatan ?? this.namaKecamatan,
        desa: desa ?? this.desa,
        namaDesa: namaDesa ?? this.namaDesa,
        dusun: dusun ?? this.dusun,
        namaDusun: namaDusun ?? this.namaDusun,
        rw: rw ?? this.rw,
        rt: rt ?? this.rt,
        dasaWisma: dasaWisma ?? this.dasaWisma,
        namaDasawisma: namaDasawisma ?? this.namaDasawisma,
        nomorRt: nomorRt ?? this.nomorRt,
        nomorRw: nomorRw ?? this.nomorRw,
        jumlahDusun: jumlahDusun ?? this.jumlahDusun,
        jumlahRw: jumlahRw ?? this.jumlahRw,
        jumlahRt: jumlahRt ?? this.jumlahRt,
        jumlahDasawisma: jumlahDasawisma ?? this.jumlahDasawisma,
        jumlahKrt: jumlahKrt ?? this.jumlahKrt,
        jumlahKk: jumlahKk ?? this.jumlahKk,
        totalL: totalL ?? this.totalL,
        totalP: totalP ?? this.totalP,
        balitaL: balitaL ?? this.balitaL,
        balitaP: balitaP ?? this.balitaP,
        pus: pus ?? this.pus,
        wus: wus ?? this.wus,
        ibuHamil: ibuHamil ?? this.ibuHamil,
        ibuMenyusui: ibuMenyusui ?? this.ibuMenyusui,
        lansia: lansia ?? this.lansia,
        butaL: butaL ?? this.butaL,
        butaP: butaP ?? this.butaP,
        berkebutuhanKhusus: berkebutuhanKhusus ?? this.berkebutuhanKhusus,
        rumahSehat: rumahSehat ?? this.rumahSehat,
        rumahTidakSehat: rumahTidakSehat ?? this.rumahTidakSehat,
        rumahKurangSehat: rumahKurangSehat ?? this.rumahKurangSehat,
        tempatSampah: tempatSampah ?? this.tempatSampah,
        memilikiTempatSampah: memilikiTempatSampah ?? this.memilikiTempatSampah,
        spal: spal ?? this.spal,
        memilikiSpal: memilikiSpal ?? this.memilikiSpal,
        memilikiStikerP4k: memilikiStikerP4k ?? this.memilikiStikerP4k,
        jambanMck: jambanMck ?? this.jambanMck,
        jumlahJambanKeluarga: jumlahJambanKeluarga ?? this.jumlahJambanKeluarga,
        airPdam: airPdam ?? this.airPdam,
        airSumur: airSumur ?? this.airSumur,
        airSungai: airSungai ?? this.airSungai,
        airDll: airDll ?? this.airDll,
        makananBeras: makananBeras ?? this.makananBeras,
        makananPokokBeras: makananPokokBeras ?? this.makananPokokBeras,
        makananNonBeras: makananNonBeras ?? this.makananNonBeras,
        makananPokokNonBeras: makananPokokNonBeras ?? this.makananPokokNonBeras,
        kegiatanUp2k: kegiatanUp2k ?? this.kegiatanUp2k,
        kegiatanPekarangan: kegiatanPekarangan ?? this.kegiatanPekarangan,
        kegiatanTanahPekarangan: kegiatanTanahPekarangan ?? this.kegiatanTanahPekarangan,
        kegiatanIndustriRt: kegiatanIndustriRt ?? this.kegiatanIndustriRt,
        kegiatanIndustriRumahTangga: kegiatanIndustriRumahTangga ?? this.kegiatanIndustriRumahTangga,
        kegiatanKesling: kegiatanKesling ?? this.kegiatanKesling,
        kegiatanKesehatanLingkungan: kegiatanKesehatanLingkungan ?? this.kegiatanKesehatanLingkungan,
        keterangan: keterangan ?? this.keterangan,
      );
}