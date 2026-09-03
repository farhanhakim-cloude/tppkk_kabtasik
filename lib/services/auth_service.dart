// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

class AuthService {
  final http.Client _client = http.Client();

  // ============================================================
  // LOGIN - KONEK KE API LARAVEL
  // ============================================================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 AMBIL TOKEN & USER DARI RESPONSE (data wrapper)
        print('🔍 LOGIN RESPONSE: ${response.body}');
        final token = data['data']['token'] ?? '';
        print('🔍 TOKEN SAVED: "$token"');
        final userData = data['data']['user'] ?? {};

        // Simpan token dan user data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userKey, jsonEncode(userData));
        await prefs.setBool('isLoggedIn', true);

        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Email atau password salah');
      } else if (response.statusCode == 422) {
        throw Exception('Email atau password salah');
      } else {
        throw Exception('Login gagal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ============================================================
  // CEK STATUS LOGIN
  // ============================================================
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null || token.isEmpty) return false;

      // Cek token ke server (opsional)
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.me}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================
  Future<User> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null || token.isEmpty) {
        final cached = prefs.getString(AppConstants.userKey);
        if (cached != null && cached.isNotEmpty) {
          try {
            return User.fromJson(jsonDecode(cached));
          } catch (_) {}
        }
        return _getDummyUser();
      }

      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.me}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final cached = prefs.getString(AppConstants.userKey);
        if (cached != null && cached.isNotEmpty) {
          try {
            return User.fromJson(jsonDecode(cached));
          } catch (_) {}
        }
        return _getDummyUser();
      }
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(AppConstants.userKey);
        if (cached != null && cached.isNotEmpty) {
          return User.fromJson(jsonDecode(cached));
        }
      } catch (_) {}
      return _getDummyUser();
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token != null && token.isNotEmpty) {
        await _client.post(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.logout}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Ignore error saat logout
    } finally {
      // Hapus semua data lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      await prefs.remove('isLoggedIn');
    }
  }

  // ============================================================
  // GET TOKEN
  // ============================================================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // ============================================================
  // DUMMY USER (FALLBACK)
  // ============================================================
  User _getDummyUser() {
    return User(
      id: 0,
      name: 'Kader PKK',
      username: 'kader',
      email: 'kader@tasikmalayakab.go.id',
      roles: [],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================
  void dispose() {
    _client.close();
  }
}
