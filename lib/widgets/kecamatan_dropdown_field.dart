// lib/widgets/kecamatan_dropdown_field.dart
// Dropdown 39 Kecamatan di Kabupaten Tasikmalaya

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/kecamatan_options.dart';

class KecamatanDropdownField extends StatelessWidget {
  final String? value;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;
  final String label;
  final bool isRequired;
  final bool allowEmpty;
  final String? emptyLabel;
  final bool isCompact;
  final InputDecoration? customDecoration;
  final Widget? prefixIcon;

  const KecamatanDropdownField({
    super.key,
    this.value,
    this.controller,
    this.onChanged,
    this.label = 'Kecamatan',
    this.isRequired = false,
    this.allowEmpty = false,
    this.emptyLabel,
    this.isCompact = false,
    this.customDecoration,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D9488);

    // Tentukan nilai terpilih saat ini
    String? currentVal = value ?? controller?.text;
    if (currentVal != null && currentVal.isNotEmpty) {
      // Cari kecocokan case-insensitive
      final match = kKecamatanOptions.firstWhere(
        (e) => e.toLowerCase() == currentVal?.toLowerCase(),
        orElse: () => '',
      );
      currentVal = match.isNotEmpty ? match : (allowEmpty ? '' : null);
    }

    // Default fallback jika kosong dan allowEmpty false
    if (!allowEmpty && (currentVal == null || currentVal.isEmpty)) {
      currentVal = 'Singaparna';
      controller?.text = 'Singaparna';
    }

    final defaultDecoration = InputDecoration(
      labelText: isRequired ? '$label *' : label,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: isCompact ? 11 : 12,
        color: const Color(0xFF64748B),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: prefixIcon ??
          Icon(Icons.location_city_rounded, size: isCompact ? 16 : 18, color: primary),
      contentPadding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
    );

    return DropdownButtonFormField<String>(
      value: currentVal,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down_rounded, color: const Color(0xFF64748B), size: isCompact ? 18 : 22),
      style: GoogleFonts.plusJakartaSans(
        fontSize: isCompact ? 12 : 13.5,
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      decoration: customDecoration ?? defaultDecoration,
      items: [
        if (allowEmpty)
          DropdownMenuItem<String>(
            value: '',
            child: Text(
              emptyLabel ?? 'Semua Kecamatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: isCompact ? 12 : 13.5,
                color: const Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ...kKecamatanOptions.map((kec) {
          return DropdownMenuItem<String>(
            value: kec,
            child: Text(
              kec,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isCompact ? 12 : 13.5,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
      onChanged: (newVal) {
        final val = newVal ?? '';
        if (controller != null) {
          controller!.text = val;
        }
        if (onChanged != null) {
          onChanged!(val);
        }
      },
      validator: isRequired
          ? (v) => (v == null || v.isEmpty) ? '$label wajib dipilih' : null
          : null,
    );
  }
}
