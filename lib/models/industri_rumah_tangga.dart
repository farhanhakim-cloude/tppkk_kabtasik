// lib/models/industri_rumah_tangga.dart
// Kontrak: tabel Laravel `industri_rumah_tanggas` + DasawismaResourceCatalog
// 'industri-rumah-tangga'. 1 baris = 1 usaha rumah tangga.
// Status ditentukan server.

class IndustriRumahTangga {
  final String id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String jenisIndustri;
  final String pemilik;
  final int jumlahTenagaKerja;
  final double omzet;

  // --- Ditentukan server, jangan dikirim saat create/update ---
  final String status; // pending|approved|rejected
  final String? rejectedReason;
  final String? approvedByName;

  // --- Berjenjang (nullable, aman jika server tidak mengirim) ---
  final String? kecamatanStatus;
  final String? kecamatanRejectedReason;

  IndustriRumahTangga({
    required this.id,
    this.dasaWisma = '',
    this.rt = '',
    this.rw = '',
    this.dusun = '',
    this.desa = '',
    this.kecamatan = '',
    required this.jenisIndustri,
    this.pemilik = '',
    this.jumlahTenagaKerja = 0,
    this.omzet = 0,
    this.status = 'pending',
    this.rejectedReason,
    this.approvedByName,
    this.kecamatanStatus,
    this.kecamatanRejectedReason,
  });

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

  IndustriRumahTangga copyWith({
    String? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? jenisIndustri,
    String? pemilik,
    int? jumlahTenagaKerja,
    double? omzet,
    String? status,
    String? rejectedReason,
    String? approvedByName,
    String? kecamatanStatus,
    String? kecamatanRejectedReason,
  }) {
    return IndustriRumahTangga(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      jenisIndustri: jenisIndustri ?? this.jenisIndustri,
      pemilik: pemilik ?? this.pemilik,
      jumlahTenagaKerja: jumlahTenagaKerja ?? this.jumlahTenagaKerja,
      omzet: omzet ?? this.omzet,
      status: status ?? this.status,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      approvedByName: approvedByName ?? this.approvedByName,
      kecamatanStatus: kecamatanStatus ?? this.kecamatanStatus,
      kecamatanRejectedReason:
          kecamatanRejectedReason ?? this.kecamatanRejectedReason,
    );
  }

  factory IndustriRumahTangga.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v == null ? '' : v.toString();
    int intOf(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    double doubleOf(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    String? approvedName;
    final approvedBy = json['approved_by'] ?? json['approvedBy'];
    if (approvedBy is Map<String, dynamic>) {
      approvedName = approvedBy['name']?.toString();
    }

    return IndustriRumahTangga(
      id: str(json['id']),
      dasaWisma:
          str(json['dasawisma'] ?? json['dasa_wisma'] ?? json['dasaWisma']),
      rt: str(json['rt']),
      rw: str(json['rw']),
      dusun: str(json['dusun']),
      desa: str(json['desa']),
      kecamatan: str(json['kecamatan']),
      jenisIndustri:
          str(json['jenis_industri'] ?? json['jenisIndustri']),
      pemilik: str(json['pemilik']),
      jumlahTenagaKerja:
          intOf(json['jumlah_tenaga_kerja'] ?? json['jumlahTenagaKerja']),
      omzet: doubleOf(json['omzet']),
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
  Map<String, dynamic> toJson() => {
        'dasawisma': dasaWisma,
        'dusun': dusun,
        'rt': rt,
        'rw': rw,
        'jenis_industri': jenisIndustri,
        'pemilik': pemilik,
        'jumlah_tenaga_kerja': jumlahTenagaKerja,
        'omzet': omzet,
      };
}
