// lib/services/rekap_bumil_berjenjang_service.dart
// Service penyimpanan data form rekap berjenjang bumil & bayi (RT, RW, Dusun, Desa, Kecamatan)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rekap_bumil_berjenjang.dart';
import '../services/rekap_ibu_anak_service.dart';

class RekapBumilBerjenjangService {
  static final RekapBumilBerjenjangService _instance = RekapBumilBerjenjangService._internal();
  factory RekapBumilBerjenjangService() => _instance;
  RekapBumilBerjenjangService._internal();

  static const String _prefKey = 'rekap_bumil_berjenjang_v1';
  List<RekapBumilBerjenjangItem> _cache = [];
  bool _initialized = false;

  final List<RekapBumilBerjenjangItem> _initialDemoData = [
    // 1. TINGKAT RT (15 Kolom)
    RekapBumilBerjenjangItem(
      id: 101,
      level: 'rt',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaDasawisma: 'Mawar 01',
      ibuHamil: 3,
      ibuMelahirkan: 2,
      ibuNifas: 1,
      ibuMeninggal: 0,
      bayiLahirL: 1,
      bayiLahirP: 1,
      akteAda: 2,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: 'Kondisi bumil terpantau sehat',
    ),
    RekapBumilBerjenjangItem(
      id: 102,
      level: 'rt',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaDasawisma: 'Mawar 02',
      ibuHamil: 2,
      ibuMelahirkan: 1,
      ibuNifas: 1,
      ibuMeninggal: 0,
      bayiLahirL: 1,
      bayiLahirP: 0,
      akteAda: 1,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '1 proses akta kelahiran',
    ),

    // 2. TINGKAT RW (16 Kolom)
    RekapBumilBerjenjangItem(
      id: 201,
      level: 'rw',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      nomorRt: '01',
      namaDasawisma: 'Mawar 01',
      ibuHamil: 3,
      ibuMelahirkan: 2,
      ibuNifas: 1,
      ibuMeninggal: 0,
      bayiLahirL: 1,
      bayiLahirP: 1,
      akteAda: 2,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),
    RekapBumilBerjenjangItem(
      id: 202,
      level: 'rw',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      nomorRt: '02',
      namaDasawisma: 'Mawar 02',
      ibuHamil: 2,
      ibuMelahirkan: 1,
      ibuNifas: 1,
      ibuMeninggal: 0,
      bayiLahirL: 1,
      bayiLahirP: 0,
      akteAda: 1,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),

    // 3. TINGKAT DUSUN/LINGKUNGAN (17 Kolom)
    RekapBumilBerjenjangItem(
      id: 301,
      level: 'dusun',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      nomorRw: '01',
      jumlahRt: 4,
      jumlahDasawisma: 8,
      ibuHamil: 5,
      ibuMelahirkan: 3,
      ibuNifas: 2,
      ibuMeninggal: 0,
      bayiLahirL: 2,
      bayiLahirP: 1,
      akteAda: 3,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),
    RekapBumilBerjenjangItem(
      id: 302,
      level: 'dusun',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      nomorRw: '05',
      jumlahRt: 3,
      jumlahDasawisma: 6,
      ibuHamil: 4,
      ibuMelahirkan: 2,
      ibuNifas: 1,
      ibuMeninggal: 0,
      bayiLahirL: 1,
      bayiLahirP: 1,
      akteAda: 2,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),

    // 4. TINGKAT TP PKK DESA (18 Kolom)
    RekapBumilBerjenjangItem(
      id: 401,
      level: 'desa',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaDusun: 'Cikunir',
      jumlahRw: 5,
      jumlahRt: 18,
      jumlahDasawisma: 36,
      ibuHamil: 9,
      ibuMelahirkan: 5,
      ibuNifas: 3,
      ibuMeninggal: 0,
      bayiLahirL: 3,
      bayiLahirP: 2,
      akteAda: 5,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),
    RekapBumilBerjenjangItem(
      id: 402,
      level: 'desa',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaDusun: 'Sukasenang',
      jumlahRw: 4,
      jumlahRt: 14,
      jumlahDasawisma: 28,
      ibuHamil: 7,
      ibuMelahirkan: 4,
      ibuNifas: 2,
      ibuMeninggal: 0,
      bayiLahirL: 2,
      bayiLahirP: 2,
      akteAda: 4,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),

    // 5. TINGKAT TP PKK KECAMATAN (19 Kolom)
    RekapBumilBerjenjangItem(
      id: 501,
      level: 'kecamatan',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaDesa: 'Singaparna',
      jumlahDusun: 4,
      jumlahRw: 12,
      jumlahRt: 45,
      jumlahDasawisma: 90,
      ibuHamil: 16,
      ibuMelahirkan: 9,
      ibuNifas: 5,
      ibuMeninggal: 0,
      bayiLahirL: 5,
      bayiLahirP: 4,
      akteAda: 9,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),
    RekapBumilBerjenjangItem(
      id: 502,
      level: 'kecamatan',
      kecamatan: 'Singaparna',
      bulan: 'September',
      tahun: '2026',
      namaDesa: 'Sukamaju',
      jumlahDusun: 3,
      jumlahRw: 9,
      jumlahRt: 32,
      jumlahDasawisma: 64,
      ibuHamil: 12,
      ibuMelahirkan: 6,
      ibuNifas: 4,
      ibuMeninggal: 0,
      bayiLahirL: 3,
      bayiLahirP: 3,
      akteAda: 6,
      akteTidakAda: 0,
      bayiMeninggalL: 0,
      bayiMeninggalP: 0,
      balitaMeninggalL: 0,
      balitaMeninggalP: 0,
      keterangan: '',
    ),
  ];

  Future<void> _init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_prefKey);
      if (str != null && str.isNotEmpty) {
        final List list = jsonDecode(str);
        _cache = list.map((e) => RekapBumilBerjenjangItem.fromJson(e)).toList();
      } else {
        _cache = List.from(_initialDemoData);
        await _persist();
      }
    } catch (_) {
      _cache = List.from(_initialDemoData);
    }
    _initialized = true;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(_cache.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, str);
    } catch (_) {}
  }

  Future<List<RekapBumilBerjenjangItem>> getByLevel(String level) async {
    await _init();
    return _cache.where((e) => e.level == level).toList();
  }

  Future<void> save(RekapBumilBerjenjangItem item) async {
    await _init();
    final idx = _cache.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _cache[idx] = item;
    } else {
      final newId = DateTime.now().millisecondsSinceEpoch;
      _cache.add(item.copyWith(id: newId));
    }
    await _persist();
  }

  Future<void> delete(int id) async {
    await _init();
    _cache.removeWhere((e) => e.id == id);
    await _persist();
  }

  // Tarik & Hitung Otomatis dari Input Buku Catatan Ibu & Anak Dasawisma
  Future<void> autoGenerateFromDasawisma(String level) async {
    await _init();
    final rawDasawisma = await RekapIbuAnakService().getAll();
    if (rawDasawisma.isEmpty) return;

    // Remove existing rows for this level before recreating
    _cache.removeWhere((e) => e.level == level);

    if (level == 'rt') {
      // Group by kelompok dasawisma
      final Map<String, List> groups = {};
      for (var d in rawDasawisma) {
        final k = d.kelompokDasaWisma.isNotEmpty ? d.kelompokDasaWisma : 'Dasawisma';
        groups.putIfAbsent(k, () => []).add(d);
      }
      groups.forEach((dasa, list) {
        int hamil = 0, melahirkan = 0, nifas = 0, ibuMeninggal = 0;
        int lahirL = 0, lahirP = 0, aktaAda = 0, aktaTidak = 0;
        int matiBayiL = 0, matiBayiP = 0, matiBalitaL = 0, matiBalitaP = 0;
        for (var e in list) {
          final s = e.statusIbu.toLowerCase();
          if (s.contains('hamil')) hamil++;
          if (s.contains('lahir')) melahirkan++;
          if (s.contains('nifas')) nifas++;
          if (e.adaKelahiran) {
            if (e.jenisKelaminBayi == 'L') lahirL++; else lahirP++;
            if (e.hasAktaKelahiran) aktaAda++; else aktaTidak++;
          }
          if (e.adaKematian) {
            final sm = e.statusMeninggal.toLowerCase();
            if (sm.contains('ibu')) ibuMeninggal++;
            if (sm.contains('bayi')) {
              if (e.jenisKelaminMeninggal == 'L') matiBayiL++; else matiBayiP++;
            }
            if (sm.contains('balita')) {
              if (e.jenisKelaminMeninggal == 'L') matiBalitaL++; else matiBalitaP++;
            }
          }
        }
        _cache.add(RekapBumilBerjenjangItem(
          id: DateTime.now().millisecondsSinceEpoch + _cache.length,
          level: 'rt',
          rt: list.first.rt,
          rw: list.first.rw,
          dusun: list.first.dusun,
          desa: list.first.desa,
          namaDasawisma: dasa,
          ibuHamil: hamil,
          ibuMelahirkan: melahirkan,
          ibuNifas: nifas,
          ibuMeninggal: ibuMeninggal,
          bayiLahirL: lahirL,
          bayiLahirP: lahirP,
          akteAda: aktaAda,
          akteTidakAda: aktaTidak,
          bayiMeninggalL: matiBayiL,
          bayiMeninggalP: matiBayiP,
          balitaMeninggalL: matiBalitaL,
          balitaMeninggalP: matiBalitaP,
          keterangan: 'Otomatis dari Dasawisma',
        ));
      });
    } else if (level == 'rw') {
      // Group by RT & dasawisma
      final Map<String, List> groups = {};
      for (var d in rawDasawisma) {
        final k = 'RT ${d.rt} - ${d.kelompokDasaWisma}';
        groups.putIfAbsent(k, () => []).add(d);
      }
      groups.forEach((key, list) {
        int hamil = 0, melahirkan = 0, nifas = 0, ibuMeninggal = 0;
        int lahirL = 0, lahirP = 0, aktaAda = 0, aktaTidak = 0;
        int matiBayiL = 0, matiBayiP = 0, matiBalitaL = 0, matiBalitaP = 0;
        for (var e in list) {
          final s = e.statusIbu.toLowerCase();
          if (s.contains('hamil')) hamil++;
          if (s.contains('lahir')) melahirkan++;
          if (s.contains('nifas')) nifas++;
          if (e.adaKelahiran) {
            if (e.jenisKelaminBayi == 'L') lahirL++; else lahirP++;
            if (e.hasAktaKelahiran) aktaAda++; else aktaTidak++;
          }
          if (e.adaKematian) {
            final sm = e.statusMeninggal.toLowerCase();
            if (sm.contains('ibu')) ibuMeninggal++;
            if (sm.contains('bayi')) {
              if (e.jenisKelaminMeninggal == 'L') matiBayiL++; else matiBayiP++;
            }
            if (sm.contains('balita')) {
              if (e.jenisKelaminMeninggal == 'L') matiBalitaL++; else matiBalitaP++;
            }
          }
        }
        _cache.add(RekapBumilBerjenjangItem(
          id: DateTime.now().millisecondsSinceEpoch + _cache.length,
          level: 'rw',
          nomorRt: list.first.rt,
          namaDasawisma: list.first.kelompokDasaWisma,
          rw: list.first.rw,
          dusun: list.first.dusun,
          desa: list.first.desa,
          ibuHamil: hamil,
          ibuMelahirkan: melahirkan,
          ibuNifas: nifas,
          ibuMeninggal: ibuMeninggal,
          bayiLahirL: lahirL,
          bayiLahirP: lahirP,
          akteAda: aktaAda,
          akteTidakAda: aktaTidak,
          bayiMeninggalL: matiBayiL,
          bayiMeninggalP: matiBayiP,
          balitaMeninggalL: matiBalitaL,
          balitaMeninggalP: matiBalitaP,
          keterangan: 'Otomatis dari Dasawisma',
        ));
      });
    } else if (level == 'dusun') {
      // Group by RW
      final Map<String, List> groups = {};
      for (var d in rawDasawisma) {
        final k = d.rw.isNotEmpty ? d.rw : '01';
        groups.putIfAbsent(k, () => []).add(d);
      }
      groups.forEach((rwNum, list) {
        final rtSet = list.map((e) => e.rt).toSet();
        final dasaSet = list.map((e) => e.kelompokDasaWisma).toSet();
        int hamil = 0, melahirkan = 0, nifas = 0, ibuMeninggal = 0;
        int lahirL = 0, lahirP = 0, aktaAda = 0, aktaTidak = 0;
        int matiBayiL = 0, matiBayiP = 0, matiBalitaL = 0, matiBalitaP = 0;
        for (var e in list) {
          final s = e.statusIbu.toLowerCase();
          if (s.contains('hamil')) hamil++;
          if (s.contains('lahir')) melahirkan++;
          if (s.contains('nifas')) nifas++;
          if (e.adaKelahiran) {
            if (e.jenisKelaminBayi == 'L') lahirL++; else lahirP++;
            if (e.hasAktaKelahiran) aktaAda++; else aktaTidak++;
          }
          if (e.adaKematian) {
            final sm = e.statusMeninggal.toLowerCase();
            if (sm.contains('ibu')) ibuMeninggal++;
            if (sm.contains('bayi')) {
              if (e.jenisKelaminMeninggal == 'L') matiBayiL++; else matiBayiP++;
            }
            if (sm.contains('balita')) {
              if (e.jenisKelaminMeninggal == 'L') matiBalitaL++; else matiBalitaP++;
            }
          }
        }
        _cache.add(RekapBumilBerjenjangItem(
          id: DateTime.now().millisecondsSinceEpoch + _cache.length,
          level: 'dusun',
          nomorRw: rwNum,
          jumlahRt: rtSet.length,
          jumlahDasawisma: dasaSet.length,
          dusun: list.first.dusun,
          desa: list.first.desa,
          ibuHamil: hamil,
          ibuMelahirkan: melahirkan,
          ibuNifas: nifas,
          ibuMeninggal: ibuMeninggal,
          bayiLahirL: lahirL,
          bayiLahirP: lahirP,
          akteAda: aktaAda,
          akteTidakAda: aktaTidak,
          bayiMeninggalL: matiBayiL,
          bayiMeninggalP: matiBayiP,
          balitaMeninggalL: matiBalitaL,
          balitaMeninggalP: matiBalitaP,
          keterangan: 'Otomatis dari Dasawisma',
        ));
      });
    } else if (level == 'desa') {
      // Group by Dusun
      final Map<String, List> groups = {};
      for (var d in rawDasawisma) {
        final k = d.dusun.isNotEmpty ? d.dusun : 'Cikunir';
        groups.putIfAbsent(k, () => []).add(d);
      }
      groups.forEach((dusunName, list) {
        final rwSet = list.map((e) => e.rw).toSet();
        final rtSet = list.map((e) => e.rt).toSet();
        final dasaSet = list.map((e) => e.kelompokDasaWisma).toSet();
        int hamil = 0, melahirkan = 0, nifas = 0, ibuMeninggal = 0;
        int lahirL = 0, lahirP = 0, aktaAda = 0, aktaTidak = 0;
        int matiBayiL = 0, matiBayiP = 0, matiBalitaL = 0, matiBalitaP = 0;
        for (var e in list) {
          final s = e.statusIbu.toLowerCase();
          if (s.contains('hamil')) hamil++;
          if (s.contains('lahir')) melahirkan++;
          if (s.contains('nifas')) nifas++;
          if (e.adaKelahiran) {
            if (e.jenisKelaminBayi == 'L') lahirL++; else lahirP++;
            if (e.hasAktaKelahiran) aktaAda++; else aktaTidak++;
          }
          if (e.adaKematian) {
            final sm = e.statusMeninggal.toLowerCase();
            if (sm.contains('ibu')) ibuMeninggal++;
            if (sm.contains('bayi')) {
              if (e.jenisKelaminMeninggal == 'L') matiBayiL++; else matiBayiP++;
            }
            if (sm.contains('balita')) {
              if (e.jenisKelaminMeninggal == 'L') matiBalitaL++; else matiBalitaP++;
            }
          }
        }
        _cache.add(RekapBumilBerjenjangItem(
          id: DateTime.now().millisecondsSinceEpoch + _cache.length,
          level: 'desa',
          namaDusun: dusunName,
          jumlahRw: rwSet.length,
          jumlahRt: rtSet.length,
          jumlahDasawisma: dasaSet.length,
          desa: list.first.desa,
          ibuHamil: hamil,
          ibuMelahirkan: melahirkan,
          ibuNifas: nifas,
          ibuMeninggal: ibuMeninggal,
          bayiLahirL: lahirL,
          bayiLahirP: lahirP,
          akteAda: aktaAda,
          akteTidakAda: aktaTidak,
          bayiMeninggalL: matiBayiL,
          bayiMeninggalP: matiBayiP,
          balitaMeninggalL: matiBalitaL,
          balitaMeninggalP: matiBalitaP,
          keterangan: 'Otomatis dari Dasawisma',
        ));
      });
    } else if (level == 'kecamatan') {
      // Group by Desa
      final Map<String, List> groups = {};
      for (var d in rawDasawisma) {
        final k = d.desa.isNotEmpty ? d.desa : 'Singaparna';
        groups.putIfAbsent(k, () => []).add(d);
      }
      groups.forEach((desaName, list) {
        final dusunSet = list.map((e) => e.dusun).toSet();
        final rwSet = list.map((e) => e.rw).toSet();
        final rtSet = list.map((e) => e.rt).toSet();
        final dasaSet = list.map((e) => e.kelompokDasaWisma).toSet();
        int hamil = 0, melahirkan = 0, nifas = 0, ibuMeninggal = 0;
        int lahirL = 0, lahirP = 0, aktaAda = 0, aktaTidak = 0;
        int matiBayiL = 0, matiBayiP = 0, matiBalitaL = 0, matiBalitaP = 0;
        for (var e in list) {
          final s = e.statusIbu.toLowerCase();
          if (s.contains('hamil')) hamil++;
          if (s.contains('lahir')) melahirkan++;
          if (s.contains('nifas')) nifas++;
          if (e.adaKelahiran) {
            if (e.jenisKelaminBayi == 'L') lahirL++; else lahirP++;
            if (e.hasAktaKelahiran) aktaAda++; else aktaTidak++;
          }
          if (e.adaKematian) {
            final sm = e.statusMeninggal.toLowerCase();
            if (sm.contains('ibu')) ibuMeninggal++;
            if (sm.contains('bayi')) {
              if (e.jenisKelaminMeninggal == 'L') matiBayiL++; else matiBayiP++;
            }
            if (sm.contains('balita')) {
              if (e.jenisKelaminMeninggal == 'L') matiBalitaL++; else matiBalitaP++;
            }
          }
        }
        _cache.add(RekapBumilBerjenjangItem(
          id: DateTime.now().millisecondsSinceEpoch + _cache.length,
          level: 'kecamatan',
          namaDesa: desaName,
          jumlahDusun: dusunSet.length,
          jumlahRw: rwSet.length,
          jumlahRt: rtSet.length,
          jumlahDasawisma: dasaSet.length,
          ibuHamil: hamil,
          ibuMelahirkan: melahirkan,
          ibuNifas: nifas,
          ibuMeninggal: ibuMeninggal,
          bayiLahirL: lahirL,
          bayiLahirP: lahirP,
          akteAda: aktaAda,
          akteTidakAda: aktaTidak,
          bayiMeninggalL: matiBayiL,
          bayiMeninggalP: matiBayiP,
          balitaMeninggalL: matiBalitaL,
          balitaMeninggalP: matiBalitaP,
          keterangan: 'Otomatis dari Dasawisma',
        ));
      });
    }

    await _persist();
  }
}
