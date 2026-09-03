// lib/models/pokja_3_model.dart

class Pokja3Model {
  final int id;
  final String? kecamatan;
  final int panganL;
  final int panganP;
  final int sandangL;
  final int sandangP;
  final int perumahanL;
  final int perumahanP;

  Pokja3Model({
    required this.id,
    this.kecamatan,
    this.panganL = 0,
    this.panganP = 0,
    this.sandangL = 0,
    this.sandangP = 0,
    this.perumahanL = 0,
    this.perumahanP = 0,
  });

  factory Pokja3Model.fromJson(Map<String, dynamic> json) {
    return Pokja3Model(
      id: json['id'] ?? 0,
      kecamatan: json['kecamatan'],
      panganL: json['pangan_l'] ?? 0,
      panganP: json['pangan_p'] ?? 0,
      sandangL: json['sandang_l'] ?? 0,
      sandangP: json['sandang_p'] ?? 0,
      perumahanL: json['perumahan_l'] ?? 0,
      perumahanP: json['perumahan_p'] ?? 0,
    );
  }
}

class Pokja3Response {
  final List<Pokja3Model> data;
  final int total;

  Pokja3Response({
    required this.data,
    required this.total,
  });

  factory Pokja3Response.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return Pokja3Response(
      data: dataList.map((item) => Pokja3Model.fromJson(item)).toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }
}