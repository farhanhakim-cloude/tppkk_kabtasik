// lib/widgets/notifikasi_bell.dart
// Ikon lonceng + badge merah jumlah belum dibaca — dipakai di header
// dashboard kader & dasawisma (keduanya header biru solid).

import 'package:flutter/material.dart';

class NotifikasiBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final Color iconColor;

  const NotifikasiBell({
    super.key,
    required this.count,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return IconButton(
      onPressed: onTap,
      tooltip: 'Notifikasi',
      visualDensity: VisualDensity.compact,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: iconColor, size: 22),
          if (count > 0)
            Positioned(
              right: -2,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
