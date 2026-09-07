class RekapIbuAnak {
  final int id;
  final String kelompokDasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String bulan;
  final String tahun;

  // Data Ibu & Suami
  final String namaIbu;
  final String namaSuami;
  final String statusIbu; // "Hamil", "Melahirkan", "Nifas", "Normal"

  // Catatan Kelahiran
  final bool adaKelahiran;
  final String namaBayi;
  final String jenisKelaminBayi; // "L", "P"
  final String tanggalLahir;
  final bool hasAktaKelahiran; // true = Ada, false = Tidak Ada

  // Catatan Kematian
  final bool adaKematian;
  final String namaMeninggal;
  final String statusMeninggal; // "Ibu", "Bayi", "Balita"
  final String jenisKelaminMeninggal; // "L", "P"
  final String tanggalMeninggal;
  final String sebabMeninggal;

  // Keterangan
  final String keterangan;

  RekapIbuAnak({
    required this.id,
    required this.kelompokDasaWisma,
    required this.rt,
    required this.rw,
    required this.dusun,
    required this.desa,
    required this.bulan,
    required this.tahun,
    required this.namaIbu,
    required this.namaSuami,
    required this.statusIbu,
    this.adaKelahiran = false,
    this.namaBayi = '',
    this.jenisKelaminBayi = 'L',
    this.tanggalLahir = '',
    this.hasAktaKelahiran = true,
    this.adaKematian = false,
    this.namaMeninggal = '',
    this.statusMeninggal = 'Ibu',
    this.jenisKelaminMeninggal = 'P',
    this.tanggalMeninggal = '',
    this.sebabMeninggal = '',
    this.keterangan = '',
  });

  RekapIbuAnak copyWith({
    int? id,
    String? kelompokDasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? bulan,
    String? tahun,
    String? namaIbu,
    String? namaSuami,
    String? statusIbu,
    bool? adaKelahiran,
    String? namaBayi,
    String? jenisKelaminBayi,
    String? tanggalLahir,
    bool? hasAktaKelahiran,
    bool? adaKematian,
    String? namaMeninggal,
    String? statusMeninggal,
    String? jenisKelaminMeninggal,
    String? tanggalMeninggal,
    String? sebabMeninggal,
    String? keterangan,
  }) {
    return RekapIbuAnak(
      id: id ?? this.id,
      kelompokDasaWisma: kelompokDasaWisma ?? this.kelompokDasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      namaIbu: namaIbu ?? this.namaIbu,
      namaSuami: namaSuami ?? this.namaSuami,
      statusIbu: statusIbu ?? this.statusIbu,
      adaKelahiran: adaKelahiran ?? this.adaKelahiran,
      namaBayi: namaBayi ?? this.namaBayi,
      jenisKelaminBayi: jenisKelaminBayi ?? this.jenisKelaminBayi,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      hasAktaKelahiran: hasAktaKelahiran ?? this.hasAktaKelahiran,
      adaKematian: adaKematian ?? this.adaKematian,
      namaMeninggal: namaMeninggal ?? this.namaMeninggal,
      statusMeninggal: statusMeninggal ?? this.statusMeninggal,
      jenisKelaminMeninggal: jenisKelaminMeninggal ?? this.jenisKelaminMeninggal,
      tanggalMeninggal: tanggalMeninggal ?? this.tanggalMeninggal,
      sebabMeninggal: sebabMeninggal ?? this.sebabMeninggal,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
