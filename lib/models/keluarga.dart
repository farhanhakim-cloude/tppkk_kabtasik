class Keluarga {
  final int id;
  final String namaKepalaKeluarga;
  final String alamat;
  final String rt;
  final String rw;
  final int jumlahAnggota;
  final String pekerjaan;

  Keluarga({
    required this.id,
    required this.namaKepalaKeluarga,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.jumlahAnggota,
    required this.pekerjaan,
  });

  Keluarga copyWith({
    int? id,
    String? namaKepalaKeluarga,
    String? alamat,
    String? rt,
    String? rw,
    int? jumlahAnggota,
    String? pekerjaan,
  }) {
    return Keluarga(
      id: id ?? this.id,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      jumlahAnggota: jumlahAnggota ?? this.jumlahAnggota,
      pekerjaan: pekerjaan ?? this.pekerjaan,
    );
  }
}