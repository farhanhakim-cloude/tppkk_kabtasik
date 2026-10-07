// lib/models/bumil_ibu.dart
// Kontrak: tabel Laravel `rekap_bumil_dasa_wismas`.
// 1 baris = 1 ibu + 1 status per bulan (hamil/melahirkan/nifas/meninggal).
// Status ditentukan server.

class BumilIbu {
  final String id;
  final int tahun;
  final int bulan;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String nama;
  final String suamiNama;
  final int umur;
  final String statusIbu; // hamil|melahirkan|nifas|meninggal

  // Kelahiran (bila melahirkan)
  final String bayiNama;
  final String bayiJenisKelamin; // L / P
  final DateTime? bayiTanggalLahir;
  final bool? bayiAkta; // true=Ada, false=Tidak, null=belum tahu

  // Kematian (bila ada)
  final String kematianKategori; // ibu / bayi / balita
  final int? kematianUmurBulan; // otomatisasi kategori: <12 bayi, 12-59 balita
  final String kematianNama;
  final String kematianJenisKelamin;
  final DateTime? kematianTanggal;
  final String kematianSebab;

  final String keterangan;

  // --- Ditentukan server, jangan dikirim saat create/update ---
  final String status; // pending|approved|rejected
  final String? rejectedReason;
  final String? approvedByName;

  // --- Berjenjang (nullable, aman jika server tidak mengirim) ---
  final String? kecamatanStatus;
  final String? kecamatanRejectedReason;

  BumilIbu({
    required this.id,
    required this.tahun,
    required this.bulan,
    this.dasaWisma = '',
    this.rt = '',
    this.rw = '',
    this.dusun = '',
    this.desa = '',
    this.kecamatan = '',
    required this.nama,
    this.suamiNama = '',
    this.umur = 0,
    this.statusIbu = 'hamil',
    this.bayiNama = '',
    this.bayiJenisKelamin = '',
    this.bayiTanggalLahir,
    this.bayiAkta,
    this.kematianKategori = '',
    this.kematianUmurBulan,
    this.kematianNama = '',
    this.kematianJenisKelamin = '',
    this.kematianTanggal,
    this.kematianSebab = '',
    this.keterangan = '',
    this.status = 'pending',
    this.rejectedReason,
    this.approvedByName,
    this.kecamatanStatus,
    this.kecamatanRejectedReason,
  });

  static const Map<String, String> statusLabels = {
    'hamil': 'Hamil',
    'melahirkan': 'Melahirkan',
    'nifas': 'Nifas',
  };

  static const Map<int, String> namaBulan = {
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };

  String get statusIbuLabel => statusLabels[statusIbu] ?? statusIbu;
  String get bulanLabel => namaBulan[bulan] ?? 'Bulan $bulan';

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Perlu Diperbaiki';
      default:
        return 'Menunggu';
    }
  }

  BumilIbu copyWith({
    String? id,
    int? tahun,
    int? bulan,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? nama,
    String? suamiNama,
    int? umur,
    String? statusIbu,
    String? bayiNama,
    String? bayiJenisKelamin,
    DateTime? bayiTanggalLahir,
    bool? bayiAkta,
    String? kematianKategori,
    int? kematianUmurBulan,
    String? kematianNama,
    String? kematianJenisKelamin,
    DateTime? kematianTanggal,
    String? kematianSebab,
    String? keterangan,
    String? status,
    String? rejectedReason,
    String? approvedByName,
    String? kecamatanStatus,
    String? kecamatanRejectedReason,
  }) {
    return BumilIbu(
      id: id ?? this.id,
      tahun: tahun ?? this.tahun,
      bulan: bulan ?? this.bulan,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      nama: nama ?? this.nama,
      suamiNama: suamiNama ?? this.suamiNama,
      umur: umur ?? this.umur,
      statusIbu: statusIbu ?? this.statusIbu,
      bayiNama: bayiNama ?? this.bayiNama,
      bayiJenisKelamin: bayiJenisKelamin ?? this.bayiJenisKelamin,
      bayiTanggalLahir: bayiTanggalLahir ?? this.bayiTanggalLahir,
      bayiAkta: bayiAkta ?? this.bayiAkta,
      kematianKategori: kematianKategori ?? this.kematianKategori,
      kematianUmurBulan: kematianUmurBulan ?? this.kematianUmurBulan,
      kematianNama: kematianNama ?? this.kematianNama,
      kematianJenisKelamin:
          kematianJenisKelamin ?? this.kematianJenisKelamin,
      kematianTanggal: kematianTanggal ?? this.kematianTanggal,
      kematianSebab: kematianSebab ?? this.kematianSebab,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      approvedByName: approvedByName ?? this.approvedByName,
      kecamatanStatus: kecamatanStatus ?? this.kecamatanStatus,
      kecamatanRejectedReason:
          kecamatanRejectedReason ?? this.kecamatanRejectedReason,
    );
  }

  factory BumilIbu.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v == null ? '' : v.toString();
    int intOf(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    DateTime? dateOf(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    bool? boolOf(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is num) return v == 1;
      final s = v.toString().toLowerCase();
      if (s == '1' || s == 'true') return true;
      if (s == '0' || s == 'false') return false;
      return null;
    }

    String? approvedName;
    final approvedBy = json['approved_by'] ?? json['approvedBy'];
    if (approvedBy is Map<String, dynamic>) {
      approvedName = approvedBy['name']?.toString();
    }

    return BumilIbu(
      id: str(json['id']),
      tahun: intOf(json['tahun']) == 0
          ? DateTime.now().year
          : intOf(json['tahun']),
      bulan: intOf(json['bulan']) == 0
          ? DateTime.now().month
          : intOf(json['bulan']),
      dasaWisma:
          str(json['dasawisma'] ?? json['dasa_wisma'] ?? json['dasaWisma']),
      rt: str(json['rt']),
      rw: str(json['rw']),
      dusun: str(json['dusun']),
      desa: str(json['desa']),
      kecamatan: str(json['kecamatan']),
      nama: str(json['nama']),
      suamiNama: str(json['suami_nama'] ?? json['suamiNama']),
      umur: intOf(json['umur']),
      statusIbu: str(json['status_ibu'] ?? json['statusIbu']).isEmpty
          ? 'hamil'
          : str(json['status_ibu'] ?? json['statusIbu']),
      bayiNama: str(json['bayi_nama'] ?? json['bayiNama']),
      bayiJenisKelamin:
          str(json['bayi_jenis_kelamin'] ?? json['bayiJenisKelamin']),
      bayiTanggalLahir:
          dateOf(json['bayi_tanggal_lahir'] ?? json['bayiTanggalLahir']),
      bayiAkta: boolOf(json['bayi_akta'] ?? json['bayiAkta']),
      kematianKategori:
          str(json['kematian_kategori'] ?? json['kematianKategori']),
      kematianUmurBulan: (json['kematian_umur_bulan'] ??
              json['kematianUmurBulan']) ==
          null
          ? null
          : int.tryParse(
              (json['kematian_umur_bulan'] ?? json['kematianUmurBulan'])
                  .toString()),
      kematianNama: str(json['kematian_nama'] ?? json['kematianNama']),
      kematianJenisKelamin: str(
          json['kematian_jenis_kelamin'] ?? json['kematianJenisKelamin']),
      kematianTanggal:
          dateOf(json['kematian_tanggal'] ?? json['kematianTanggal']),
      kematianSebab:
          str(json['kematian_sebab'] ?? json['kematianSebab']),
      keterangan: str(json['keterangan']),
      status:
          str(json['status']).isEmpty ? 'pending' : str(json['status']),
      rejectedReason:
          (json['rejected_reason'] ?? json['rejectedReason'])?.toString(),
      approvedByName: approvedName,
      kecamatanStatus:
          (json['kecamatan_status'] ?? json['kecamatanStatus'])?.toString(),
      kecamatanRejectedReason: (json['kecamatan_rejected_reason'] ??
              json['kecamatanRejectedReason'])
          ?.toString(),
    );
  }

  /// Payload create/update. TIDAK mengirim status/approval —
  /// kecamatan & desa diisi server dari akun login.
  Map<String, dynamic> toJson() {
    String? ymd(DateTime? d) {
      if (d == null) return null;
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '${d.year}-$m-$day';
    }

    return {
      'tahun': tahun,
      'bulan': bulan,
      'dasawisma': dasaWisma,
      'dusun': dusun,
      'rt': rt,
      'rw': rw,
      'nama': nama,
      'suami_nama': suamiNama.isEmpty ? null : suamiNama,
      'umur': umur == 0 ? null : umur,
      'status_ibu': statusIbu,
      'bayi_nama': bayiNama.isEmpty ? null : bayiNama,
      'bayi_jenis_kelamin': bayiJenisKelamin.isEmpty ? null : bayiJenisKelamin,
      'bayi_tanggal_lahir': ymd(bayiTanggalLahir),
      'bayi_akta': bayiAkta,
      'kematian_kategori':
          kematianKategori.isEmpty ? null : kematianKategori,
      'kematian_umur_bulan': kematianUmurBulan,
      'kematian_nama': kematianNama.isEmpty ? null : kematianNama,
      'kematian_jenis_kelamin':
          kematianJenisKelamin.isEmpty ? null : kematianJenisKelamin,
      'kematian_tanggal': ymd(kematianTanggal),
      'kematian_sebab': kematianSebab.isEmpty ? null : kematianSebab,
      'keterangan': keterangan,
    };
  }
}
