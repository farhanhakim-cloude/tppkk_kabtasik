// lib/widgets/wilayah_otomatis.dart
// Helper: Desa & Kecamatan otomatis dari akun Dasawisma yang login.
// Backend sudah paksa pakai user->kecamatan/desa saat store,
// jadi Flutter cukup tampilkan terkunci agar tidak input ulang.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class WilayahAkun {
  final String desa;
  final String kecamatan;
  const WilayahAkun({required this.desa, required this.kecamatan});
  bool get lengkap => desa.isNotEmpty && kecamatan.isNotEmpty;
}

Future<WilayahAkun?> loadWilayahAkun() async {
  try {
    final user = await AuthService().getCurrentUser();
    if (user.kecamatan.isEmpty && user.desa.isEmpty) return null;
    return WilayahAkun(desa: user.desa, kecamatan: user.kecamatan);
  } catch (_) {
    return null;
  }
}

class WilayahOtomatisBanner extends StatelessWidget {
  final String desa;
  final String kecamatan;
  const WilayahOtomatisBanner({super.key, required this.desa, required this.kecamatan});

  @override
  Widget build(BuildContext context) {
    if (desa.isEmpty && kecamatan.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFF0072BC), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Otomatis dari akun: $desa, Kec. $kecamatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DesaTerkunciField extends StatelessWidget {
  final TextEditingController controller;
  const DesaTerkunciField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: 'Desa *',
        prefixIcon: const Icon(Icons.home_outlined, size: 18, color: Color(0xFF0072BC)),
        suffixIcon: const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF94A3B8)),
        helperText: 'Otomatis dari akun',
        helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Desa belum terisi dari akun' : null,
    );
  }
}
