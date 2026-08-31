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

  @override
  void initState() {
    super.initState();
    _future = _authService.getCurrentUser();
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Ubah Foto Profil',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text('Ambil dari Kamera',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                subtitle: Text('Gunakan kamera langsung',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500])),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                ),
                title: Text('Pilih dari Galeri',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                subtitle: Text('Ambil dari album foto ponsel',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500])),
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
              content: Text('Foto profil berhasil diperbarui',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Keluar Akun?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Anda akan keluar dari aplikasi e-PKK.\nApakah Anda yakin ingin melanjutkan?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: Colors.grey[600], height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Ya, Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loggingOut = true);
    await _authService.logout();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showInfoDialog(String title, String message) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17)),
        content: Text(message,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: Colors.grey[600], height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text('Profil Kader',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
            ),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat profil: ${snapshot.error}',
                  style: GoogleFonts.plusJakartaSans()),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                // ── 1. BLUE HERO HEADER (DENGAN TAMBAH FOTO PROFIL) ──
                _buildHeroHeader(user),

                // ── 2. CONTRIBUTION STATS ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      _buildStatCard('24 KK', 'Keluarga', Icons.home_work_rounded, const Color(0xFF2563EB)),
                      const SizedBox(width: 10),
                      _buildStatCard('18 Anak', 'KIA & Gizi', Icons.child_care_rounded, const Color(0xFF0EA5E9)),
                      const SizedBox(width: 10),
                      _buildStatCard('12 Laporan', 'Pokja I-IV', Icons.assignment_turned_in_rounded, const Color(0xFF3B82F6)),
                    ],
                  ),
                ),

                // ── 3. DATA WILAYAH & TUGAS ──
                _buildSectionContainer(
                  title: 'Wilayah Tugas & Dasawisma',
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF2563EB),
                  items: [
                    _InfoRow(label: 'Kabupaten', value: 'Kabupaten Tasikmalaya'),
                    _InfoRow(label: 'Kecamatan', value: 'Kecamatan Singaparna'),
                    _InfoRow(label: 'Desa / Kelurahan', value: 'Desa Cipakat'),
                    _InfoRow(label: 'Kelompok Dasawisma', value: 'Dasawisma Mawar 02'),
                    _InfoRow(label: 'Wilayah RT / RW', value: 'RT 02 / RW 05'),
                  ],
                ),

                // ── 4. PENGATURAN & BANTUAN ──
                _buildSectionContainer(
                  title: 'Pengaturan & Bantuan',
                  icon: Icons.settings_rounded,
                  iconColor: const Color(0xFF64748B),
                  items: [
                    _ActionRow(
                      icon: Icons.menu_book_rounded,
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
                        'Untuk mengganti kata sandi akun, silakan hubungi Admin TP PKK Kecamatan Anda.',
                      ),
                    ),
                    _ActionRow(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi e-PKK Kab. Tasikmalaya',
                      onTap: () => _showInfoDialog(
                        'Tentang Aplikasi',
                        'e-PKK Kabupaten Tasikmalaya\nVersi 1.0.0 (Build 2026)\n\n'
                        'Aplikasi digitalisasi pencatatan data keluarga, gizi KIA, dan kegiatan Pokja TP PKK Kabupaten Tasikmalaya.',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 5. TOMBOL LOGOUT ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _loggingOut ? null : _handleLogout,
                      icon: _loggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                            )
                          : const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      label: Text(
                        _loggingOut ? 'Memproses...' : 'Keluar dari Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'TP PKK Kabupaten Tasikmalaya • v1.0.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(User user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1D4ED8), // Royal Blue
            Color(0xFF2563EB), // Vibrant Blue
            Color(0xFF3B82F6), // Sky Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              // Avatar with upload option
              GestureDetector(
                onTap: _pilihFotoProfil,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFF1E40AF),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Text(
                                user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'K',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    // Camera Edit Button Badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Name
              Text(
                user.nama,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '${user.jabatan} • TP PKK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk foto untuk mengganti foto profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF475569)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
