// lib/models/kegiatan_warga.dart
// Kontrak: tabel Laravel `kegiatan_wargas` + DasawismaResourceCatalog 'kegiatan-warga'.
// 1 baris = 1 kegiatan (enum) + jumlah peserta + tanggal. Status ditentukan server.

class KegiatanWarga {
  final String id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kegiatan; // up2k|pekarangan|industri|kesehatan|lainnya
  final int jumlahPeserta;
  final DateTime? tanggal;
  final String keterangan;

  // --- Ditentukan server, jangan dikirim saat create/update ---
  final String status; // pending|approved|rejected
  final String? rejectedReason;
  final String? approvedByName;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // --- Berjenjang (tidak ada di tabel kegiatan_wargas, nullable & aman) ---
  final String? kecamatanStatus;
  final String? kecamatanRejectedReason;

  KegiatanWarga({
    required this.id,
    this.dasaWisma = '',
    this.rt = '',
    this.rw = '',
    this.dusun = '',
    this.desa = '',
    this.kecamatan = '',
    required this.kegiatan,
    this.jumlahPeserta = 0,
    this.tanggal,
    this.keterangan = '',
    this.status = 'pending',
    this.rejectedReason,
    this.approvedByName,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.kecamatanStatus,
    this.kecamatanRejectedReason,
  });

  static const Map<String, String> kegiatanLabels = {
    'up2k': 'UP2K',
    'pekarangan': 'Pekarangan',
    'industri': 'Industri Rumah Tangga',
    'kesehatan': 'Kesehatan',
    'lainnya': 'Lainnya',
  };

  static List<String> get daftarKegiatan => kegiatanLabels.keys.toList();

  String get kegiatanLabel => kegiatanLabels[kegiatan] ?? kegiatan;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Butuh diperbaiki (aliased agar screen mudah): status rejected + ada alasan.
  bool get needsRevision => isRejected;

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

  /// Tahun diambil dari tanggal (server tidak punya kolom tahun).
  String get tahun => tanggal == null ? '' : '${tanggal!.year}';

  /// Kompatibilitas: rekapitulasi_service memakai e.totalAktif.
  int get totalAktif => jumlahPeserta;

  KegiatanWarga copyWith({
    String? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? kegiatan,
    int? jumlahPeserta,
    DateTime? tanggal,
    String? keterangan,
    String? status,
    String? rejectedReason,
    String? approvedByName,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? kecamatanStatus,
    String? kecamatanRejectedReason,
  }) {
    return KegiatanWarga(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kegiatan: kegiatan ?? this.kegiatan,
      jumlahPeserta: jumlahPeserta ?? this.jumlahPeserta,
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kecamatanStatus: kecamatanStatus ?? this.kecamatanStatus,
      kecamatanRejectedReason:
          kecamatanRejectedReason ?? this.kecamatanRejectedReason,
    );
  }

  // ============================================================
  // JSON — toleran: id int/string, approved_by int/objek,
  // snake_case + camelCase, field absen -> default aman.
  // ============================================================
  factory KegiatanWarga.fromJson(Map<String, dynamic> json) {
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

    String? approvedName;
    final approvedBy = json['approved_by'] ?? json['approvedBy'];
    if (approvedBy is Map<String, dynamic>) {
      approvedName = approvedBy['name']?.toString();
    }

    return KegiatanWarga(
      id: str(json['id']),
      dasaWisma: str(json['dasawisma'] ?? json['dasa_wisma'] ?? json['dasaWisma']),
      rt: str(json['rt']),
      rw: str(json['rw']),
      dusun: str(json['dusun']),
      desa: str(json['desa']),
      kecamatan: str(json['kecamatan']),
      kegiatan: str(json['kegiatan']),
      jumlahPeserta:
          intOf(json['jumlah_peserta'] ?? json['jumlahPeserta']),
      tanggal: dateOf(json['tanggal']),
      keterangan: str(json['keterangan']),
      status: str(json['status']).isEmpty ? 'pending' : str(json['status']),
      rejectedReason: (json['rejected_reason'] ?? json['rejectedReason'])
          ?.toString(),
      approvedByName: approvedName ??
          (json['approved_by_name'] ?? json['approvedByName'])?.toString(),
      approvedAt: dateOf(json['approved_at'] ?? json['approvedAt']),
      createdAt: dateOf(json['created_at'] ?? json['createdAt']),
      updatedAt: dateOf(json['updated_at'] ?? json['updatedAt']),
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
      'dasawisma': dasaWisma,
      'dusun': dusun,
      'rt': rt,
      'rw': rw,
      'kegiatan': kegiatan,
      'jumlah_peserta': jumlahPeserta,
      'tanggal': ymd(tanggal),
      'keterangan': keterangan,
    };
  }
}
