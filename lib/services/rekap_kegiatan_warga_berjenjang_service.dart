// lib/services/rekap_kegiatan_warga_berjenjang_service.dart
// Service penyimpanan data rekap berjenjang catatan data dan kegiatan warga (RT, RW, Dusun, Desa, Kecamatan)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rekap_kegiatan_warga_berjenjang.dart';
import '../services/data_keluarga_dasawisma_service.dart';

class RekapKegiatanWargaBerjenjangService {
  static final RekapKegiatanWargaBerjenjangService _instance =
      RekapKegiatanWargaBerjenjangService._internal();
  factory RekapKegiatanWargaBerjenjangService() => _instance;
  RekapKegiatanWargaBerjenjangService._internal();

  static const String _prefKey = 'rekap_kegiatan_warga_berjenjang_v1';
  List<RekapKegiatanWargaBerjenjangItem> _cache = [];
  bool _initialized = false;

  final List<RekapKegiatanWargaBerjenjangItem> _initialDemoData = [
    // 1. TINGKAT RT (Gambar 1: Kelompok PKK RT - pengenal baris: Nama DasaWisma)
    RekapKegiatanWargaBerjenjangItem(
      id: 201,
      level: 'rt',
      tahun: '2026',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      dasaWisma: 'Mawar 01',
      namaDasawisma: 'Mawar 01',
      jumlahKrt: 10,
      jumlahKk: 12,
      totalL: 22,
      totalP: 24,
      balitaL: 3,
      balitaP: 2,
      pus: 8,
      wus: 9,
      ibuHamil: 2,
      ibuMenyusui: 3,
      lansia: 4,
      butaL: 0,
      butaP: 0,
      berkebutuhanKhusus: 0,
      rumahSehat: 9,
      rumahTidakSehat: 1,
      tempatSampah: 8,
      spal: 8,
      jambanMck: 10,
      airPdam: 4,
      airSumur: 6,
      airSungai: 0,
      airDll: 0,
      makananBeras: 10,
      makananNonBeras: 0,
      kegiatanUp2k: 3,
      kegiatanPekarangan: 5,
      kegiatanIndustriRt: 2,
      kegiatanKesling: 10,
      keterangan: 'Aktif gotong royong',
    ),
    RekapKegiatanWargaBerjenjangItem(
      id: 202,
      level: 'rt',
      tahun: '2026',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      dasaWisma: 'Mawar 02',
      namaDasawisma: 'Mawar 02',
      jumlahKrt: 8,
      jumlahKk: 9,
      totalL: 18,
      totalP: 19,
      balitaL: 2,
      balitaP: 1,
      pus: 6,
      wus: 7,
      ibuHamil: 1,
      ibuMenyusui: 2,
      lansia: 3,
      butaL: 0,
      butaP: 0,
      berkebutuhanKhusus: 0,
      rumahSehat: 8,
      rumahTidakSehat: 0,
      tempatSampah: 7,
      spal: 7,
      jambanMck: 8,
      airPdam: 5,
      airSumur: 3,
      airSungai: 0,
      airDll: 0,
      makananBeras: 8,
      makananNonBeras: 0,
      kegiatanUp2k: 2,
      kegiatanPekarangan: 4,
      kegiatanIndustriRt: 1,
      kegiatanKesling: 8,
      keterangan: 'Pekarangan tertata rapi',
    ),

    // 2. TINGKAT RW (Gambar 2: Kelompok PKK RW - pengenal: Nomor RT, Jumlah Dasa Wisma)
    RekapKegiatanWargaBerjenjangItem(
      id: 203,
      level: 'rw',
      tahun: '2026',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      nomorRt: '01',
      jumlahDasawisma: 2,
      jumlahKrt: 18,
      jumlahKk: 21,
      totalL: 40,
      totalP: 43,
      balitaL: 5,
      balitaP: 3,
      pus: 14,
      wus: 16,
      ibuHamil: 3,
      ibuMenyusui: 5,
      lansia: 7,
      butaL: 0,
      butaP: 0,
      berkebutuhanKhusus: 0,
      rumahSehat: 17,
      rumahTidakSehat: 1,
      tempatSampah: 15,
      spal: 15,
      jambanMck: 18,
      airPdam: 9,
      airSumur: 9,
      airSungai: 0,
      airDll: 0,
      makananBeras: 18,
      makananNonBeras: 0,
      kegiatanUp2k: 5,
      kegiatanPekarangan: 9,
      kegiatanIndustriRt: 3,
      kegiatanKesling: 18,
      keterangan: 'Rekapitulasi RT 01',
    ),

    // 3. TINGKAT DUSUN (Gambar 3: Kelompok PKK Dusun - pengenal: Nomor RW, Jumlah RT, Jumlah Dasawisma)
    RekapKegiatanWargaBerjenjangItem(
      id: 204,
      level: 'dusun',
      tahun: '2026',
      rt: '01',
      rw: '05',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      nomorRw: '05',
      jumlahRt: 4,
      jumlahDasawisma: 8,
      jumlahKrt: 72,
      jumlahKk: 84,
      totalL: 160,
      totalP: 172,
      balitaL: 20,
      balitaP: 12,
      pus: 56,
      wus: 64,
      ibuHamil: 12,
      ibuMenyusui: 20,
      lansia: 28,
      butaL: 0,
      butaP: 0,
      berkebutuhanKhusus: 1,
      rumahSehat: 68,
      rumahTidakSehat: 4,
      tempatSampah: 60,
      spal: 60,
      jambanMck: 72,
      airPdam: 36,
      airSumur: 36,
      airSungai: 0,
      airDll: 0,
      makananBeras: 72,
      makananNonBeras: 0,
      kegiatanUp2k: 20,
      kegiatanPekarangan: 36,
      kegiatanIndustriRt: 12,
      kegiatanKesling: 72,
      keterangan: 'Rekap RW 05 Dusun Cikunir',
    ),

    // 4. TINGKAT DESA (Gambar 4: TP PKK Desa - pengenal: Nama Dusun, Jumlah RW, Jumlah RT, Jumlah Dasawisma)
    RekapKegiatanWargaBerjenjangItem(
      id: 205,
      level: 'desa',
      tahun: '2026',
      dusun: 'Cikunir',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      namaDusun: 'Cikunir',
      jumlahRw: 2,
      jumlahRt: 8,
      jumlahDasawisma: 16,
      jumlahKrt: 144,
      jumlahKk: 168,
      totalL: 320,
      totalP: 344,
      balitaL: 40,
      balitaP: 24,
      pus: 112,
      wus: 128,
      ibuHamil: 24,
      ibuMenyusui: 40,
      lansia: 56,
      butaL: 0,
      butaP: 0,
      berkebutuhanKhusus: 2,
      rumahSehat: 136,
      rumahTidakSehat: 8,
      tempatSampah: 120,
      spal: 120,
      jambanMck: 144,
      airPdam: 72,
      airSumur: 72,
      airSungai: 0,
      airDll: 0,
      makananBeras: 144,
      makananNonBeras: 0,
      kegiatanUp2k: 40,
      kegiatanPekarangan: 72,
      kegiatanIndustriRt: 24,
      kegiatanKesling: 144,
      keterangan: 'Kondisi umum dusun Cikunir sehat',
    ),

    // 5. TINGKAT KECAMATAN (Gambar 5: TP PKK Kecamatan - pengenal: Nama Desa, Jumlah Dusun, Jumlah RW, Jumlah RT, Jumlah Dasawisma)
    RekapKegiatanWargaBerjenjangItem(
      id: 206,
      level: 'kecamatan',
      tahun: '2026',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      namaDesa: 'Singaparna',
      jumlahDusun: 4,
      jumlahRw: 8,
      jumlahRt: 32,
      jumlahDasawisma: 64,
      jumlahKrt: 576,
      jumlahKk: 672,
      totalL: 1280,
      totalP: 1376,
      balitaL: 160,
      balitaP: 96,
      pus: 448,
      wus: 512,
      ibuHamil: 96,
      ibuMenyusui: 160,
      lansia: 224,
      butaL: 0,
      butaP: 0,
      berkebutuhanKhusus: 5,
      rumahSehat: 544,
      rumahTidakSehat: 32,
      tempatSampah: 480,
      spal: 480,
      jambanMck: 576,
      airPdam: 288,
      airSumur: 288,
      airSungai: 0,
      airDll: 0,
      makananBeras: 576,
      makananNonBeras: 0,
      kegiatanUp2k: 160,
      kegiatanPekarangan: 288,
      kegiatanIndustriRt: 96,
      kegiatanKesling: 576,
      keterangan: 'Rekap Desa Singaparna',
    ),
  ];

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      try {
        final List list = jsonDecode(raw);
        _cache = list.map((e) => RekapKegiatanWargaBerjenjangItem.fromJson(e)).toList();
      } catch (_) {
        _cache = List.from(_initialDemoData);
      }
    } else {
      _cache = List.from(_initialDemoData);
      await _persist();
    }
    _initialized = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, raw);
  }

  Future<List<RekapKegiatanWargaBerjenjangItem>> getByLevel(String level) async {
    await _init();
    return _cache.where((e) => e.level.toLowerCase() == level.toLowerCase()).toList();
  }

  Future<RekapKegiatanWargaBerjenjangItem?> getById(int id) async {
    await _init();
    try {
      return _cache.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(RekapKegiatanWargaBerjenjangItem item) async {
    await _init();
    final idx = _cache.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _cache[idx] = item;
    } else {
      final newId = DateTime.now().millisecondsSinceEpoch;
      _cache.insert(0, item.copyWith(id: newId));
    }
    await _persist();
  }

  Future<void> delete(int id) async {
    await _init();
    _cache.removeWhere((e) => e.id == id);
    await _persist();
  }

  /// Fitur Hitung Otomatis dari Binaan Dasawisma (Gambar 1 / DataKeluargaDasawisma)
  Future<RekapKegiatanWargaBerjenjangItem> autoGenerateFromDasawisma(String level) async {
    await _init();
    final dasawismaService = DataKeluargaDasawismaService();
    final allDasawisma = await dasawismaService.getAll();

    int krt = allDasawisma.length;
    int kk = 0;
    int l = 0;
    int p = 0;
    int balitaL = 0;
    int balitaP = 0;
    int pus = 0;
    int wus = 0;
    int bumil = 0;
    int busui = 0;
    int lansia = 0;
    int butaL = 0;
    int butaP = 0;
    int berkebutuhanKhusus = 0;

    for (var item in allDasawisma) {
      kk += item.jumlahKk;
      l += item.jumlahLakiLaki;
      p += item.jumlahPerempuan;
      pus += item.jumlahPus;
      wus += item.jumlahWus;
      bumil += item.jumlahIbuHamil;
      busui += item.jumlahIbuMenyusui;
      lansia += item.jumlahLansia;
      
      // Balita estimasi L/P dari data
      int totalBalita = item.jumlahBalita;
      balitaL += (totalBalita / 2).ceil();
      balitaP += (totalBalita / 2).floor();

      // 3 Buta
      int totalButa = item.jumlahTigaButa;
      butaL += (totalButa / 2).ceil();
      butaP += (totalButa / 2).floor();
    }

    final first = allDasawisma.isNotEmpty ? allDasawisma.first : null;

    final newItem = RekapKegiatanWargaBerjenjangItem(
      id: DateTime.now().millisecondsSinceEpoch,
      level: level,
      tahun: '2026',
      rt: first?.rt ?? '01',
      rw: first?.rw ?? '05',
      desa: first?.desa ?? 'Singaparna',
      kecamatan: first?.kecamatan ?? 'Singaparna',
      kabupaten: first?.kabupaten ?? 'Tasikmalaya',
      provinsi: first?.provinsi ?? 'Jawa Barat',
      dasaWisma: first?.dasaWisma ?? 'Mawar 01',
      namaDasawisma: first?.dasaWisma ?? 'Mawar 01',
      nomorRt: first?.rt ?? '01',
      nomorRw: first?.rw ?? '05',
      namaDusun: 'Cikunir',
      namaDesa: first?.desa ?? 'Singaparna',
      jumlahDusun: 1,
      jumlahRw: 1,
      jumlahRt: 1,
      jumlahDasawisma: allDasawisma.isNotEmpty ? 1 : 0,
      jumlahKrt: krt,
      jumlahKk: kk,
      totalL: l,
      totalP: p,
      balitaL: balitaL,
      balitaP: balitaP,
      pus: pus,
      wus: wus,
      ibuHamil: bumil,
      ibuMenyusui: busui,
      lansia: lansia,
      butaL: butaL,
      butaP: butaP,
      berkebutuhanKhusus: berkebutuhanKhusus,
      rumahSehat: krt > 0 ? (krt * 0.9).round() : 0,
      rumahTidakSehat: krt > 0 ? (krt * 0.1).round() : 0,
      tempatSampah: krt > 0 ? (krt * 0.85).round() : 0,
      spal: krt > 0 ? (krt * 0.85).round() : 0,
      jambanMck: krt,
      airPdam: krt > 0 ? (krt * 0.5).round() : 0,
      airSumur: krt > 0 ? (krt * 0.5).round() : 0,
      airSungai: 0,
      airDll: 0,
      makananBeras: krt,
      makananNonBeras: 0,
      kegiatanUp2k: krt > 0 ? (krt * 0.3).round() : 0,
      kegiatanPekarangan: krt > 0 ? (krt * 0.5).round() : 0,
      kegiatanIndustriRt: krt > 0 ? (krt * 0.2).round() : 0,
      kegiatanKesling: krt,
      keterangan: 'Ditarik otomatis dari data Dasawisma',
    );

    _cache.insert(0, newItem);
    await _persist();
    return newItem;
  }
}
