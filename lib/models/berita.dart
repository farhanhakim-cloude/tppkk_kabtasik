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
  })  : deskripsi = deskripsi ?? ringkasan,
        createdAt = createdAt ?? tanggal,
        fotoUrl = fotoUrl ?? gambar;

  // ============================================================
  // FROM JSON
  // ============================================================
  factory Berita.fromJson(Map<String, dynamic> json) {
    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return Berita(
      id: map['id'] is int
          ? map['id']
          : (int.tryParse(map['id']?.toString() ?? '0') ?? 0),
      judul: (map['judul'] ?? map['title'] ?? 'Tidak ada judul').toString(),
      slug: map['slug']?.toString(),
      deskripsi: (map['deskripsi'] ??
              map['deskripsi_singkat'] ??
              map['ringkasan'] ??
              map['excerpt'])
          ?.toString(),
      konten: (map['konten'] ?? map['content'] ?? map['body'])?.toString(),
      fotoUrl: (map['foto_url'] ??
              map['foto'] ??
              map['image'] ??
              map['gambar'] ??
              map['image_url'] ??
              map['thumbnail'])
          ?.toString(),
      createdAt: (map['created_at'] ?? map['tanggal'])?.toString(),
      updatedAt: map['updated_at']?.toString(),
      tanggalFormatted: map['tanggal_formatted']?.toString(),
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
    };
  }

  // ============================================================
  // GETTER UNTUK COMPATIBILITY (FIX ERROR)
  // ============================================================
  String get tanggal => tanggalFormatted ?? createdAt ?? 'Tanggal tidak tersedia';
  String get ringkasan => deskripsi ?? konten ?? 'Klik untuk membaca selengkapnya';
  String? get gambar => fotoUrl;
}