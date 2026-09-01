// lib/models/pokja_1_model.dart

class Pokja1Model {
  final int id;
  final String? kecamatan;
  final int pkbnL;
  final int pkbnP;
  final int pkdrtL;
  final int pkdrtP;
  final int polaAsuhL;
  final int polaAsuhP;
  final int lansiaL;
  final int lansiaP;
  final int kaderPokja1L;
  final int kaderPokja1P;

  Pokja1Model({
    required this.id,
    this.kecamatan,
    this.pkbnL = 0,
    this.pkbnP = 0,
    this.pkdrtL = 0,
    this.pkdrtP = 0,
    this.polaAsuhL = 0,
    this.polaAsuhP = 0,
    this.lansiaL = 0,
    this.lansiaP = 0,
    this.kaderPokja1L = 0,
    this.kaderPokja1P = 0,
  });

  factory Pokja1Model.fromJson(Map<String, dynamic> json) {
    return Pokja1Model(
      id: json['id'] ?? 0,
      kecamatan: json['kecamatan'],
      pkbnL: json['pkbn_l'] ?? 0,
      pkbnP: json['pkbn_p'] ?? 0,
      pkdrtL: json['pkdrt_l'] ?? 0,
      pkdrtP: json['pkdrt_p'] ?? 0,
      polaAsuhL: json['pola_asuh_l'] ?? 0,
      polaAsuhP: json['pola_asuh_p'] ?? 0,
      lansiaL: json['lansia_l'] ?? 0,
      lansiaP: json['lansia_p'] ?? 0,
      kaderPokja1L: json['kader_pokja1_l'] ?? 0,
      kaderPokja1P: json['kader_pokja1_p'] ?? 0,
    );
  }
}

class Pokja1Response {
  final List<Pokja1Model> data;
  final int total;

  Pokja1Response({
    required this.data,
    required this.total,
  });

  factory Pokja1Response.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return Pokja1Response(
      data: dataList.map((item) => Pokja1Model.fromJson(item)).toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }
}