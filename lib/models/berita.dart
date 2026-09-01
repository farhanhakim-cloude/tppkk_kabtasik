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
    required this.id,
    required this.judul,
    this.slug,
    this.deskripsi,
    this.konten,
    this.fotoUrl,
    this.createdAt,
    this.updatedAt,
    this.tanggalFormatted,
  });

  // ============================================================
  // FROM JSON
  // ============================================================
  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? 'Tidak ada judul',
      slug: json['slug'],
      deskripsi: json['deskripsi'] ?? json['deskripsi_singkat'],
      konten: json['konten'],
      fotoUrl: json['foto_url'] ?? json['foto'] ?? json['image'],
      createdAt: json['created_at'] ?? json['tanggal'],
      updatedAt: json['updated_at'],
      tanggalFormatted: json['tanggal_formatted'],
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
  String get tanggal => createdAt ?? 'Tanggal tidak tersedia';
  String get ringkasan => deskripsi ?? konten ?? 'Klik untuk membaca selengkapnya';
}