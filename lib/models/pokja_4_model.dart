// lib/models/pokja_4_model.dart

class Pokja4Model {
  final int id;
  final String? kecamatan;
  final int kesehatanL;
  final int kesehatanP;
  final int lingkunganL;
  final int lingkunganP;
  final int perencanaanL;
  final int perencanaanP;

  Pokja4Model({
    required this.id,
    this.kecamatan,
    this.kesehatanL = 0,
    this.kesehatanP = 0,
    this.lingkunganL = 0,
    this.lingkunganP = 0,
    this.perencanaanL = 0,
    this.perencanaanP = 0,
  });

  factory Pokja4Model.fromJson(Map<String, dynamic> json) {
    return Pokja4Model(
      id: json['id'] ?? 0,
      kecamatan: json['kecamatan'],
      kesehatanL: json['kesehatan_l'] ?? 0,
      kesehatanP: json['kesehatan_p'] ?? 0,
      lingkunganL: json['lingkungan_l'] ?? 0,
      lingkunganP: json['lingkungan_p'] ?? 0,
      perencanaanL: json['perencanaan_l'] ?? 0,
      perencanaanP: json['perencanaan_p'] ?? 0,
    );
  }
}

class Pokja4Response {
  final List<Pokja4Model> data;
  final int total;

  Pokja4Response({
    required this.data,
    required this.total,
  });

  factory Pokja4Response.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return Pokja4Response(
      data: dataList.map((item) => Pokja4Model.fromJson(item)).toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }
}