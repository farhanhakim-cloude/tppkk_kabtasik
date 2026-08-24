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
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Image.asset('assets/images/logo.png', width: 34, height: 34),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Selamat',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        Text(
                          'Datang',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TP PKK Kab. Tasikmalaya',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
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
                padding: const EdgeInsets.fromLTRB(28, 44, 28, 24),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 22),
                        _UnderlineField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          primary: primary,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 19,
                              color: Colors.grey[400],
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Hubungi admin jika lupa password',
                            style: GoogleFonts.plusJakartaSans(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Material(
                            color: primary,
                            borderRadius: BorderRadius.circular(26),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(26),
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
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Sistem khusus kader terdaftar',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 12),
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
      style: GoogleFonts.plusJakartaSans(fontSize: 14.5),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 19, color: Colors.grey[400]),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary, width: 1.6)),
        errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 1.2)),
      ),
    );
  }
}