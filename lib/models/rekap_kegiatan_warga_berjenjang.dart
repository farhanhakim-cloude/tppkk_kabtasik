// lib/models/rekap_kegiatan_warga_berjenjang.dart
// Model untuk Form Rekap Berjenjang Catatan Data dan Kegiatan Warga
// Sesuai format excel resmi untuk 5 Tingkat: RT, RW, Dusun, Desa, Kecamatan

class RekapKegiatanWargaBerjenjangItem {
  final int id;
  final String level; // 'rt', 'rw', 'dusun', 'desa', 'kecamatan'
  final String tahun;
  final String kabupaten;
  final String provinsi;
  final String kecamatan;
  final String desa;
  final String dusun;
  final String rw;
  final String rt;
  final String dasaWisma;

  // Kolom pengenal baris sesuai tingkat
  final String namaDasawisma; // RT & RW
  final String nomorRt;       // RW
  final String nomorRw;       // Dusun
  final String namaDusun;     // Desa
  final String namaDesa;      // Kecamatan

  // Jumlah Wilayah Binaan (Dusun, RW, RT, Dasawisma)
  final int jumlahDusun;      // Kecamatan
  final int jumlahRw;         // Dusun (bisa), Desa, Kecamatan
  final int jumlahRt;         // Dusun, Desa, Kecamatan
  final int jumlahDasawisma;  // RW, Dusun, Desa, Kecamatan

  // Jumlah KRT & KK
  final int jumlahKrt;
  final int jumlahKk;

  // Jumlah Anggota Keluarga
  final int totalL;
  final int totalP;
  final int balitaL;
  final int balitaP;
  final int pus; // Pasangan Usia Subur
  final int wus; // Wanita Usia Subur
  final int ibuHamil;
  final int ibuMenyusui;
  final int lansia;
  final int butaL; // 3 Buta L
  final int butaP; // 3 Buta P
  final int berkebutuhanKhusus;

  // Kriteria Rumah
  final int rumahSehat;
  final int rumahTidakSehat;
  final int tempatSampah;
  final int spal;
  final int jambanMck;

  // Sumber Air Keluarga
  final int airPdam;
  final int airSumur;
  final int airSungai;
  final int airDll;

  // Makanan Pokok
  final int makananBeras;
  final int makananNonBeras;

  // Warga Mengikuti Kegiatan
  final int kegiatanUp2k;
  final int kegiatanPekarangan;
  final int kegiatanIndustriRt;
  final int kegiatanKesling;

  // Keterangan
  final String keterangan;

  RekapKegiatanWargaBerjenjangItem({
    required this.id,
    required this.level,
    this.tahun = '2026',
    this.kabupaten = 'Tasikmalaya',
    this.provinsi = 'Jawa Barat',
    this.kecamatan = 'Singaparna',
    this.desa = 'Singaparna',
    this.dusun = 'Cikunir',
    this.rw = '05',
    this.rt = '01',
    this.dasaWisma = 'Mawar 01',
    this.namaDasawisma = '',
    this.nomorRt = '',
    this.nomorRw = '',
    this.namaDusun = '',
    this.namaDesa = '',
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
    this.tempatSampah = 0,
    this.spal = 0,
    this.jambanMck = 0,
    this.airPdam = 0,
    this.airSumur = 0,
    this.airSungai = 0,
    this.airDll = 0,
    this.makananBeras = 0,
    this.makananNonBeras = 0,
    this.kegiatanUp2k = 0,
    this.kegiatanPekarangan = 0,
    this.kegiatanIndustriRt = 0,
    this.kegiatanKesling = 0,
    this.keterangan = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'tahun': tahun,
        'kabupaten': kabupaten,
        'provinsi': provinsi,
        'kecamatan': kecamatan,
        'desa': desa,
        'dusun': dusun,
        'rw': rw,
        'rt': rt,
        'dasaWisma': dasaWisma,
        'namaDasawisma': namaDasawisma,
        'nomorRt': nomorRt,
        'nomorRw': nomorRw,
        'namaDusun': namaDusun,
        'namaDesa': namaDesa,
        'jumlahDusun': jumlahDusun,
        'jumlahRw': jumlahRw,
        'jumlahRt': jumlahRt,
        'jumlahDasawisma': jumlahDasawisma,
        'jumlahKrt': jumlahKrt,
        'jumlahKk': jumlahKk,
        'totalL': totalL,
        'totalP': totalP,
        'balitaL': balitaL,
        'balitaP': balitaP,
        'pus': pus,
        'wus': wus,
        'ibuHamil': ibuHamil,
        'ibuMenyusui': ibuMenyusui,
        'lansia': lansia,
        'butaL': butaL,
        'butaP': butaP,
        'berkebutuhanKhusus': berkebutuhanKhusus,
        'rumahSehat': rumahSehat,
        'rumahTidakSehat': rumahTidakSehat,
        'tempatSampah': tempatSampah,
        'spal': spal,
        'jambanMck': jambanMck,
        'airPdam': airPdam,
        'airSumur': airSumur,
        'airSungai': airSungai,
        'airDll': airDll,
        'makananBeras': makananBeras,
        'makananNonBeras': makananNonBeras,
        'kegiatanUp2k': kegiatanUp2k,
        'kegiatanPekarangan': kegiatanPekarangan,
        'kegiatanIndustriRt': kegiatanIndustriRt,
        'kegiatanKesling': kegiatanKesling,
        'keterangan': keterangan,
      };

  factory RekapKegiatanWargaBerjenjangItem.fromJson(Map<String, dynamic> json) =>
      RekapKegiatanWargaBerjenjangItem(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        level: json['level'] ?? 'rt',
        tahun: json['tahun'] ?? '2026',
        kabupaten: json['kabupaten'] ?? 'Tasikmalaya',
        provinsi: json['provinsi'] ?? 'Jawa Barat',
        kecamatan: json['kecamatan'] ?? 'Singaparna',
        desa: json['desa'] ?? 'Singaparna',
        dusun: json['dusun'] ?? 'Cikunir',
        rw: json['rw'] ?? '05',
        rt: json['rt'] ?? '01',
        dasaWisma: json['dasaWisma'] ?? 'Mawar 01',
        namaDasawisma: json['namaDasawisma'] ?? '',
        nomorRt: json['nomorRt'] ?? '',
        nomorRw: json['nomorRw'] ?? '',
        namaDusun: json['namaDusun'] ?? '',
        namaDesa: json['namaDesa'] ?? '',
        jumlahDusun: json['jumlahDusun'] ?? 0,
        jumlahRw: json['jumlahRw'] ?? 0,
        jumlahRt: json['jumlahRt'] ?? 0,
        jumlahDasawisma: json['jumlahDasawisma'] ?? 0,
        jumlahKrt: json['jumlahKrt'] ?? 0,
        jumlahKk: json['jumlahKk'] ?? 0,
        totalL: json['totalL'] ?? 0,
        totalP: json['totalP'] ?? 0,
        balitaL: json['balitaL'] ?? 0,
        balitaP: json['balitaP'] ?? 0,
        pus: json['pus'] ?? 0,
        wus: json['wus'] ?? 0,
        ibuHamil: json['ibuHamil'] ?? 0,
        ibuMenyusui: json['ibuMenyusui'] ?? 0,
        lansia: json['lansia'] ?? 0,
        butaL: json['butaL'] ?? 0,
        butaP: json['butaP'] ?? 0,
        berkebutuhanKhusus: json['berkebutuhanKhusus'] ?? 0,
        rumahSehat: json['rumahSehat'] ?? 0,
        rumahTidakSehat: json['rumahTidakSehat'] ?? 0,
        tempatSampah: json['tempatSampah'] ?? 0,
        spal: json['spal'] ?? 0,
        jambanMck: json['jambanMck'] ?? 0,
        airPdam: json['airPdam'] ?? 0,
        airSumur: json['airSumur'] ?? 0,
        airSungai: json['airSungai'] ?? 0,
        airDll: json['airDll'] ?? 0,
        makananBeras: json['makananBeras'] ?? 0,
        makananNonBeras: json['makananNonBeras'] ?? 0,
        kegiatanUp2k: json['kegiatanUp2k'] ?? 0,
        kegiatanPekarangan: json['kegiatanPekarangan'] ?? 0,
        kegiatanIndustriRt: json['kegiatanIndustriRt'] ?? 0,
        kegiatanKesling: json['kegiatanKesling'] ?? 0,
        keterangan: json['keterangan'] ?? '',
      );

  RekapKegiatanWargaBerjenjangItem copyWith({
    int? id,
    String? level,
    String? tahun,
    String? kabupaten,
    String? provinsi,
    String? kecamatan,
    String? desa,
    String? dusun,
    String? rw,
    String? rt,
    String? dasaWisma,
    String? namaDasawisma,
    String? nomorRt,
    String? nomorRw,
    String? namaDusun,
    String? namaDesa,
    int? jumlahDusun,
    int? jumlahRw,
    int? jumlahRt,
    int? jumlahDasawisma,
    int? jumlahKrt,
    int? jumlahKk,
    int? totalL,
    int? totalP,
    int? balitaL,
    int? balitaP,
    int? pus,
    int? wus,
    int? ibuHamil,
    int? ibuMenyusui,
    int? lansia,
    int? butaL,
    int? butaP,
    int? berkebutuhanKhusus,
    int? rumahSehat,
    int? rumahTidakSehat,
    int? tempatSampah,
    int? spal,
    int? jambanMck,
    int? airPdam,
    int? airSumur,
    int? airSungai,
    int? airDll,
    int? makananBeras,
    int? makananNonBeras,
    int? kegiatanUp2k,
    int? kegiatanPekarangan,
    int? kegiatanIndustriRt,
    int? kegiatanKesling,
    String? keterangan,
  }) {
    return RekapKegiatanWargaBerjenjangItem(
      id: id ?? this.id,
      level: level ?? this.level,
      tahun: tahun ?? this.tahun,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      dusun: dusun ?? this.dusun,
      rw: rw ?? this.rw,
      rt: rt ?? this.rt,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      namaDasawisma: namaDasawisma ?? this.namaDasawisma,
      nomorRt: nomorRt ?? this.nomorRt,
      nomorRw: nomorRw ?? this.nomorRw,
      namaDusun: namaDusun ?? this.namaDusun,
      namaDesa: namaDesa ?? this.namaDesa,
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
      tempatSampah: tempatSampah ?? this.tempatSampah,
      spal: spal ?? this.spal,
      jambanMck: jambanMck ?? this.jambanMck,
      airPdam: airPdam ?? this.airPdam,
      airSumur: airSumur ?? this.airSumur,
      airSungai: airSungai ?? this.airSungai,
      airDll: airDll ?? this.airDll,
      makananBeras: makananBeras ?? this.makananBeras,
      makananNonBeras: makananNonBeras ?? this.makananNonBeras,
      kegiatanUp2k: kegiatanUp2k ?? this.kegiatanUp2k,
      kegiatanPekarangan: kegiatanPekarangan ?? this.kegiatanPekarangan,
      kegiatanIndustriRt: kegiatanIndustriRt ?? this.kegiatanIndustriRt,
      kegiatanKesling: kegiatanKesling ?? this.kegiatanKesling,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
