// lib/models/berita.dart

class Berita {
  final int id;
  final String judul;
  final String? slug;
  final String? deskripsi;
  final String? konten;
  final String? fotoUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? tanggalFormatted;
  
  // 🔥 TAMBAHAN UNTUK MOBILE
  final String? status;           // pending, approved, rejected
  final String? statusLabel;      // label status (Indonesia)
  final String? kategori;
  final String? kecamatan;
  final int? userId;
  final String? createdByName;

  Berita({
    this.id = 0,
    this.judul = '',
    this.slug,
    String? deskripsi,
    this.konten,
    String? fotoUrl,
    String? createdAt,
    this.updatedAt,
    this.tanggalFormatted,
    String? ringkasan,
    String? tanggal,
    String? gambar,
    // 🔥 TAMBAHAN
    this.status,
    this.statusLabel,
    this.kategori,
    this.kecamatan,
    this.userId,
    this.createdByName,
  })  : deskripsi = deskripsi ?? ringkasan,
        createdAt = createdAt ?? tanggal,
        fotoUrl = fotoUrl ?? gambar;

  // ============================================================
  // FROM JSON
  // ============================================================
  factory Berita.fromJson(Map<String, dynamic> json) {
    // 🔥 FIX: Pastikan json tidak null
    if (json == null) {
      return Berita();
    }

    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    // 🔥 AMBIL DATA DARI FIELD YANG BERBEDA
    final dataMap = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;

    // 🔥 AMBIL USER INFO
    final user = dataMap['user'] as Map<String, dynamic>?;
    final userData = dataMap['user_data'] as Map<String, dynamic>?;

    return Berita(
      id: _parseInt(dataMap['id']),
      judul: _parseString(dataMap['judul'] ?? dataMap['title']),
      slug: _parseString(dataMap['slug']),
      deskripsi: _parseString(
        dataMap['deskripsi'] ??
        dataMap['deskripsi_singkat'] ??
        dataMap['ringkasan'] ??
        dataMap['excerpt']
      ),
      konten: _parseString(
        dataMap['konten'] ??
        dataMap['content'] ??
        dataMap['body']
      ),
      fotoUrl: _parseString(
        dataMap['foto_url'] ??
        dataMap['foto'] ??
        dataMap['image'] ??
        dataMap['gambar'] ??
        dataMap['image_url'] ??
        dataMap['thumbnail']
      ),
      createdAt: _parseString(dataMap['created_at'] ?? dataMap['tanggal']),
      updatedAt: _parseString(dataMap['updated_at']),
      tanggalFormatted: _parseString(dataMap['tanggal_formatted']),
      
      // 🔥 TAMBAHAN
      status: _parseString(dataMap['status']),
      statusLabel: _parseString(dataMap['status_label']) ?? _getStatusLabel(_parseString(dataMap['status'])),
      kategori: _parseString(dataMap['kategori']),
      kecamatan: _parseString(dataMap['kecamatan']),
      userId: _parseInt(dataMap['user_id']),
      createdByName: _parseString(
        user?['name'] ??
        userData?['name'] ??
        dataMap['created_by_name'] ??
        dataMap['user_name']
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'slug': slug,
      'deskripsi': deskripsi,
      'konten': konten,
      'foto_url': fotoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'tanggal_formatted': tanggalFormatted,
      'status': status,
      'status_label': statusLabel,
      'kategori': kategori,
      'kecamatan': kecamatan,
      'user_id': userId,
      'created_by_name': createdByName,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================
  Berita copyWith({
    int? id,
    String? judul,
    String? slug,
    String? deskripsi,
    String? konten,
    String? fotoUrl,
    String? createdAt,
    String? updatedAt,
    String? tanggalFormatted,
    String? status,
    String? statusLabel,
    String? kategori,
    String? kecamatan,
    int? userId,
    String? createdByName,
  }) {
    return Berita(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      slug: slug ?? this.slug,
      deskripsi: deskripsi ?? this.deskripsi,
      konten: konten ?? this.konten,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tanggalFormatted: tanggalFormatted ?? this.tanggalFormatted,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      kategori: kategori ?? this.kategori,
      kecamatan: kecamatan ?? this.kecamatan,
      userId: userId ?? this.userId,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  // ============================================================
  // GETTER UNTUK COMPATIBILITY
  // ============================================================
  String get tanggal => tanggalFormatted ?? createdAt ?? 'Tanggal tidak tersedia';
  String get ringkasan => deskripsi ?? konten ?? 'Klik untuk membaca selengkapnya';
  String? get gambar => fotoUrl;
<<<<<<< HEAD
}

=======

  // 🔥 GETTER UNTUK STATUS
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isEditable => isPending; // Hanya bisa diedit/dihapus jika pending

  // 🔥 GETTER UNTUK BADGE STATUS
  String get statusBadgeColor {
    switch (status) {
      case 'pending': return 'amber';
      case 'approved': return 'green';
      case 'rejected': return 'red';
      default: return 'gray';
    }
  }

  String get statusBadgeText {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      default: return status ?? 'Unknown';
    }
  }

  // ============================================================
  // HELPER PRIVATE
  // ============================================================
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending': return 'Menunggu Persetujuan';
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      default: return status ?? 'Unknown';
    }
  }

  // ============================================================
  // LIST FROM JSON
  // ============================================================
  static List<Berita> listFromJson(List<dynamic> jsonList) {
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList.map((json) => Berita.fromJson(json)).toList();
  }
}

// ============================================================
// 🔥 EXTENSION UNTUK DAFTAR BERITA
// ============================================================
extension BeritaListExtension on List<Berita> {
  List<Berita> get pending => where((b) => b.isPending).toList();
  List<Berita> get approved => where((b) => b.isApproved).toList();
  List<Berita> get rejected => where((b) => b.isRejected).toList();
  List<Berita> get editable => where((b) => b.isEditable).toList();
}

// ============================================================
// 🔥 MODEL UNTUK INPUT BERITA (SUBMIT)
// ============================================================
class BeritaInput {
  final String judul;
  final String konten;
  final String? kategori;
  final String? kecamatan;
  final String? foto; // base64

  BeritaInput({
    required this.judul,
    required this.konten,
    this.kategori,
    this.kecamatan,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'konten': konten,
      'kategori': kategori,
      'kecamatan': kecamatan,
      'foto': foto,
    };
  }
}
>>>>>>> 10b8cf888e7207a81704b95a4286d76e8ec2cdea
