// lib/models/sekretariat_model.dart

class SekretariatModel {
  final int id;
  final String? kecamatan;
  final int jumlahPkkRw;
  final int jumlahPkkRt;
  final int jumlahDasaWisma;
  final int jumlahKrt;
  final int jumlahKk;
  final int jiwaL;
  final int jiwaP;
  final int tpPkkL;
  final int tpPkkP;
  final int kaderUmumL;
  final int kaderUmumP;
  final int kaderKhususL;
  final int kaderKhususP;

  SekretariatModel({
    required this.id,
    this.kecamatan,
    this.jumlahPkkRw = 0,
    this.jumlahPkkRt = 0,
    this.jumlahDasaWisma = 0,
    this.jumlahKrt = 0,
    this.jumlahKk = 0,
    this.jiwaL = 0,
    this.jiwaP = 0,
    this.tpPkkL = 0,
    this.tpPkkP = 0,
    this.kaderUmumL = 0,
    this.kaderUmumP = 0,
    this.kaderKhususL = 0,
    this.kaderKhususP = 0,
  });

  factory SekretariatModel.fromJson(Map<String, dynamic> json) {
    return SekretariatModel(
      id: json['id'] ?? 0,
      kecamatan: json['kecamatan'],
      jumlahPkkRw: json['jumlah_pkk_rw'] ?? 0,
      jumlahPkkRt: json['jumlah_pkk_rt'] ?? 0,
      jumlahDasaWisma: json['jumlah_dasa_wisma'] ?? 0,
      jumlahKrt: json['jumlah_krt'] ?? 0,
      jumlahKk: json['jumlah_kk'] ?? 0,
      jiwaL: json['jiwa_l'] ?? 0,
      jiwaP: json['jiwa_p'] ?? 0,
      tpPkkL: json['tp_pkk_l'] ?? 0,
      tpPkkP: json['tp_pkk_p'] ?? 0,
      kaderUmumL: json['kader_umum_l'] ?? 0,
      kaderUmumP: json['kader_umum_p'] ?? 0,
      kaderKhususL: json['kader_khusus_l'] ?? 0,
      kaderKhususP: json['kader_khusus_p'] ?? 0,
    );
  }
}

class SekretariatResponse {
  final List<SekretariatModel> data;
  final int total;

  SekretariatResponse({
    required this.data,
    required this.total,
  });

  factory SekretariatResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return SekretariatResponse(
      data: dataList.map((item) => SekretariatModel.fromJson(item)).toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }
}