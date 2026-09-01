// lib/models/pokja_2_model.dart

class Pokja2Model {
  final int id;
  final String? kecamatan;
  final int wargaButaL;
  final int wargaButaP;
  final int kelompokBelajarPaketA;
  final int kelompokBelajarPaketB;
  final int kelompokBelajarPaketC;
  final int kf;
  final int paud;
  final int koperasiBadanHukum;

  Pokja2Model({
    required this.id,
    this.kecamatan,
    this.wargaButaL = 0,
    this.wargaButaP = 0,
    this.kelompokBelajarPaketA = 0,
    this.kelompokBelajarPaketB = 0,
    this.kelompokBelajarPaketC = 0,
    this.kf = 0,
    this.paud = 0,
    this.koperasiBadanHukum = 0,
  });

  factory Pokja2Model.fromJson(Map<String, dynamic> json) {
    return Pokja2Model(
      id: json['id'] ?? 0,
      kecamatan: json['kecamatan'],
      wargaButaL: json['warga_buta_l'] ?? 0,
      wargaButaP: json['warga_buta_p'] ?? 0,
      kelompokBelajarPaketA: json['kelompok_belajar_paket_a'] ?? 0,
      kelompokBelajarPaketB: json['kelompok_belajar_paket_b'] ?? 0,
      kelompokBelajarPaketC: json['kelompok_belajar_paket_c'] ?? 0,
      kf: json['kf'] ?? 0,
      paud: json['paud'] ?? 0,
      koperasiBadanHukum: json['koperasi_berbadan_hukum'] ?? 0,
    );
  }
}

class Pokja2Response {
  final List<Pokja2Model> data;
  final int total;

  Pokja2Response({
    required this.data,
    required this.total,
  });

  factory Pokja2Response.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return Pokja2Response(
      data: dataList.map((item) => Pokja2Model.fromJson(item)).toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }
}