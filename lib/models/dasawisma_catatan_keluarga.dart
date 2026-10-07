// lib/models/dasawisma_catatan_keluarga.dart
// Kontrak: tabel Laravel `catatan_keluargas` + DasawismaResourceCatalog
// 'catatan-keluarga'. 1 baris = 1 anggota keluarga, terhubung ke
// daftar_warga_id. Wilayah (desa/dusun/rt/...) dibaca dari relasi
// daftar_warga. Status ditentukan server.

class DasawismaCatatanKeluarga {
  final String id;
  final int daftarWargaId;
  final String kepalaKeluarga;

  // Denormalisasi dari relasi daftar_warga (read-only tampilan).
  final String desa;
  final String dusun;
  final String rt;
  final String rw;
  final String dasaWisma;
  final String kecamatan;

  final String namaAnggota;
  final String nik;
  final String jenisKelamin; // L / P
  final DateTime? tanggalLahir;
  final int umur;
  final String hubunganKeluarga; // kepala / istri / anak
  final String pendidikan;
  final String pekerjaan;
  final String statusPerkawinan;

  // --- Ditentukan server, jangan dikirim saat create/update ---
  final String status; // pending|approved|rejected
  final String? rejectedReason;
  final String? approvedByName;

  // --- Berjenjang (nullable, aman jika server tidak mengirim) ---
  final String? kecamatanStatus;
  final String? kecamatanRejectedReason;

  // Field lokal (tidak ada kolom server) — kompatibilitas rekapitulasi.
  final String berkebutuhanKhusus;

  DasawismaCatatanKeluarga({
    required this.id,
    this.daftarWargaId = 0,
    this.kepalaKeluarga = '',
    this.desa = '',
    this.dusun = '',
    this.rt = '',
    this.rw = '',
    this.dasaWisma = '',
    this.kecamatan = '',
    required this.namaAnggota,
    this.nik = '',
    this.jenisKelamin = 'P',
    this.tanggalLahir,
    this.umur = 0,
    this.hubunganKeluarga = 'anak',
    this.pendidikan = '',
    this.pekerjaan = '',
    this.statusPerkawinan = '',
    this.status = 'pending',
    this.rejectedReason,
    this.approvedByName,
    this.kecamatanStatus,
    this.kecamatanRejectedReason,
    this.berkebutuhanKhusus = 'Tidak',
  });

  static const Map<String, String> hubunganLabels = {
    'kepala': 'Kepala Keluarga',
    'istri': 'Istri',
    'anak': 'Anak',
  };

  String get hubunganLabel =>
      hubunganLabels[hubunganKeluarga] ?? hubunganKeluarga;

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

  DasawismaCatatanKeluarga copyWith({
    String? id,
    int? daftarWargaId,
    String? kepalaKeluarga,
    String? desa,
    String? dusun,
    String? rt,
    String? rw,
    String? dasaWisma,
    String? kecamatan,
    String? namaAnggota,
    String? nik,
    String? jenisKelamin,
    DateTime? tanggalLahir,
    int? umur,
    String? hubunganKeluarga,
    String? pendidikan,
    String? pekerjaan,
    String? statusPerkawinan,
    String? status,
    String? rejectedReason,
    String? approvedByName,
    String? kecamatanStatus,
    String? kecamatanRejectedReason,
    String? berkebutuhanKhusus,
  }) {
    return DasawismaCatatanKeluarga(
      id: id ?? this.id,
      daftarWargaId: daftarWargaId ?? this.daftarWargaId,
      kepalaKeluarga: kepalaKeluarga ?? this.kepalaKeluarga,
      desa: desa ?? this.desa,
      dusun: dusun ?? this.dusun,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      kecamatan: kecamatan ?? this.kecamatan,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      nik: nik ?? this.nik,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      umur: umur ?? this.umur,
      hubunganKeluarga: hubunganKeluarga ?? this.hubunganKeluarga,
      pendidikan: pendidikan ?? this.pendidikan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      status: status ?? this.status,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      approvedByName: approvedByName ?? this.approvedByName,
      kecamatanStatus: kecamatanStatus ?? this.kecamatanStatus,
      kecamatanRejectedReason:
          kecamatanRejectedReason ?? this.kecamatanRejectedReason,
      berkebutuhanKhusus: berkebutuhanKhusus ?? this.berkebutuhanKhusus,
    );
  }

  factory DasawismaCatatanKeluarga.fromJson(Map<String, dynamic> json) {
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

    // Relasi nested: daftar_warga / daftarWarga.
    var kk = '';
    var desa = '';
    var dusun = '';
    var rt = '';
    var rw = '';
    var dw = '';
    var kec = '';
    final rel = json['daftar_warga'] ?? json['daftarWarga'];
    if (rel is Map<String, dynamic>) {
      kk = str(rel['nama_kepala_keluarga'] ?? rel['namaKepalaRumahTangga']);
      desa = str(rel['desa']);
      dusun = str(rel['dusun']);
      rt = str(rel['rt']);
      rw = str(rel['rw']);
      dw = str(rel['dasawisma'] ?? rel['dasa_wisma']);
      kec = str(rel['kecamatan']);
    }

    String? approvedName;
    final approvedBy = json['approved_by'] ?? json['approvedBy'];
    if (approvedBy is Map<String, dynamic>) {
      approvedName = approvedBy['name']?.toString();
    }

    return DasawismaCatatanKeluarga(
      id: str(json['id']),
      daftarWargaId:
          intOf(json['daftar_warga_id'] ?? json['daftarWargaId']),
      kepalaKeluarga: kk,
      desa: desa,
      dusun: dusun,
      rt: rt,
      rw: rw,
      dasaWisma: dw,
      kecamatan: kec,
      namaAnggota: str(json['nama_anggota'] ?? json['namaAnggota']),
      nik: str(json['nik']),
      jenisKelamin: str(json['jenis_kelamin'] ?? json['jenisKelamin'])
          .isEmpty
          ? 'P'
          : str(json['jenis_kelamin'] ?? json['jenisKelamin']),
      tanggalLahir:
          dateOf(json['tanggal_lahir'] ?? json['tanggalLahir']),
      umur: intOf(json['umur']),
      hubunganKeluarga:
          str(json['hubungan_keluarga'] ?? json['hubunganKeluarga'])
                  .isEmpty
              ? 'anak'
              : str(json['hubungan_keluarga'] ?? json['hubunganKeluarga']),
      pendidikan: str(json['pendidikan']),
      pekerjaan: str(json['pekerjaan']),
      statusPerkawinan:
          str(json['status_perkawinan'] ?? json['statusPerkawinan']),
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
      berkebutuhanKhusus:
          str(json['berkebutuhan_khusus'] ?? json['berkebutuhanKhusus'])
                  .isEmpty
              ? 'Tidak'
              : str(json['berkebutuhan_khusus'] ??
                  json['berkebutuhanKhusus']),
    );
  }

  /// Payload create/update. TIDAK mengirim status/approval.
  Map<String, dynamic> toJson() {
    String? ymd(DateTime? d) {
      if (d == null) return null;
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '${d.year}-$m-$day';
    }

    return {
      'daftar_warga_id': daftarWargaId,
      'nama_anggota': namaAnggota,
      'nik': nik.isEmpty ? null : nik,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': ymd(tanggalLahir),
      'umur': umur,
      'hubungan_keluarga': hubunganKeluarga,
      'pendidikan': pendidikan,
      'pekerjaan': pekerjaan,
      'status_perkawinan': statusPerkawinan,
    };
  }
}
