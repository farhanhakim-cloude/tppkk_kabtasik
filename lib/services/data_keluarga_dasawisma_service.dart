import '../models/data_keluarga_dasawisma.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataKeluargaDasawismaService {
  static final DataKeluargaDasawismaService _instance = DataKeluargaDasawismaService._internal();
  factory DataKeluargaDasawismaService() => _instance;
  DataKeluargaDasawismaService._internal();
  static const _storageKey = 'data_keluarga_dasawisma_v2';
  bool _loaded = false;

  final List<DataKeluargaDasawisma> _items = [];

  Future<List<DataKeluargaDasawisma>> getAll({String query = ''}) async {
    await _load();
    await Future.delayed(const Duration(milliseconds: 150));
    if (query.trim().isEmpty) return List.from(_items);
    final q = query.toLowerCase();
    return _items.where((e) {
      return e.namaKepalaRumahTangga.toLowerCase().contains(q) ||
          e.dasaWisma.toLowerCase().contains(q) ||
          e.rt.contains(q) ||
          e.rw.contains(q);
    }).toList();
  }

  Future<void> save(DataKeluargaDasawisma item) async {
    await _load();
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      final newId = _items.isEmpty ? 1 : (_items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      _items.insert(0, item.copyWith(id: newId));
    }
    await _persist();
  }

  Future<void> delete(int id) async {
    await _load();
    await Future.delayed(const Duration(milliseconds: 150));
    _items.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> _load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final values = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _items
        ..clear()
        ..addAll(values.map(_fromJson).where((item) => !_isSeed(item)));
    }
    _loaded = true;
  }

  bool _isSeed(DataKeluargaDasawisma item) =>
      item.namaKepalaRumahTangga.trim().toLowerCase() == 'ahmad fauzi' &&
      item.dasaWisma.trim().toLowerCase() == 'mawar 01' &&
      item.dusun.trim().isEmpty &&
      item.nomorKk.trim().isEmpty;

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_items.map(_toJson).toList()));
  }

  Map<String, dynamic> _toJson(DataKeluargaDasawisma e) => {
        'id': e.id, 'dasa_wisma': e.dasaWisma, 'rt': e.rt, 'rw': e.rw,
        'dusun': e.dusun, 'desa': e.desa, 'kecamatan': e.kecamatan,
        'nama_kepala': e.namaKepalaRumahTangga, 'nomor_kk': e.nomorKk,
        'nik_kepala': e.nikKepalaKeluarga, 'alamat': e.alamat,
        'l': e.jumlahLakiLaki, 'p': e.jumlahPerempuan, 'kk': e.jumlahKk,
        'balita': e.jumlahBalita, 'balita_l': e.jumlahBalitaL,
        'balita_p': e.jumlahBalitaP, 'anak': e.jumlahAnak, 'pus': e.jumlahPus,
        'wus': e.jumlahWus, 'buta': e.jumlahTigaButa,
        'buta_l': e.jumlahTigaButaL, 'buta_p': e.jumlahTigaButaP,
        'bumil': e.jumlahIbuHamil, 'busui': e.jumlahIbuMenyusui,
        'lansia': e.jumlahLansia, 'makanan': e.makananPokok,
        'mck': e.jumlahMckSepticTank, 'air': e.sumberAir,
        'sampah': e.memilikiTempatSampah, 'spal': e.mempunyaiSpal,
        'p4k': e.memilikiStikerP4k, 'rumah': e.kriteriaRumah,
        'up2k': e.aktifitasUp2k, 'usaha': e.jenisUsahaUp2k,
        'kesling': e.aktifitasKesehatanLingkungan,
        'pekarangan': e.aktifitasTanahPekarangan,
        'industri': e.aktifitasIndustriRumahTangga,
      };

  int _int(dynamic value) => int.tryParse('$value') ?? 0;
  bool _bool(dynamic value) => value == true || value == 'true';
  DataKeluargaDasawisma _fromJson(Map<String, dynamic> j) => DataKeluargaDasawisma(
        id: _int(j['id']), dasaWisma: '${j['dasa_wisma'] ?? ''}',
        rt: '${j['rt'] ?? ''}', rw: '${j['rw'] ?? ''}', dusun: '${j['dusun'] ?? ''}',
        desa: '${j['desa'] ?? ''}', kecamatan: '${j['kecamatan'] ?? ''}',
        namaKepalaRumahTangga: '${j['nama_kepala'] ?? ''}',
        nomorKk: '${j['nomor_kk'] ?? ''}', nikKepalaKeluarga: '${j['nik_kepala'] ?? ''}',
        alamat: '${j['alamat'] ?? ''}', jumlahLakiLaki: _int(j['l']),
        jumlahPerempuan: _int(j['p']), jumlahKk: _int(j['kk']) == 0 ? 1 : _int(j['kk']),
        jumlahBalita: _int(j['balita']), jumlahBalitaL: _int(j['balita_l']),
        jumlahBalitaP: _int(j['balita_p']), jumlahAnak: _int(j['anak']),
        jumlahPus: _int(j['pus']), jumlahWus: _int(j['wus']),
        jumlahTigaButa: _int(j['buta']), jumlahTigaButaL: _int(j['buta_l']),
        jumlahTigaButaP: _int(j['buta_p']), jumlahIbuHamil: _int(j['bumil']),
        jumlahIbuMenyusui: _int(j['busui']), jumlahLansia: _int(j['lansia']),
        makananPokok: '${j['makanan'] ?? 'Beras'}', jumlahMckSepticTank: _int(j['mck']),
        sumberAir: '${j['air'] ?? 'Sumur'}', memilikiTempatSampah: _bool(j['sampah']),
        mempunyaiSpal: _bool(j['spal']), memilikiStikerP4k: _bool(j['p4k']),
        kriteriaRumah: '${j['rumah'] ?? 'Sehat'}', aktifitasUp2k: _bool(j['up2k']),
        jenisUsahaUp2k: '${j['usaha'] ?? ''}',
        aktifitasKesehatanLingkungan: _bool(j['kesling']),
        aktifitasTanahPekarangan: _bool(j['pekarangan']),
        aktifitasIndustriRumahTangga: _bool(j['industri']),
      );
}
