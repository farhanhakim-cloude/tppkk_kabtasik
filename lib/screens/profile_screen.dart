// lib/screens/profile_screen.dart — diperbarui: selaras kader/admin, tidak ramai, pill & soft
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
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
  bool _isKaderDark = true;

  // selaras palet kader/admin
  static const primaryMint = Color(0xFF2ED9C3);
  static const primaryTeal = Color(0xFF0D9488);
  static const darkTeal = Color(0xFF0F766E);

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
      // sinkronkan themeNotifier agar dashboard & profile selaras
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
    final sheetBg = isDark ? const Color(0xFF1E242D) : Colors.white;
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
              _sheetTile(icon: Icons.camera_alt_rounded, title: 'Ambil dari Kamera', subtitle: 'Gunakan kamera ponsel', color: primaryTeal, isDark: isDark, onTap: () => Navigator.pop(context, ImageSource.camera)),
              const SizedBox(height: 8),
              _sheetTile(icon: Icons.photo_library_rounded, title: 'Pilih dari Galeri', subtitle: 'Pilih dari album foto', color: primaryMint, isDark: isDark, onTap: () => Navigator.pop(context, ImageSource.gallery)),
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
            backgroundColor: primaryTeal,
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
        backgroundColor: isDark ? const Color(0xFF1E242D) : Colors.white,
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
        backgroundColor: isDark ? const Color(0xFF1E242D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: isDark ? Colors.white70 : const Color(0xFF475569), height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primaryTeal)))],
      ),
    );
  }

  bool _isDark(BuildContext ctx) => _isKaderDark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final bg = isDark ? const Color(0xFF14181F) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E242D) : Colors.white;
    final border = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primary = isDark ? primaryMint : primaryTeal;

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: isDark ? const Color(0xFF1A1F28) : Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)), onPressed: () => Navigator.pop(context)),
              title: Text('Profil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              centerTitle: true,
            ),
      body: FutureBuilder<User>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primary, strokeWidth: 2.5));
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
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(children: [
              // Header — ala admin tapi soft, tidak ramai
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(22), border: Border.all(color: border)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                      borderRadius: BorderRadius.circular(20),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Text(isDark ? 'Gelap' : 'Terang', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF334155))),
                      ])),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pilihFotoProfil,
                    child: Stack(children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primary.withValues(alpha: 0.18), width: 2)),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: primary.withValues(alpha: 0.10),
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? Text(user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'K', style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w800, color: primary))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: cardBg, width: 2)), child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Text(user.nama, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(user.email, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: sub)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withValues(alpha: 0.18))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified_rounded, size: 14, color: primary),
                      const SizedBox(width: 6),
                      Text('${user.jabatan} • TP PKK', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: primary)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              // Stats — minimalis pill
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
                child: Row(children: [
                  _stat('24', 'Keluarga', Icons.home_rounded, isDark, primary, sub),
                  _divider(isDark),
                  _stat('18', 'KIA & Gizi', Icons.child_care_rounded, isDark, primary, sub),
                  _divider(isDark),
                  _stat('12', 'Lap. Pokja', Icons.assignment_rounded, isDark, primary, sub),
                ]),
              ),
              const SizedBox(height: 14),
              // Wilayah — tidak ramai: 4 baris saja
              _sectionCard(
                title: 'Wilayah Tugas',
                icon: Icons.location_on_rounded,
                isDark: isDark, cardBg: cardBg, border: border, sub: sub, primary: primary, items: [
                  _infoRow('Kabupaten', 'Kab. Tasikmalaya', isDark),
                  _infoRow('Kecamatan', 'Singaparna', isDark),
                  _infoRow('Desa', 'Cipakat', isDark),
                  _infoRow('Dasawisma', 'Mawar 02 • RT 02/RW 05', isDark),
                ]),
              const SizedBox(height: 12),
              // Menu seperti admin Input Langsung — tapi untuk kader
              _sectionCard(
                title: 'Menu',
                icon: Icons.grid_view_rounded,
                isDark: isDark, cardBg: cardBg, border: border, sub: sub, primary: primary, items: [
                  _actionRow(icon: Icons.assignment_outlined, title: 'Riwayat Catatan Pokja', subtitle: 'Lihat laporan yang pernah dikirim', isDark: isDark, onTap: () => _showInfo('Riwayat', 'Fitur riwayat catatan akan menampilkan semua laporan yang telah Anda kirim.')),
                  _actionRow(icon: Icons.shield_outlined, title: 'Keamanan Akun', subtitle: 'Ubah kata sandi', isDark: isDark, onTap: () => _showInfo('Keamanan', 'Hubungi pengurus TP PKK untuk ubah kata sandi.')),
                  _actionRow(icon: Icons.info_outline_rounded, title: 'Tentang e-PKK', subtitle: 'Versi 1.0.0 • Kab. Tasikmalaya', isDark: isDark, onTap: () => _showInfo('Tentang', 'e-PKK Kab. Tasikmalaya\nVersi 1.0.0 (2026)\nDigitalisasi pendataan Dasawisma & Pokja.')),
                ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: _loggingOut ? null : _handleLogout,
                  icon: _loggingOut ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444))) : const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                  label: Text(_loggingOut ? 'Memproses...' : 'Keluar Akun', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFFEF4444))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA)), backgroundColor: isDark ? const Color(0xFFEF4444).withValues(alpha: 0.08) : const Color(0xFFFEF2F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                ),
              ),
              const SizedBox(height: 12),
              Text('TP PKK Kab. Tasikmalaya • v1.0.0', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sub)),
            ]),
          );
        },
      ),
    );
  }

  Widget _stat(String v, String label, IconData icon, bool isDark, Color primary, Color sub) => Expanded(child: Column(children: [
    Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: primary), const SizedBox(width: 5), Text(v, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A)))]),
    const SizedBox(height: 3), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: sub, fontWeight: FontWeight.w600)),
  ]));
  Widget _divider(bool isDark) => Container(height: 28, width: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0));

  Widget _sectionCard({required String title, required IconData icon, required bool isDark, required Color cardBg, required Color border, required Color sub, required Color primary, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 15, color: primary)),
          const SizedBox(width: 10), Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        ]),
        const SizedBox(height: 10), Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)), const SizedBox(height: 6),
        ...items,
      ]),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)))),
    ]),
  );

  Widget _actionRow({required IconData icon, required String title, required String subtitle, required bool isDark, required VoidCallback onTap}) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2), child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B))),
          const SizedBox(height: 1), Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
        ])),
        Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
      ])),
    ),
  );
}
