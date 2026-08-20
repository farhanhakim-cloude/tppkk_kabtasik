import '../models/berita.dart';

class BeritaService {
  Future<List<Berita>> getBerita() async {
    // SEKARANG: data dummy
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Berita(
        id: 1,
        judul: 'Kegiatan Posyandu Bulan Ini',
        ringkasan: 'Pelaksanaan posyandu rutin di seluruh desa dimulai minggu ini.',
        tanggal: '05 Agu 2026',
      ),
      Berita(
        id: 2,
        judul: 'Pelatihan Kader PKK',
        ringkasan: 'Pelatihan kader baru akan dilaksanakan di aula kecamatan.',
        tanggal: '03 Agu 2026',
      ),
      Berita(
        id: 3,
        judul: 'Lomba Kebersihan Antar RT',
        ringkasan: 'Penilaian lomba kebersihan dimulai pekan depan.',
        tanggal: '01 Agu 2026',
      ),
    ];

    // NANTI, tinggal ganti isi function ini jadi:
    // final response = await http.get(Uri.parse('$baseUrl/berita'));
    // final List data = jsonDecode(response.body);
    // return data.map((json) => Berita(
    //   id: json['id'],
    //   judul: json['judul'],
    //   ringkasan: json['ringkasan'],
    //   tanggal: json['tanggal'],
    // )).toList();
  }
}