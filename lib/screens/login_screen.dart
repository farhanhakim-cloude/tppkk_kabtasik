import 'package:flutter/material.dart';
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await _authService.login(_emailController.text.trim(), _passwordController.text);
    setState(() => _loading = false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          // Bagian atas: wave + welcome text
          Expanded(
            flex: 5,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 30,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                  Positioned(
                    top: 90,
                    right: 60,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        // Logo dipusatkan & diperbesar agar lebih proporsional
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset('assets/images/logo.png', width: 52, height: 52, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -0.5),
                              ),
                              Text(
                                'Datang',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  'TP PKK Kab. Tasikmalaya',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bagian bawah: card putih dengan wave clip di atasnya
          Expanded(
            flex: 6,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _UnderlineField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          primary: primary,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                            if (!v.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 26),
                        _UnderlineField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          primary: primary,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Hubungi admin jika lupa password',
                            style: GoogleFonts.plusJakartaSans(color: primary, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Material(
                            color: primary,
                            borderRadius: BorderRadius.circular(28),
                            elevation: 4,
                            shadowColor: primary.withValues(alpha: 0.3),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: _loading ? null : _handleLogin,
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Masuk',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'Sistem khusus kader terdaftar',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 12.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 40);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 18);
    path.quadraticBezierTo(size.width * 0.75, 36, size.width, 4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _UnderlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color primary;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _UnderlineField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.primary,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 15.5, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(icon, size: 21, color: Colors.grey[500]),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 42),
        suffixIcon: suffixIcon,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary, width: 1.8)),
        errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 1.4)),
      ),
    );
  }
}