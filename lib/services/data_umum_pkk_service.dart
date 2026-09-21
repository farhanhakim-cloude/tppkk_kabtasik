// lib/services/data_umum_pkk_service.dart
// Service penyimpanan lokal dan kalkulasi otomatis Data Umum PKK Tingkat Desa & Kecamatan

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_umum_pkk.dart';
import '../models/rekap_kegiatan_warga_berjenjang.dart';
import 'rekap_kegiatan_warga_berjenjang_service.dart';

class DataUmumPkkService {
  static final DataUmumPkkService _instance = DataUmumPkkService._internal();
  factory DataUmumPkkService() => _instance;
  DataUmumPkkService._internal();

  static const String _prefKey = 'data_umum_pkk_desa_kecamatan_v1';
  List<DataUmumPkkItem> _cache = [];
  bool _initialized = false;

  final List<DataUmumPkkItem> _initialDemoData = [
    // Data Default Tingkat Desa (Format Gambar 1: Kolom Pengenal = Nama Dusun)
    DataUmumPkkItem(
      id: 101,
      level: 'desa',
      tahun: '2026',
      kabupaten: 'TASIKMALAYA',
      provinsi: 'JAWA BARAT',
      kecamatan: 'Singaparna',
      desa: 'Singaparna',
      namaDusun: 'Dusun Cikunir',
      jumlahPkkRw: 4,
      jumlahPkkRt: 12,
      jumlahDasaWisma: 24,
      jumlahKrt: 190,
      jumlahKk: 215,
      jiwaL: 420,
      jiwaP: 435,
      kaderTpPkkL: 2,
      kaderTpPkkP: 18,
      kaderUmumL: 4,
      kaderUmumP: 22,
      kaderKhususL: 1,
      kaderKhususP: 8,
      sekretariatHonorerL: 1,
      sekretariatHonorerP: 2,
      sekretariatBantuanL: 0,
      sekretariatBantuanP: 1,
      keterangan: 'Kelompok Dasawisma sangat aktif',
    ),
    DataUmumPkkItem(
      id: 102,
      level: 'desa',
      tahun: '2026',
      kabupaten: 'TASIKMALAYA',
      provinsi: 'JAWA BARAT',
      kecamatan: 'Singaparna',
      desa: 'Singaparna',
      namaDusun: 'Dusun Sukamaju',
      jumlahPkkRw: 3,
      jumlahPkkRt: 9,
      jumlahDasaWisma: 18,
      jumlahKrt: 150,
      jumlahKk: 168,
      jiwaL: 330,
      jiwaP: 345,
      kaderTpPkkL: 1,
      kaderTpPkkP: 14,
      kaderUmumL: 3,
      kaderUmumP: 17,
      kaderKhususL: 1,
      kaderKhususP: 6,
      sekretariatHonorerL: 1,
      sekretariatHonorerP: 1,
      sekretariatBantuanL: 0,
      sekretariatBantuanP: 1,
      keterangan: 'Pemanfaatan pekarangan optimal',
    ),

    // Data Default Tingkat Kecamatan (Format Gambar 2: Kolom Pengenal = Nama Desa)
    DataUmumPkkItem(
      id: 201,
      level: 'kecamatan',
      tahun: '2026',
      kabupaten: 'TASIKMALAYA',
      provinsi: 'JAWA BARAT',
      kecamatan: 'Singaparna',
      namaDesa: 'Desa Singaparna',
      jumlahDusun: 4,
      jumlahPkkRw: 14,
      jumlahPkkRt: 42,
      jumlahDasaWisma: 84,
      jumlahKrt: 680,
      jumlahKk: 760,
      jiwaL: 1510,
      jiwaP: 1560,
      kaderTpPkkL: 5,
      kaderTpPkkP: 64,
      kaderUmumL: 14,
      kaderUmumP: 78,
      kaderKhususL: 4,
      kaderKhususP: 28,
      sekretariatHonorerL: 2,
      sekretariatHonorerP: 4,
      sekretariatBantuanL: 1,
      sekretariatBantuanP: 2,
      keterangan: 'Ibu Kota Kecamatan',
    ),
    DataUmumPkkItem(
      id: 202,
      level: 'kecamatan',
      tahun: '2026',
      kabupaten: 'TASIKMALAYA',
      provinsi: 'JAWA BARAT',
      kecamatan: 'Singaparna',
      namaDesa: 'Desa Cintaraja',
      jumlahDusun: 3,
      jumlahPkkRw: 10,
      jumlahPkkRt: 30,
      jumlahDasaWisma: 60,
      jumlahKrt: 490,
      jumlahKk: 540,
      jiwaL: 1100,
      jiwaP: 1150,
      kaderTpPkkL: 3,
      kaderTpPkkP: 45,
      kaderUmumL: 10,
      kaderUmumP: 55,
      kaderKhususL: 3,
      kaderKhususP: 20,
      sekretariatHonorerL: 1,
      sekretariatHonorerP: 3,
      sekretariatBantuanL: 0,
      sekretariatBantuanP: 2,
      keterangan: 'UP2K dan Posyandu Mandiri',
    ),
  ];

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _cache = list.map((e) => DataUmumPkkItem.fromJson(e)).toList();
      } catch (_) {
        _cache = List.from(_initialDemoData);
        await _save();
      }
    } else {
      _cache = List.from(_initialDemoData);
      await _save();
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, raw);
  }

  Future<List<DataUmumPkkItem>> getByLevel(String level) async {
    await _init();
    return _cache.where((e) => e.level == level).toList();
  }

  Future<void> save(DataUmumPkkItem item) async {
    await _init();
    final idx = _cache.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _cache[idx] = item;
    } else {
      final newId = item.id != 0
          ? item.id
          : (_cache.isEmpty ? 100 : _cache.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      _cache.insert(0, item.copyWith(id: newId));
    }
    await _save();
  }

  Future<void> delete(int id) async {
    await _init();
    _cache.removeWhere((e) => e.id == id);
    await _save();
  }

  /// Auto-kalkulasi dari data Rekap Kegiatan Warga Berjenjang jika tersedia
  Future<void> autoGenerateFromRekap(String level) async {
    await _init();
    final kegiatanService = RekapKegiatanWargaBerjenjangService();
    final kegiatanList = await kegiatanService.getByLevel(level);

    if (kegiatanList.isEmpty) return;

    for (final k in kegiatanList) {
      final name = level == 'desa'
          ? (k.namaDusun.isNotEmpty ? k.namaDusun : 'Dusun ${k.dusun}')
          : (k.namaDesa.isNotEmpty ? k.namaDesa : 'Desa ${k.desa}');

      final existingIdx = _cache.indexWhere((e) =>
          e.level == level &&
          (level == 'desa' ? e.namaDusun == name : e.namaDesa == name));

      final newItem = DataUmumPkkItem(
        id: existingIdx >= 0 ? _cache[existingIdx].id : DateTime.now().millisecondsSinceEpoch % 100000,
        level: level,
        tahun: k.tahun.isNotEmpty ? k.tahun : '2026',
        kabupaten: k.kabupaten.isNotEmpty ? k.kabupaten : 'TASIKMALAYA',
        provinsi: k.provinsi.isNotEmpty ? k.provinsi : 'JAWA BARAT',
        kecamatan: k.kecamatan.isNotEmpty ? k.kecamatan : 'Singaparna',
        desa: k.desa.isNotEmpty ? k.desa : 'Singaparna',
        namaDusun: level == 'desa' ? name : '',
        namaDesa: level == 'kecamatan' ? name : '',
        jumlahDusun: k.jumlahDusun > 0 ? k.jumlahDusun : (level == 'kecamatan' ? 3 : 0),
        jumlahPkkRw: k.jumlahRw > 0 ? k.jumlahRw : 4,
        jumlahPkkRt: k.jumlahRt > 0 ? k.jumlahRt : 12,
        jumlahDasaWisma: k.jumlahDasawisma > 0 ? k.jumlahDasawisma : 24,
        jumlahKrt: k.jumlahKrt,
        jumlahKk: k.jumlahKk,
        jiwaL: k.totalL,
        jiwaP: k.totalP,
        kaderTpPkkL: 2,
        kaderTpPkkP: 18,
        kaderUmumL: 5,
        kaderUmumP: 25,
        kaderKhususL: 2,
        kaderKhususP: 10,
        sekretariatHonorerL: 1,
        sekretariatHonorerP: 2,
        sekretariatBantuanL: 0,
        sekretariatBantuanP: 1,
        keterangan: 'Auto roll-up dari data kegiatan warga $name',
      );

      if (existingIdx >= 0) {
        _cache[existingIdx] = newItem;
      } else {
        _cache.add(newItem);
      }
    }

    await _save();
  }
}
