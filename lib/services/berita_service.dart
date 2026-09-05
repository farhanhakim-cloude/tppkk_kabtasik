import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/berita.dart';

class BeritaService {
  static final BeritaService _instance = BeritaService._internal();
  factory BeritaService() => _instance;
  BeritaService._internal();

  final List<Berita> _localBerita = [
    Berita(
      id: 1,
      judul: 'Kegiatan Posyandu Rutin Bulan Ini',
      ringkasan: 'Pelaksanaan posyandu rutin pemantauan gizi dan tumbuh kembang balita di seluruh desa dimulai minggu ini.',
      konten: 'Pelaksanaan posyandu rutin pemantauan gizi dan tumbuh kembang balita di seluruh desa dimulai minggu ini. Kader Dasawisma bersama tenaga medis Puskesmas setempat melakukan penimbangan berat badan, pengukuran tinggi badan, imunisasi, serta pemberian makanan tambahan (PMT) bergizi tinggi.',
      tanggal: '05 Agu 2026',
      gambar: 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=600&auto=format&fit=crop&q=80',
    ),
    Berita(
      id: 2,
      judul: 'Pelatihan Kader PKK Tingkat Kecamatan',
      ringkasan: 'Pelatihan kader baru tentang pemanfaatan pekarangan HATINYA PKK dan administrasi dasawisma akan dilaksanakan di aula kecamatan.',
      konten: 'Pelatihan kader baru tentang pemanfaatan pekarangan HATINYA PKK dan administrasi dasawisma akan dilaksanakan di aula kecamatan. Kegiatan ini bertujuan memperkuat kapasitas kader dalam pendataan digital serta ketahanan pangan keluarga.',
      tanggal: '03 Agu 2026',
      gambar: 'https://images.unsplash.com/photo-1577495508048-b635879837f1?w=600&auto=format&fit=crop&q=80',
    ),
    Berita(
      id: 3,
      judul: 'Lomba Kebersihan Lingkungan dan PHBS Antar RW',
      ringkasan: 'Penilaian lomba pemanfaatan pekarangan, pengolahan sampah mandiri, dan kebersihan lingkungan dimulai pekan depan.',
      konten: 'Penilaian lomba pemanfaatan pekarangan, pengolahan sampah mandiri, dan kebersihan lingkungan dimulai pekan depan. Warga bersama kader dasawisma antusias mempersiapkan lingkungan yang asri, bersih, dan sehat.',
      tanggal: '01 Agu 2026',
      gambar: 'https://images.unsplash.com/photo-1588880331179-bc9b93a8cb5e?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // ============================================================
  // AMBIL DAFTAR BERITA (API DENGAN FALLBACK LOKAL)
  // ============================================================
  Future<List<Berita>> getBerita() async {
    try {
      final token = await _getToken();
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.berita}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? (data is List ? data : []);
        final apiList = list.map((item) => Berita.fromJson(item)).toList();

        if (apiList.isNotEmpty) {
          // Gabungkan berita lokal yang baru dipublish jika belum ada di server
          final existingIds = apiList.map((e) => e.id).toSet();
          final localUnsynced = _localBerita.where((b) => !existingIds.contains(b.id)).toList();
          return [...localUnsynced, ...apiList];
        }
      }
    } catch (e) {
      print('⚠️ API berita offline/tidak merespon, memuat data lokal: $e');
    }

    return List.from(_localBerita);
  }

  // ============================================================
  // PUBLISH BERITA BARU
  // ============================================================
  Future<Berita> publishBerita({
    required String judul,
    required String ringkasan,
    String? konten,
    String? kategori,
    File? fotoFile,
  }) async {
    final now = DateTime.now();
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')} ${_namaBulan(now.month)} ${now.year}';

    // Buat Berita lokal terlebih dahulu agar langsung muncul di aplikasi
    final newId = _localBerita.isEmpty
        ? 1
        : _localBerita.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;

    Berita newBerita = Berita(
      id: newId,
      judul: judul,
      ringkasan: ringkasan,
      konten: (konten != null && konten.isNotEmpty) ? konten : ringkasan,
      tanggal: formattedDate,
      gambar: fotoFile?.path,
    );

    _localBerita.insert(0, newBerita);

    // Kirim ke backend Laravel API jika server tersedia
    try {
      final token = await _getToken();
      final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.berita}');
      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['judul'] = judul;
      request.fields['deskripsi'] = ringkasan;
      request.fields['ringkasan'] = ringkasan;
      request.fields['konten'] = (konten != null && konten.isNotEmpty) ? konten : ringkasan;
      if (kategori != null && kategori.isNotEmpty) {
        request.fields['kategori'] = kategori;
      }

      if (fotoFile != null && await fotoFile.exists()) {
        try {
          final multipartFile = await http.MultipartFile.fromPath('foto', fotoFile.path);
          request.files.add(multipartFile);
        } catch (e) {
          print('⚠️ Gagal melampirkan foto: $e');
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 8));
      final response = await http.Response.fromStream(streamedResponse);
      print('📡 Publish response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final apiBerita = Berita.fromJson(data['data']);
          _localBerita[0] = apiBerita;
          return apiBerita;
        }
      }
    } catch (e) {
      print('⚠️ Tidak dapat terhubung ke server Laravel saat publish, berita tersimpan lokal: $e');
    }

    return newBerita;
  }

  String _namaBulan(int month) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) {
      return bulan[month - 1];
    }
    return '';
  }
}