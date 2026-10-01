// lib/screens/profile_screen.dart — diperbarui: selaras kader/admin, tidak ramai, pill & soft
import 'dart:io';
// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

import '../widgets/change_password_dialog.dart';

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
  bool _isKaderDark = false;

  static const brandBlue = Color(0xFF0072BC);
  static const brandBlueDark = Color(0xFF005893);

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isKaderDark != isDark) setState(() => _isKaderDark = isDark);
  }

  @override
  void initState() {
    super.initState();
    _future = _authService.getCurrentUser();
    _isKaderDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadKaderTheme();
  }

  Future<void> _loadKaderTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kd = prefs.getBool('kader_dark_mode');
      final md = prefs.getBool('isDarkMode');
      final val = kd ?? md ?? (themeNotifier.value == ThemeMode.dark);
      if (mounted && _isKaderDark != val) setState(() => _isKaderDark = val);
      if (themeNotifier.value != (val ? ThemeMode.dark : ThemeMode.light)) {
        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _authService.dispose();
    super.dispose();
  }

  Future<void> _pilihFotoProfil() async {
    HapticFeedback.lightImpact();
    final isDark = _isDark(context);
    final sheetBg = isDark ? const Color(0xFF1E242F) : Colors.white;
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        decoration: BoxDecoration(color: sheetBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text('Ubah Foto Profil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              _sheetTile(icon: Icons.camera_alt_rounded, title: 'Ambil dari Kamera', subtitle: 'Gunakan kamera ponsel', color: brandBlue, isDark: isDark, onTap: () => Navigator.pop(context, ImageSource.camera)),
              const SizedBox(height: 8),
              _sheetTile(icon: Icons.photo_library_rounded, title: 'Pilih dari Galeri', subtitle: 'Pilih dari album foto', color: brandBlue, isDark: isDark, onTap: () => Navigator.pop(context, ImageSource.gallery)),
            ]),
          ),
        ),
      ),
    );
    if (sumber == null) return;
    try {
      final img = await _picker.pickImage(source: sumber, imageQuality: 80, maxWidth: 600);
      if (img != null) {
        setState(() => _profileImage = File(img.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Foto profil diperbarui', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white)),
            backgroundColor: brandBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ));
        }
      }
    } catch (_) {}
  }

  Widget _sheetTile({required IconData icon, required String title, required String subtitle, required Color color, required bool isDark, required VoidCallback onTap}) {
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 18, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
            ])),
            Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? Colors.white24 : const Color(0xFF94A3B8)),
          ]),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final isDark = _isDark(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E242F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar Akun?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        content: Text('Anda akan keluar dari sesi e-PKK Kab. Tasikmalaya.', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: isDark ? Colors.white70 : const Color(0xFF64748B), height: 1.5)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : const Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text('Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _loggingOut = true);
      await _authService.logout();
      if (mounted) {
        setState(() => _loggingOut = false);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    }
  }

  void _showInfo(String title, String msg) {
    HapticFeedback.selectionClick();
    final isDark = _isDark(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E242F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: isDark ? Colors.white70 : const Color(0xFF475569), height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: brandBlue)))],
      ),
    );
  }

  bool _isDark(BuildContext ctx) => _isKaderDark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final bg = isDark ? const Color(0xFF10141D) : const Color(0xFFF1F4F9);
    final cardBg = isDark ? const Color(0xFF1E242F) : Colors.white;
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: bg,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textCol), onPressed: () => Navigator.pop(context)),
              title: Text('Profil Akun', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: textCol)),
              centerTitle: true,
            ),
      body: FutureBuilder<User>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: brandBlue, strokeWidth: 2.5));
          if (snap.hasError) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.error_outline_rounded, size: 44, color: sub),
              const SizedBox(height: 10),
              Text('Gagal memuat profil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: sub)),
              const SizedBox(height: 6),
              Text(snap.error.toString().replaceFirst('Exception: ', ''), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sub)),
            ]));
          }
          final user = snap.data!;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(children: [
              // 1. HERO BLUE PROFILE & STAT CARD (Sesuai tema baru)
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                    decoration: BoxDecoration(
                      color: brandBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: brandBlue.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top bar inside card: mode gelap toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                user.roles.isNotEmpty ? user.roles.first.toUpperCase() : 'ANGGOTA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                HapticFeedback.selectionClick();
                                final newVal = !isDark;
                                setState(() => _isKaderDark = newVal);
                                themeNotifier.value = newVal ? ThemeMode.dark : ThemeMode.light;
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('kader_dark_mode', newVal);
                                await prefs.setBool('isDarkMode', newVal);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      isDark ? 'Gelap' : 'Terang',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Avatar
                        GestureDetector(
                          onTap: _pilihFotoProfil,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                                  child: _profileImage == null
                                      ? Text(
                                          user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'P',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt_rounded, size: 13, color: brandBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          user.nama,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${user.jabatan} • TP PKK Kab. Tasikmalaya',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                        const SizedBox(height: 16),

                        // Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Status Akun Terverifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: brandBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: bg, width: 2),
                      ),
                      child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. WILAYAH TUGAS & INFORMASI AKUN
              _sectionHeader('Informasi Akun', textCol),
              const SizedBox(height: 10),
              _buildModernInfoCard(
                icon: Icons.alternate_email_rounded,
                label: 'Username / Email',
                value: user.email.isNotEmpty ? user.email : user.username,
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
              ),
              _buildModernInfoCard(
                icon: Icons.location_on_outlined,
                label: 'Wilayah Penugasan',
                value: 'Kec. Singaparna, Kab. Tasikmalaya',
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
              ),
              _buildModernInfoCard(
                icon: Icons.badge_outlined,
                label: 'Peran & Tanggung Jawab',
                value: user.roles.join(', '),
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
              ),

              const SizedBox(height: 20),

              // 3. PENGATURAN & KEAMANAN AKUN (TERMASUK GANTI PASSWORD)
              _sectionHeader('Pengaturan & Keamanan', textCol),
              const SizedBox(height: 10),

              // Tombol Ganti Password
              _buildSettingActionCard(
                icon: Icons.key_rounded,
                iconColor: const Color(0xFF0072BC),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Ganti Kata Sandi',
                subtitle: 'Ubah password akun secara mandiri',
                isHighlighted: true,
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
                onTap: () => ChangePasswordDialog.show(context, isDark: isDark),
              ),

              _buildSettingActionCard(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF0072BC),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Tentang Aplikasi',
                subtitle: 'e-PKK Kab. Tasikmalaya v1.0.0 (2026)',
                isHighlighted: false,
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
                onTap: () => _showInfo('Tentang e-PKK', 'Sistem Informasi Pelaporan & Pendataan TP PKK Kabupaten Tasikmalaya.'),
              ),

              const SizedBox(height: 24),

              // Tombol Keluar Akun
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _loggingOut ? null : _handleLogout,
                  icon: _loggingOut
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                      : const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                  label: Text(
                    _loggingOut ? 'Memproses...' : 'Keluar dari Akun',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5, color: const Color(0xFFEF4444)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.2),
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '© 2026 Sekretariat TP PKK Kabupaten Tasikmalaya',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sub),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, Color textCol) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: textCol,
        ),
      ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required Color border,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sub.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: sub),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sub)),
                  const SizedBox(height: 2),
                  Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: textCol)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isHighlighted,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required Color border,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? brandBlue.withValues(alpha: 0.35) : border,
              width: isHighlighted ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted ? brandBlue.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: textCol)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: sub)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: sub),
            ],
          ),
        ),
      ),
    );
  }
}

