class CatatanKeluargaPokja {
  final int id;
  final int? keluargaId;
  final String namaKepalaKeluarga;
  final String rt;
  final String rw;
  final DateTime tanggalInput;

  // Step 1: Pokja I - Penghayatan & Pengamalan Pancasila
  final List<String> penghayatanPancasila;

  // Step 2: Pokja I - Gotong Royong
  final List<String> gotongRoyong;

  // Step 3: Pokja II - Pendidikan dan Keterampilan
  final List<String> pendidikanKeterampilan;

  // Step 4: Pokja II - Pengembangan Kehidupan Berkoperasi
  final List<String> pengembanganKoperasi;

  // Step 5: Pokja III - Pangan, Sandang, dan Tata Laksana RT
  final List<String> panganSandangTataLaksana;

  // Step 6: Pokja IV - Kesehatan dan Kelestarian Lingkungan
  final List<String> kesehatanLingkungan;

  // Step 7: Pokja IV - Perencanaan Sehat
  final List<String> perencanaanSehat;

  CatatanKeluargaPokja({
    required this.id,
    this.keluargaId,
    required this.namaKepalaKeluarga,
    required this.rt,
    required this.rw,
    required this.tanggalInput,
    this.penghayatanPancasila = const [],
    this.gotongRoyong = const [],
    this.pendidikanKeterampilan = const [],
    this.pengembanganKoperasi = const [],
    this.panganSandangTataLaksana = const [],
    this.kesehatanLingkungan = const [],
    this.perencanaanSehat = const [],
  });

  CatatanKeluargaPokja copyWith({
    int? id,
    int? keluargaId,
    String? namaKepalaKeluarga,
    String? rt,
    String? rw,
    DateTime? tanggalInput,
    List<String>? penghayatanPancasila,
    List<String>? gotongRoyong,
    List<String>? pendidikanKeterampilan,
    List<String>? pengembanganKoperasi,
    List<String>? panganSandangTataLaksana,
    List<String>? kesehatanLingkungan,
    List<String>? perencanaanSehat,
  }) {
    return CatatanKeluargaPokja(
      id: id ?? this.id,
      keluargaId: keluargaId ?? this.keluargaId,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      tanggalInput: tanggalInput ?? this.tanggalInput,
      penghayatanPancasila: penghayatanPancasila ?? this.penghayatanPancasila,
      gotongRoyong: gotongRoyong ?? this.gotongRoyong,
      pendidikanKeterampilan: pendidikanKeterampilan ?? this.pendidikanKeterampilan,
      pengembanganKoperasi: pengembanganKoperasi ?? this.pengembanganKoperasi,
      panganSandangTataLaksana: panganSandangTataLaksana ?? this.panganSandangTataLaksana,
      kesehatanLingkungan: kesehatanLingkungan ?? this.kesehatanLingkungan,
      perencanaanSehat: perencanaanSehat ?? this.perencanaanSehat,
    );
  }
}
