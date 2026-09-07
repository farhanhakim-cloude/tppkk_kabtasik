import '../models/rekap_ibu_anak.dart';

class RekapIbuAnakSummary {
  final int jumlahHamil;
  final int jumlahMelahirkan;
  final int jumlahNifas;
  final int jumlahIbuMeninggal;
  final int jumlahBayiLahir;
  final int jumlahBayiMeninggal;
  final int jumlahBalitaMeninggal;

  RekapIbuAnakSummary({
    required this.jumlahHamil,
    required this.jumlahMelahirkan,
    required this.jumlahNifas,
    required this.jumlahIbuMeninggal,
    required this.jumlahBayiLahir,
    required this.jumlahBayiMeninggal,
    required this.jumlahBalitaMeninggal,
  });
}

class RekapIbuAnakService {
  static final RekapIbuAnakService _instance = RekapIbuAnakService._internal();
  factory RekapIbuAnakService() => _instance;
  RekapIbuAnakService._internal();

  final List<RekapIbuAnak> _items = [
    RekapIbuAnak(
      id: 1,
      kelompokDasaWisma: 'Mawar 01',
      rt: '02',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaIbu: 'Siti Rohmah',
      namaSuami: 'Ahmad Hidayat',
      statusIbu: 'Hamil',
      adaKelahiran: false,
      adaKematian: false,
      keterangan: 'Usia kandungan 7 bulan',
    ),
    RekapIbuAnak(
      id: 2,
      kelompokDasaWisma: 'Mawar 01',
      rt: '02',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaIbu: 'Dewi Kartika',
      namaSuami: 'Budi Santoso',
      statusIbu: 'Melahirkan',
      adaKelahiran: true,
      namaBayi: 'Anindya Putri',
      jenisKelaminBayi: 'P',
      tanggalLahir: '02-09-2026',
      hasAktaKelahiran: true,
      adaKematian: false,
      keterangan: 'Kelahiran normal di Puskesmas',
    ),
    RekapIbuAnak(
      id: 3,
      kelompokDasaWisma: 'Mawar 02',
      rt: '03',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaIbu: 'Rina Maryana',
      namaSuami: 'Hendra Gunawan',
      statusIbu: 'Nifas',
      adaKelahiran: true,
      namaBayi: 'Muhamad Fathan',
      jenisKelaminBayi: 'L',
      tanggalLahir: '20-08-2026',
      hasAktaKelahiran: false,
      adaKematian: false,
      keterangan: 'Proses pengurusan Akta',
    ),
    RekapIbuAnak(
      id: 4,
      kelompokDasaWisma: 'Mawar 02',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaIbu: 'Nurhayati',
      namaSuami: 'Dedi Kurnia',
      statusIbu: 'Hamil',
      adaKelahiran: false,
      adaKematian: false,
      keterangan: 'Usia kandungan 4 bulan',
    ),
  ];

  Future<List<RekapIbuAnak>> getAll({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (query == null || query.trim().isEmpty) {
      return List.from(_items);
    }
    final q = query.toLowerCase();
    return _items.where((item) {
      return item.namaIbu.toLowerCase().contains(q) ||
          item.namaSuami.toLowerCase().contains(q) ||
          item.namaBayi.toLowerCase().contains(q) ||
          item.kelompokDasaWisma.toLowerCase().contains(q) ||
          item.rt.contains(q) ||
          item.rw.contains(q);
    }).toList();
  }

  Future<void> save(RekapIbuAnak item) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      final newId = _items.isEmpty ? 1 : (_items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      _items.insert(0, item.copyWith(id: newId));
    }
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items.removeWhere((e) => e.id == id);
  }

  Future<RekapIbuAnakSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 50));
    int hamil = 0;
    int melahirkan = 0;
    int nifas = 0;
    int ibuMeninggal = 0;
    int bayiLahir = 0;
    int bayiMeninggal = 0;
    int balitaMeninggal = 0;

    for (var item in _items) {
      final st = item.statusIbu.toLowerCase();
      if (st.contains('hamil')) hamil++;
      if (st.contains('lahir')) melahirkan++;
      if (st.contains('nifas')) nifas++;

      if (item.adaKelahiran) {
        bayiLahir++;
      }

      if (item.adaKematian) {
        final stK = item.statusMeninggal.toLowerCase();
        if (stK.contains('ibu')) ibuMeninggal++;
        if (stK.contains('bayi')) bayiMeninggal++;
        if (stK.contains('balita')) balitaMeninggal++;
      }
    }

    return RekapIbuAnakSummary(
      jumlahHamil: hamil,
      jumlahMelahirkan: melahirkan,
      jumlahNifas: nifas,
      jumlahIbuMeninggal: ibuMeninggal,
      jumlahBayiLahir: bayiLahir,
      jumlahBayiMeninggal: bayiMeninggal,
      jumlahBalitaMeninggal: balitaMeninggal,
    );
  }
}
