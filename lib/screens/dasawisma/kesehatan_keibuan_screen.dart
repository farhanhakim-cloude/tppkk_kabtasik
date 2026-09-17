import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kesehatan_list_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';

class KesehatanKeibuanScreen extends StatefulWidget {
  final int initialTab;
  final bool embedded;

  const KesehatanKeibuanScreen({
    super.key,
    this.initialTab = 0,
    this.embedded = false,
  });

  @override
  State<KesehatanKeibuanScreen> createState() => _KesehatanKeibuanScreenState();
}

class _KesehatanKeibuanScreenState extends State<KesehatanKeibuanScreen> {
  late int _selectedTab;

  static const Color _tealPrimary = Color(0xFF0D9488);
  static const Color _pinkAccent = Color(0xFFE11D48);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  Widget _buildSubTabItem({
    required int index,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kesehatan Balita & Keibuan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Catatan Kelahiran, Ibu & Pemantauan Balita',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildSubTabItem(
                        index: 0,
                        title: 'Kesehatan Balita (KIA)',
                        icon: Icons.child_care_rounded,
                        activeColor: _tealPrimary,
                      ),
                      _buildSubTabItem(
                        index: 1,
                        title: 'Catatan Kelahiran & Ibu',
                        icon: Icons.pregnant_woman_rounded,
                        activeColor: _pinkAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: IndexedStack(
        index: _selectedTab,
        children: const [
          KesehatanListScreen(embedded: true, showHeader: false),
          RekapIbuAnakListScreen(embedded: true),
        ],
      ),
    );
  }
}
