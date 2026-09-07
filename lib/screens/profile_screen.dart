// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _picker = ImagePicker();

  late Future<User> _future;
  File? _profileImage;
  bool _loggingOut = false;

  static const primaryTeal = Color(0xFF0D9488);
  static const darkTeal = Color(0xFF0F766E);
  static const softTealBg = Color(0xFFF0FDFA);
  static const surfaceBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _future = _authService.getCurrentUser();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  Future<void> _pilihFotoProfil() async {
    HapticFeedback.lightImpact();
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Ubah Foto Profil',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: softTealBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: primaryTeal),
                ),
                title: Text(
                  'Ambil dari Kamera',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  'Gunakan kamera langsung ponsel',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: softTealBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: primaryTeal),
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  'Pilih gambar dari album foto',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (sumber == null) return;

    try {
      final img = await _picker.pickImage(source: sumber, imageQuality: 80, maxWidth: 600);
      if (img != null) {
        setState(() {
          _profileImage = File(img.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Foto profil berhasil diperbarui',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: primaryTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Keluar Akun?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Anda akan keluar dari sesi aplikasi e-PKK Kabupaten Tasikmalaya.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loggingOut = true);
      await _authService.logout();
      if (mounted) {
        setState(() => _loggingOut = false);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showInfoDialog(String title, String message) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(
                'Profil Kader',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              backgroundColor: primaryTeal,
              elevation: 0,
              centerTitle: true,
            ),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat profil',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 36),
            child: Column(
              children: [
                // ── 1. HEADER PROFIL TIMELESS & CLEAN ──
                _buildProfileHeader(user),

                // ── 2. STATISTIK KONTRIBUSI MINIMALIS ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _buildStatsCapsule(),
                ),

                // ── 3. INFORMASI WILAYAH & TUGAS ──
                _buildSectionCard(
                  title: 'Wilayah Tugas & Dasawisma',
                  icon: Icons.location_on_outlined,
                  items: [
                    _InfoRow(label: 'Kabupaten', value: 'Kabupaten Tasikmalaya'),
                    _InfoRow(label: 'Kecamatan', value: 'Kecamatan Singaparna'),
                    _InfoRow(label: 'Desa / Kelurahan', value: 'Desa Cipakat'),
                    _InfoRow(label: 'Kelompok Dasawisma', value: 'Dasawisma Mawar 02'),
                    _InfoRow(label: 'Wilayah RT / RW', value: 'RT 02 / RW 05'),
                  ],
                ),

                // ── 4. PENGATURAN & BANTUAN ──
                _buildSectionCard(
                  title: 'Informasi & Pengaturan',
                  icon: Icons.tune_rounded,
                  items: [
                    _ActionRow(
                      icon: Icons.auto_stories_outlined,
                      title: 'Buku Panduan 10 Program Pokok PKK',
                      onTap: () => _showInfoDialog(
                        '10 Program Pokok PKK',
                        '1. Penghayatan dan Pengamalan Pancasila\n'
                        '2. Gotong Royong\n'
                        '3. Pangan\n'
                        '4. Sandang\n'
                        '5. Perumahan dan Tata Laksana Rumah Tangga\n'
                        '6. Pendidikan dan Keterampilan\n'
                        '7. Kesehatan\n'
                        '8. Pengembangan Kehidupan Berkoperasi\n'
                        '9. Kelestarian Lingkungan Hidup\n'
                        '10. Perencanaan Sehat',
                      ),
                    ),
                    _ActionRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ubah Kata Sandi Akun',
                      onTap: () => _showInfoDialog(
                        'Ubah Kata Sandi',
                        'Untuk mengatur ulang atau mengganti kata sandi akun kader, silakan hubungi Pengurus TP PKK setempat.',
                      ),
                    ),
                    _ActionRow(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi e-PKK Tasikmalaya',
                      onTap: () => _showInfoDialog(
                        'Tentang Aplikasi',
                        'e-PKK Kabupaten Tasikmalaya\nVersi 1.0.0 (Build 2026)\n\n'
                        'Platform sistem informasi digitalisasi pendataan kader Dasawisma dan kegiatan Pokja TP PKK Kabupaten Tasikmalaya.',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 5. TOMBOL KELUAR ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _loggingOut ? null : _handleLogout,
                      icon: _loggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFEF4444),
                              ),
                            )
                          : const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFEF4444),
                              size: 19,
                            ),
                      label: Text(
                        _loggingOut ? 'Memproses...' : 'Keluar Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Text(
                  'TP PKK Kabupaten Tasikmalaya • v1.0.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── HEADER DENGAN GAYA TIMELESS & ORGANIK ──
  Widget _buildProfileHeader(User user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          // Avatar dengan border halus dan tombol kamera
          GestureDetector(
            onTap: _pilihFotoProfil,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryTeal.withValues(alpha: 0.35),
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: softTealBg,
                    backgroundImage:
                        _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Text(
                            user.nama.isNotEmpty
                                ? user.nama[0].toUpperCase()
                                : 'K',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: primaryTeal,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Nama Kader
          Text(
            user.nama,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),

          // Badge Jabatan Elegan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: softTealBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFCCFBF1),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: primaryTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  '${user.jabatan} • TP PKK',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS CAPSULE MINIMALIS & TIMELESS ──
  Widget _buildStatsCapsule() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('24', 'Keluarga', Icons.home_rounded),
          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
          _buildStatItem('18', 'KIA & Gizi', Icons.child_care_rounded),
          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
          _buildStatItem('12', 'Lap. Pokja', Icons.assignment_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: primaryTeal),
            const SizedBox(width: 6),
            Text(
              count,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── KARTU BAGIAN DENGAN BORDER HALUS & TIDAK KAKU ──
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: softTealBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: primaryTeal),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 6),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSuccess;

  const _InfoRow({required this.label, required this.value, this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSuccess ? const Color(0xFF059669) : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}

