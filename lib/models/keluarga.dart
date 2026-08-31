class Keluarga {
  final int id;
  final String namaKepalaKeluarga;
  final String alamat;
  final String rt;
  final String rw;
  final int jumlahAnggota;
  final String pekerjaan;
  final String? fotoRumahPath;
  final double? latitude;
  final double? longitude;

  Keluarga({
    required this.id,
    required this.namaKepalaKeluarga,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.jumlahAnggota,
    required this.pekerjaan,
    this.fotoRumahPath,
    this.latitude,
    this.longitude,
  });

  Keluarga copyWith({
    int? id,
    String? namaKepalaKeluarga,
    String? alamat,
    String? rt,
    String? rw,
    int? jumlahAnggota,
    String? pekerjaan,
    String? fotoRumahPath,
    double? latitude,
    double? longitude,
  }) {
    return Keluarga(
      id: id ?? this.id,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      jumlahAnggota: jumlahAnggota ?? this.jumlahAnggota,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      fotoRumahPath: fotoRumahPath ?? this.fotoRumahPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}