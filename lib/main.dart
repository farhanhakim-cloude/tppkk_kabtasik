import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D9488);

    return MaterialApp(
      title: 'TP PKK Kab. Tasikmalaya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
          bodyMedium: GoogleFonts.plusJakartaSans(color: const Color(0xFF334155)),
          bodySmall: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF334155)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFF1F5F9),
          thickness: 1,
          space: 0,
        ),
        splashColor: const Color(0x0D0D9488),
        highlightColor: const Color(0x080D9488),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

