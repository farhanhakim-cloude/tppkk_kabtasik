// lib/screens/dasawisma/data_umum_rekap_screen.dart
// Rekap Data Umum — gaya disamakan dengan dashboard (biru-putih dinas).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/data_keluarga_dasawisma.dart';
import '../../services/daftar_warga_service.dart';

class DataUmumRekapScreen extends StatefulWidget {
  const DataUmumRekapScreen({super.key});

  @override
  State<DataUmumRekapScreen> createState() => _DataUmumRekapScreenState();
}

class _DataUmumRekapScreenState extends State<DataUmumRekapScreen> {
  static const Color biru = Color(0xFF0072BC);
  static const Color ink = Color(0xFF1A2B3C);
  static const Color muted = Color(0xFF5B6B7C);
  static const Color line = Color(0xFFE1E7EE);
  static const Color paper = Color(0xFFF4F6F9);

  bool _loading = true;
  int _totalKk = 0;
  int _totalJiwa = 0;
  int _totalL = 0;
  int _totalP = 0;
  int _totalBalita = 0;
  int _totalPus = 0;
  int _totalWus = 0;
  int _totalBumil = 0;
  int _totalBusui = 0;
  int _totalLansia = 0;
  int _totalRumahSehat = 0;
  int _totalRumahTidakSehat = 0;

  Map<String, Map<String, int>> _perDusun = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final list = await DaftarWargaService().getAll();
      final listKk = list.cast<DataKeluargaDasawisma>();

      int totalJiwa = 0, totalL = 0, totalP = 0, totalBalita = 0;
      int totalPus = 0, totalWus = 0, totalBumil = 0, totalBusui = 0, totalLansia = 0;
      int rumahSehat = 0, rumahTidakSehat = 0;

      final perDusun = <String, Map<String, int>>{};

      for (final kk in listKk) {
        final l = kk.jumlahLakiLaki;
        final p = kk.jumlahPerempuan;
        totalL += l;
        totalP += p;
        totalJiwa += (l + p);
        totalBalita += (kk.jumlahBalitaL + kk.jumlahBalitaP);
        totalPus += kk.jumlahPus;
        totalWus += kk.jumlahWus;
        totalBumil += kk.jumlahIbuHamil;
        totalBusui += kk.jumlahIbuMenyusui;
        totalLansia += kk.jumlahLansia;

        if (kk.kriteriaRumah == 'Sehat') {
          rumahSehat++;
        } else {
          rumahTidakSehat++;
        }

        final dusun = kk.dusun.isEmpty ? 'Tanpa Dusun' : kk.dusun;
        perDusun.putIfAbsent(dusun, () => {'kk': 0, 'jiwa': 0, 'balita': 0});
        perDusun[dusun]!['kk'] = (perDusun[dusun]!['kk'] ?? 0) + 1;
        perDusun[dusun]!['jiwa'] = (perDusun[dusun]!['jiwa'] ?? 0) + (l + p);
        perDusun[dusun]!['balita'] = (perDusun[dusun]!['balita'] ?? 0) + (kk.jumlahBalitaL + kk.jumlahBalitaP);
      }

      if (!mounted) return;
      setState(() {
        _totalKk = listKk.length;
        _totalJiwa = totalJiwa;
        _totalL = totalL;
        _totalP = totalP;
        _totalBalita = totalBalita;
        _totalPus = totalPus;
        _totalWus = totalWus;
        _totalBumil = totalBumil;
        _totalBusui = totalBusui;
        _totalLansia = totalLansia;
        _totalRumahSehat = rumahSehat;
        _totalRumahTidakSehat = rumahTidakSehat;
        _perDusun = perDusun;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      appBar: AppBar(
        backgroundColor: biru,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rekap Data Umum',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Ringkasan KK dan warga',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadData),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: biru))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: biru,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _section('Ringkasan'),
                  const SizedBox(height: 8),
                  _grid4([
                    _Stat('KK', '$_totalKk'),
                    _Stat('Jiwa', '$_totalJiwa'),
                    _Stat('L', '$_totalL'),
                    _Stat('P', '$_totalP'),
                  ]),
                  const SizedBox(height: 16),
                  _section('Kelompok Khusus'),
                  const SizedBox(height: 8),
                  _grid4([
                    _Stat('Balita', '$_totalBalita'),
                    _Stat('PUS', '$_totalPus'),
                    _Stat('WUS', '$_totalWus'),
                    _Stat('Bumil', '$_totalBumil'),
                  ]),
                  const SizedBox(height: 10),
                  _grid4([
                    _Stat('Busui', '$_totalBusui'),
                    _Stat('Lansia', '$_totalLansia'),
                    _Stat('Sehat', '$_totalRumahSehat'),
                    _Stat('Krg Sehat', '$_totalRumahTidakSehat'),
                  ]),
                  const SizedBox(height: 16),
                  _section('Per Dusun'),
                  const SizedBox(height: 8),
                  if (_perDusun.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: line)),
                      child: Center(
                        child: Text('Belum ada data dusun',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: muted)),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: line)),
                      child: Column(
                        children: [
                          for (final e in _perDusun.entries) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.key,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                                        Text('${e.value['kk']} KK • ${e.value['jiwa']} jiwa • ${e.value['balita']} balita',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted)),
                                      ],
                                    ),
                                  ),
                                  Text('${e.value['kk']}',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17, fontWeight: FontWeight.w700, color: biru)),
                                ],
                              ),
                            ),
                            if (e.key != _perDusun.entries.last.key)
                              const Divider(height: 1, indent: 14, endIndent: 14, color: line),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: line)),
                    child: Text(
                      'Otomatis dari input kader. Masuk rekap kabupaten setelah disetujui Admin Desa.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: muted),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _section(String t) => Text(t,
      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: ink));

  Widget _grid4(List<_Stat> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
              child: Column(
                children: [
                  Text(items[i].value,
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: biru)),
                  const SizedBox(height: 2),
                  Text(items[i].label,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: muted)),
                ],
              ),
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Stat {
  final String label;
  final String value;
  _Stat(this.label, this.value);
}
