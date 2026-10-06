// lib/screens/dasawisma/data_umum_rekap_screen.dart
// ✅ FIXED: baca dari API — bukan SharedPreferences

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/data_keluarga_dasawisma.dart';
// ✅ GANTI: dari lokal ke API
import '../../services/daftar_warga_service.dart';

class DataUmumRekapScreen extends StatefulWidget {
  const DataUmumRekapScreen({super.key});

  @override
  State<DataUmumRekapScreen> createState() => _DataUmumRekapScreenState();
}

class _DataUmumRekapScreenState extends State<DataUmumRekapScreen> {
  static const Color _primary = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  bool _loading = true;
  List<DataKeluargaDasawisma> _listKk = [];
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
      // ✅ FIXED: pakai DaftarWargaService (API)
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
        _listKk = listKk;
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
    } catch (e) {
      print('❌ DataUmumRekapScreen error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekap Data Umum',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
            Text(
              'Ringkasan data KK & warga',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: _primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _sectionTitle('Ringkasan Utama'),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard('Total KK', '$_totalKk', Icons.home_rounded, const Color(0xFF0D9488)),
                      _statCard('Total Jiwa', '$_totalJiwa', Icons.people_rounded, const Color(0xFF3B82F6)),
                      _statCard('Laki-laki', '$_totalL', Icons.male_rounded, const Color(0xFF2563EB)),
                      _statCard('Perempuan', '$_totalP', Icons.female_rounded, const Color(0xFFEC4899)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Kategori Khusus'),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.05,
                    children: [
                      _statCardSmall('Balita', '$_totalBalita', const Color(0xFFF59E0B)),
                      _statCardSmall('PUS', '$_totalPus', const Color(0xFF10B981)),
                      _statCardSmall('WUS', '$_totalWus', const Color(0xFF06B6D4)),
                      _statCardSmall('Bumil', '$_totalBumil', const Color(0xFFEC4899)),
                      _statCardSmall('Busui', '$_totalBusui', const Color(0xFF8B5CF6)),
                      _statCardSmall('Lansia', '$_totalLansia', const Color(0xFF6366F1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Kriteria Rumah'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _statCardBig(
                          'Rumah Sehat',
                          '$_totalRumahSehat',
                          Icons.home_rounded,
                          const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCardBig(
                          'Kurang Sehat',
                          '$_totalRumahTidakSehat',
                          Icons.home_outlined,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Rekap per Dusun'),
                  const SizedBox(height: 10),
                  if (_perDusun.isEmpty)
                    _emptyState('Belum ada data dusun')
                  else
                    ..._perDusun.entries.map((e) {
                      final dusun = e.key;
                      final data = e.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_city_rounded, color: _primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dusun,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${data['kk']} KK • ${data['jiwa']} Jiwa • ${data['balita']} Balita',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${data['kk']}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFEA580C), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Data ini otomatis terisi dari input kader. Setelah disetujui Admin Desa, akan masuk ke rekap kabupaten.',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF9A3412), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _darkText,
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: _darkText, height: 1)),
              const SizedBox(height: 2),
              Text(label, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCardSmall(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: color, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _statCardBig(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: _darkText, height: 1)),
                const SizedBox(height: 2),
                Text(label, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: const Color(0xFF94A3B8).withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Text(msg, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}