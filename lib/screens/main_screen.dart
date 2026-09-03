import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_screen.dart';
import 'keluarga_list_screen.dart';
import 'kesehatan_list_screen.dart';
import 'profile_screen.dart';
import 'statistik_screen.dart'; // Just in case you want to use it for 'Shop' icon instead

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const KeluargaListScreen(),
    const StatistikScreen(),
    const KesehatanListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _NavBarItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
              primary: primary,
            ),
            _NavBarItem(
              icon: Icons.description_outlined,
              label: 'Data',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
              primary: primary,
            ),
            _NavBarItem(
              icon: Icons.insert_chart_outlined_rounded,
              label: 'Statistik',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
              primary: primary,
            ),
            _NavBarItem(
              icon: Icons.monitor_heart_outlined,
              label: 'Health',
              isSelected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
              primary: primary,
            ),
            _NavBarItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              isSelected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
              primary: primary,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primary : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? primary : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
