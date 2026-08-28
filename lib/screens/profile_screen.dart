import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  late Future<User> _future;
  bool _loggingOut = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _future = _authService.getCurrentUser();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Keluar Akun?',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
            'Kamu akan keluar dari aplikasi.\nApakah kamu yakin?',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1)),
            child: Text('Keluar',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.red, fontWeight: FontWeight.w700)),
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat profil: ${snapshot.error}',
                    style: GoogleFonts.plusJakartaSans()));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ─── HERO HEADER ───────────────────────────────────────
                  _HeroHeader(user: user, primary: primary, onBack: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  }),

                  // ─── KONTEN BAWAH ──────────────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        children: [
                          // Stats row
                          _StatsRow(primary: primary),
                          const SizedBox(height: 20),

                          // Info section header
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Informasi Akun',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Info cards
                          _InfoCard(
                            icon: Icons.email_rounded,
                            label: 'Alamat Email',
                            value: user.email,
                            gradientColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
                          ),
                          const SizedBox(height: 10),
                          _InfoCard(
                            icon: Icons.location_on_rounded,
                            label: 'Wilayah Tugas',
                            value: user.wilayah,
                            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          const SizedBox(height: 10),
                          _InfoCard(
                            icon: Icons.badge_rounded,
                            label: 'Jabatan',
                            value: user.jabatan,
                            gradientColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                          ),
                          const SizedBox(height: 28),

                          // Section header
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pengaturan',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Settings tiles
                          _SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            label: 'Ubah Password',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {},
                          ),
                          const SizedBox(height: 8),
                          _SettingsTile(
                            icon: Icons.help_outline_rounded,
                            label: 'Bantuan & Dukungan',
                            color: const Color(0xFF0EA5E9),
                            onTap: () {},
                          ),
                          const SizedBox(height: 28),

                          // Logout button
                          _loggingOut
                              ? const CircularProgressIndicator()
                              : _LogoutButton(onTap: _handleLogout),
                          const SizedBox(height: 12),
                          Text(
                            'e-PKK Kader Dasawisma • v1.0.0',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── HERO HEADER ────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final User user;
  final Color primary;
  final VoidCallback onBack;

  const _HeroHeader({required this.user, required this.primary, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran
          Positioned(top: -30, right: -30,
              child: _Blob(size: 140, opacity: 0.08)),
          Positioned(bottom: 30, left: -20,
              child: _Blob(size: 100, opacity: 0.06)),
          Positioned(top: 80, right: 60,
              child: _Blob(size: 50, opacity: 0.10)),

          // Konten
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 36),
              child: Column(
                children: [
                  // AppBar row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Colors.white),
                        onPressed: onBack,
                      ),
                      Expanded(
                        child: Text(
                          'Profil Saya',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      // Placeholder supaya title tetap center
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFBFDBFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Icon(Icons.person_rounded,
                          size: 58, color: primary.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama
                  Text(
                    user.nama,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Badge jabatan
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      user.jabatan,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STATS ROW ───────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Color primary;
  const _StatsRow({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _StatItem(value: 'Aktif', label: 'Status', icon: Icons.check_circle_rounded, color: const Color(0xFF10B981)),
          Container(width: 1, height: 40, color: Colors.grey[100]),
          _StatItem(value: 'Kader', label: 'Peran', icon: Icons.people_alt_rounded, color: primary),
          Container(width: 1, height: 40, color: Colors.grey[100]),
          _StatItem(value: '2024', label: 'Bergabung', icon: Icons.calendar_month_rounded, color: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF1E293B))),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── INFO CARD ───────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 22),
        ],
      ),
    );
  }
}

// ─── SETTINGS TILE ───────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B))),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── LOGOUT BUTTON ───────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('Keluar Akun',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── BLOB / DEKORASI ─────────────────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
