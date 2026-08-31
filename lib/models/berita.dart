class Berita {
  final int id;
  final String judul;
  final String ringkasan;
  final String tanggal;
  final String? gambar; // URL gambar (nullable, opsional)

  Berita({
    required this.id,
    required this.judul,
    required this.ringkasan,
    required this.tanggal,
    this.gambar,
  });
}