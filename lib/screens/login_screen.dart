import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0D9488);
    const deepTeal = Color(0xFF0F766E);

    // ============================================================
    // 🔧 FIX OVERFLOW (REVISI FINAL)
    // ------------------------------------------------------------
    // Percobaan sebelumnya (menghitung headerHeight dari
    // MediaQuery.size.height + resizeToAvoidBottomInset: false)
    // ternyata masih rapuh karena perilaku MediaQuery saat keyboard
    // muncul bisa berbeda-beda tergantung device/OS.
    //
    // Solusi final: header TIDAK LAGI diberi tinggi tetap (height)
    // sama sekali. Tinggi header sekarang mengikuti tinggi kontennya
    // sendiri (mainAxisSize.min + SizedBox tetap, bukan Spacer()).
    // Dengan begini, header tidak akan PERNAH overflow, apa pun yang
    // terjadi pada ukuran layar atau keyboard.
    // ============================================================
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // 👈 FIX: cegah layout resize saat keyboard muncul
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        // 👈 FIX: kompensasi manual supaya field tidak ketutup keyboard
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============================================================
            // 🌊 HEADER BERGELOMBANG HIJAU DENGAN BUBBLE & LOGO DI ATAS TEKS
            // ============================================================
            ClipPath(
              clipper: HeaderWaveClipper(),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [deepTeal, primaryTeal],
                  ),
                ),
                child: Stack(
                  children: [
                    // Bubble dekoratif 1 (Kanan atas)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    // Bubble dekoratif 2 (Kanan tengah)
                    Positioned(
                      top: 110,
                      right: 65,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    // Bubble dekoratif 3 (Kiri tengah)
                    Positioned(
                      top: 130,
                      left: 20,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    // Bubble dekoratif 4 (Kecil tengah)
                    Positioned(
                      top: 70,
                      right: 130,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),
                    ),

                    // Konten Header: Tombol Back, Logo persis di atas teks Welcome Back
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // 👈 FIX: tinggi mengikuti konten, bukan memaksa mengisi parent
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Tombol Back ke onboarding jika dibutuhkan
                            GestureDetector(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(
                                      context, '/onboarding');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24), // 👈 FIX: pengganti Spacer() yang rawan overflow

                            // 🌟 LOGO PERSIS DI ATAS TEKS
                            Image.asset(
                              'assets/images/logo.png',
                              width: 54,
                              height: 54,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.diversity_1_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Teks Welcome Back
                            Text(
                              'Welcome\nBack',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'TP PKK Kab. Tasikmalaya',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 38),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // 📝 FORM EMAIL & PASSWORD (TIDAK DIUBAH FUNGSINYA)
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner Error
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 18, color: Color(0xFFDC2626)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFDC2626),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Field Email
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'Alamat Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      primaryColor: primaryTeal,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Field Password
                    _buildInputField(
                      controller: _passwordController,
                      hintText: 'Kata Sandi',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      primaryColor: primaryTeal,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 4) {
                          return 'Password minimal 4 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Silakan hubungi admin TP PKK Kab. Tasikmalaya untuk reset kata sandi.',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                              ),
                              backgroundColor: const Color(0xFF0F172A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryTeal,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Log in
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primaryTeal.withValues(alpha: 0.6),
                          elevation: 2,
                          shadowColor: primaryTeal.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Log in',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pembatas 'or'
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol Bantuan / Hubungi Admin (Sign up style)
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pendaftaran akun kader PKK dilakukan melalui Sekretariat TP PKK Kabupaten Tasikmalaya.',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                              ),
                              backgroundColor: deepTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Hubungi Admin TP PKK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

/// Clipper untuk menghasilkan lengkungan gelombang organik (wave curve)
class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    // Gelombang pertama
    final firstControlPoint = Offset(size.width * 0.28, size.height + 15);
    final firstEndPoint = Offset(size.width * 0.60, size.height - 24);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Gelombang kedua
    final secondControlPoint = Offset(size.width * 0.86, size.height - 54);
    final secondEndPoint = Offset(size.width, size.height - 28);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}