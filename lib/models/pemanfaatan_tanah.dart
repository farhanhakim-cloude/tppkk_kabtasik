// lib/models/pemanfaatan_tanah.dart
// Kontrak: tabel Laravel `pemanfaatan_pekarangans` + DasawismaResourceCatalog
// 'pemanfaatan-pekarangan'. 1 baris = 1 catatan tanaman.
// Status ditentukan server.

class PemanfaatanTanah {
  final String id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String jenisTanaman;
  final double luasM2;
  final int jumlahKk;
  final String hasil;

  // --- Ditentukan server, jangan dikirim saat create/update ---
  final String status; // pending|approved|rejected
  final String? rejectedReason;
  final String? approvedByName;

  // --- Berjenjang (nullable, aman jika server tidak mengirim) ---
  final String? kecamatanStatus;
  final String? kecamatanRejectedReason;

  PemanfaatanTanah({
    required this.id,
    this.dasaWisma = '',
    this.rt = '',
    this.rw = '',
    this.dusun = '',
    this.desa = '',
    this.kecamatan = '',
    required this.jenisTanaman,
    this.luasM2 = 0,
    this.jumlahKk = 0,
    this.hasil = '',
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

  PemanfaatanTanah copyWith({
    String? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? jenisTanaman,
    double? luasM2,
    int? jumlahKk,
    String? hasil,
    String? status,
    String? rejectedReason,
    String? approvedByName,
    String? kecamatanStatus,
    String? kecamatanRejectedReason,
  }) {
    return PemanfaatanTanah(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      jenisTanaman: jenisTanaman ?? this.jenisTanaman,
      luasM2: luasM2 ?? this.luasM2,
      jumlahKk: jumlahKk ?? this.jumlahKk,
      hasil: hasil ?? this.hasil,
      status: status ?? this.status,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      approvedByName: approvedByName ?? this.approvedByName,
      kecamatanStatus: kecamatanStatus ?? this.kecamatanStatus,
      kecamatanRejectedReason:
          kecamatanRejectedReason ?? this.kecamatanRejectedReason,
    );
  }

  factory PemanfaatanTanah.fromJson(Map<String, dynamic> json) {
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

    return PemanfaatanTanah(
      id: str(json['id']),
      dasaWisma:
          str(json['dasawisma'] ?? json['dasa_wisma'] ?? json['dasaWisma']),
      rt: str(json['rt']),
      rw: str(json['rw']),
      dusun: str(json['dusun']),
      desa: str(json['desa']),
      kecamatan: str(json['kecamatan']),
      jenisTanaman:
          str(json['jenis_tanaman'] ?? json['jenisTanaman']),
      luasM2: doubleOf(json['luas_m2'] ?? json['luasM2']),
      jumlahKk: intOf(json['jumlah_kk'] ?? json['jumlahKk']),
      hasil: str(json['hasil']),
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
        'jenis_tanaman': jenisTanaman,
        'luas_m2': luasM2,
        'jumlah_kk': jumlahKk,
        'hasil': hasil,
      };
}
