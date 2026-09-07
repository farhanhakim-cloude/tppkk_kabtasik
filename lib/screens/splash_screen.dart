import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();

  // 1. Controller untuk Liquid / Circular Reveal (Mekar dari kecil ke bentuk biasa)
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  late Animation<double> _liquidWobble;

  // 2. Controller Riak Lingkaran Cairan Setelah Terbuka
  late AnimationController _liquidSplashController;
  late Animation<double> _liquidSplashRadius;
  late Animation<double> _liquidSplashOpacity;

  // 3. Controller untuk Logo Mengambang & Bernapas (Setelah reveal selesai)
  late AnimationController _idleController;
  late Animation<double> _idleScale;
  late Animation<double> _idleFloat;

  // 4. Controller Bouncing Dots Loading di Bawah
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 1. Inisialisasi Liquid Circular Reveal
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutBack),
    );

    _liquidWobble = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeInOutSine),
    );

    // 2. Inisialisasi Percikan Riak Gelembung Cairan di Sekitar Logo
    _liquidSplashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _liquidSplashRadius = Tween<double>(begin: 20.0, end: 56.0).animate(
      CurvedAnimation(parent: _liquidSplashController, curve: Curves.easeOutCubic),
    );
    _liquidSplashOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _liquidSplashController, curve: Curves.easeOut),
    );

    // 3. Inisialisasi Idle Float & Breathing Logo
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _idleScale = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );
    _idleFloat = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    // 4. Inisialisasi Bouncing Dots
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Jalankan urutan animasi
    _revealController.forward().then((_) {
      if (mounted) {
        // Meletupkan percikan riak cairan sekali saat logo mekar penuh
        _liquidSplashController.forward();
        // Lanjutkan animasi pernapasan mengambang dan titik loading
        _idleController.repeat(reverse: true);
        _dotController.repeat();
      }
    });

    _checkNextScreen();
  }

  Future<void> _checkNextScreen() async {
    // Tampilkan animasi splash selama 2.5 detik
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final isLoggedIn = await _authService.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _liquidSplashController.dispose();
    _idleController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: primaryTeal,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Efek Percikan Riak Cairan yang meletup saat circular reveal mencapai bentuk biasa
          AnimatedBuilder(
            animation: _liquidSplashController,
            builder: (context, _) {
              if (_liquidSplashController.value == 0 || _liquidSplashController.isCompleted) {
                return const SizedBox.shrink();
              }
              return Container(
                width: _liquidSplashRadius.value * 2,
                height: _liquidSplashRadius.value * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(_liquidSplashOpacity.value),
                    width: 2.5,
                  ),
                ),
              );
            },
          ),

          // Konten Tengah: Liquid / Circular Reveal Logo
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_revealController, _idleController]),
              builder: (context, child) {
                final reveal = _revealAnimation.value;
                final wobble = _liquidWobble.value;
                final floatY = _revealController.isCompleted ? _idleFloat.value : 0.0;
                final scale = _revealController.isCompleted ? _idleScale.value : 1.0;

                return Transform.translate(
                  offset: Offset(0, floatY),
                  child: Transform.scale(
                    scale: scale,
                    child: ClipPath(
                      clipper: _LiquidCircularRevealClipper(
                        revealProgress: reveal.clamp(0.0, 1.0),
                        wobble: wobble,
                      ),
                      child: SizedBox(
                        width: 95,
                        height: 95,
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 85,
                            height: 85,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.diversity_1_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Indikator Loading 3 Titik Memantul di Bawah
          Positioned(
            bottom: 60,
            child: AnimatedBuilder(
              animation: _dotController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animValue = (_dotController.value - delay) % 1.0;
                    final bounce = (animValue >= 0 && animValue <= 0.5)
                        ? math.sin(animValue * math.pi * 2) * -8.0
                        : 0.0;
                    final opacity = (animValue >= 0 && animValue <= 0.5)
                        ? 0.95
                        : 0.40;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.5),
                      child: Transform.translate(
                        offset: Offset(0, bounce),
                        child: Container(
                          width: 8.5,
                          height: 8.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM CLIPPER: LIQUID / CIRCULAR REVEAL DARI KECIL KE BENTUK BIASA
// ─────────────────────────────────────────────────────────────────────────────
class _LiquidCircularRevealClipper extends CustomClipper<Path> {
  final double revealProgress;
  final double wobble;

  _LiquidCircularRevealClipper({
    required this.revealProgress,
    required this.wobble,
  });

  @override
  Path getClip(Size size) {
    if (revealProgress <= 0.001) return Path();

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2) * revealProgress;

    // Jika sudah mekar sempurna, kembalikan lingkaran murni yang bersih
    if (revealProgress >= 0.999) {
      return Path()..addOval(Rect.fromCircle(center: center, radius: size.width / 2));
    }

    final path = Path();
    const int segments = 48;

    // Formula kontur cairan (liquid bubble dynamic curve)
    for (int i = 0; i <= segments; i++) {
      final double theta = (i / segments) * 2 * math.pi;
      final double liquidWave = math.sin(theta * 4 + wobble * math.pi * 3) *
          (1.0 - revealProgress) *
          6.0;
      final double r = (baseRadius + liquidWave).clamp(0.0, size.width / 2);
      final double x = center.dx + r * math.cos(theta);
      final double y = center.dy + r * math.sin(theta);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _LiquidCircularRevealClipper oldClipper) {
    return oldClipper.revealProgress != revealProgress || oldClipper.wobble != wobble;
  }
}