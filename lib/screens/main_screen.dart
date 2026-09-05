import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

/// [MainScreen] diteruskan langsung ke [DashboardScreen]
/// untuk mencegah duplikasi Bottom Navigation Bar dan tabrakan layout.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
