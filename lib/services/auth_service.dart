import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // SEKARANG: user dummy tetap, tidak peduli email/password yang dimasukkan
  static final User _dummyUser = User(
    nama: 'Kader PKK',
    email: 'kader@tasikmalayakota.go.id',
    jabatan: 'Kader Dasawisma',
    wilayah: 'RT 01/RW 05',
  );

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // NANTI: ganti jadi http.post ke /api/login, simpan token asli, decode user dari response
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyUser;

    // NANTI: ganti jadi http.get ke /api/me pakai token tersimpan
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // NANTI: juga panggil http.post ke /api/logout dan hapus token
  }
}