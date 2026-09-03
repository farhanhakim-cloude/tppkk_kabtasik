// lib/constants/app_constants.dart

class AppConstants {
  // ============================================================
  // BASE URL - SESUAIKAN DENGAN DEVICE YANG DIPAKAI
  // ============================================================

  // 🔥 SEMUA DI 1 LAPTOP (Laravel & Flutter Web sama-sama di sini)
  // PAKE 127.0.0.1 - selalu merujuk ke komputer ini sendiri,
  // TIDAK berubah-ubah seperti IP WiFi (10.23.20.151 terbukti
  // ERR_CONNECTION_TIMED_OUT, kemungkinan besar IP itu sudah
  // tidak valid lagi / berubah setelah reconnect WiFi).
  static const String baseUrl = "http://127.0.0.1:8000/api/";

  // 📱 UNTUK EMULATOR ANDROID (AVD) - PAKE 10.0.2.2
  // static const String baseUrl = "http://10.0.2.2:8000/api/";

  // 📱 UNTUK HP FISIK (device terpisah, 1 WiFi yang sama) - PAKE IP
  // dari `ipconfig` yang PALING BARU (cek ulang tiap kali WiFi
  // reconnect, karena IP ini bisa berubah).
  // static const String baseUrl = "http://[IP_TERBARU]:8000/api/";

  // 💡 NANTI KALAU UDAH HOSTING:
  // static const String baseUrl = "https://domain-anda.com/api/";

  // ============================================================
  // ENDPOINT API
  // ============================================================

  // Auth
  static const String login = "login";
  static const String logout = "logout";
  static const String me = "me";

  // Data PKK
  static const String pokja1 = "pokja-1";
  static const String pokja2 = "pokja-2";
  static const String pokja3 = "pokja-3";
  static const String pokja4 = "pokja-4";
  static const String sekretariat = "sekretariat";

  // Konten
  static const String berita = "berita";
  static const String beritaLatest = "berita/latest";
  static const String galeri = "galeri";
  static const String agenda = "agenda";

  // Laporan
  static const String laporanKegiatan = "laporan-kegiatan";

  // ============================================================
  // SHARED PREFERENCES KEYS
  // ============================================================
  static const String tokenKey = "auth_token";
  static const String userKey = "user_data";
  static const String isLoggedInKey = "isLoggedIn";
}