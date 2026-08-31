class User {
  final String nama;
  final String email;
  final String jabatan;
  final String wilayah;

  User({
    required this.nama,
    required this.email,
    required this.jabatan,
    required this.wilayah,
  });

  String get role => jabatan;
}