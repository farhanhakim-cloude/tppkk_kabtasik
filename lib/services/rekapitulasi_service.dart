// lib/services/rekapitulasi_service.dart
// Opsi A Tanpa ACC: agregasi otomatis dari semua service input Darawisma
// Data dasar dari dasawisma -> auto roll-up ke RT/RW/Dusun/Desa/Kecamatan/Kabupaten berdasarkan filter wilayah

import '../services/data_keluarga_dasawisma_service.dart';
import '../services/dasawisma_catatan_keluarga_service.dart';
import '../services/kegiatan_warga_service.dart';
import '../services/pemanfaatan_tanah_service.dart';
import '../services/industri_rumah_tangga_service.dart';
import '../services/rekap_ibu_anak_service.dart';

class RekapRow {
  final String namaKepalaRumahTangga;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  // Sheet 7: 30 kolom
  final int jumlahKk;
  final int l;
  final int p;
  final int balitaL;
  final int balitaP;
  final int pus;
  final int wus;
  final int ibuHamil;
  final int ibuMenyusui;
  final int lansia;
  final int tigaButaL;
  final int tigaButaP;
  final int berkebutuhanKhusus;
  final int kriteriaTidakLayak;
  final int punyaJamban;
  final int punyaTempatSampah;
  final int punyaSpal;
  final int sumberAirPdam;
  final int sumberAirSumur;
  final int sumberAirLainnya;
  final int makananBeras;
  final int makananNonBeras;
  final int up2k;
  final int tanahPekarangan;
  final int industriRumah;
  final int kesehatanLingkungan;

  RekapRow({
    required this.namaKepalaRumahTangga,
    required this.dasaWisma,
    required this.rt,
    required this.rw,
    this.dusun = '',
    required this.desa,
    required this.kecamatan,
    this.jumlahKk = 0,
    this.l = 0,
    this.p = 0,
    this.balitaL = 0,
    this.balitaP = 0,
    this.pus = 0,
    this.wus = 0,
    this.ibuHamil = 0,
    this.ibuMenyusui = 0,
    this.lansia = 0,
    this.tigaButaL = 0,
    this.tigaButaP = 0,
    this.berkebutuhanKhusus = 0,
    this.kriteriaTidakLayak = 0,
    this.punyaJamban = 0,
    this.punyaTempatSampah = 0,
    this.punyaSpal = 0,
    this.sumberAirPdam = 0,
    this.sumberAirSumur = 0,
    this.sumberAirLainnya = 0,
    this.makananBeras = 0,
    this.makananNonBeras = 0,
    this.up2k = 0,
    this.tanahPekarangan = 0,
    this.industriRumah = 0,
    this.kesehatanLingkungan = 0,
  });
}

class RekapTotal {
  int jumlahKk = 0;
  int l = 0, p = 0;
  int balitaL = 0, balitaP = 0;
  int pus = 0, wus = 0;
  int ibuHamil = 0, ibuMenyusui = 0, lansia = 0;
  int tigaButaL = 0, tigaButaP = 0;
  int berkebutuhanKhusus = 0;
  int kriteriaTidakLayak = 0;
  int punyaJamban = 0, punyaTempatSampah = 0, punyaSpal = 0;
  int sumberAirPdam = 0, sumberAirSumur = 0, sumberAirLainnya = 0;
  int makananBeras = 0, makananNonBeras = 0;
  int up2k = 0, tanahPekarangan = 0, industriRumah = 0, kesehatanLingkungan = 0;

  void add(RekapRow r) {
    jumlahKk += r.jumlahKk;
    l += r.l; p += r.p;
    balitaL += r.balitaL; balitaP += r.balitaP;
    pus += r.pus; wus += r.wus;
    ibuHamil += r.ibuHamil; ibuMenyusui += r.ibuMenyusui; lansia += r.lansia;
    tigaButaL += r.tigaButaL; tigaButaP += r.tigaButaP;
    berkebutuhanKhusus += r.berkebutuhanKhusus;
    kriteriaTidakLayak += r.kriteriaTidakLayak;
    punyaJamban += r.punyaJamban; punyaTempatSampah += r.punyaTempatSampah; punyaSpal += r.punyaSpal;
    sumberAirPdam += r.sumberAirPdam; sumberAirSumur += r.sumberAirSumur; sumberAirLainnya += r.sumberAirLainnya;
    makananBeras += r.makananBeras; makananNonBeras += r.makananNonBeras;
    up2k += r.up2k; tanahPekarangan += r.tanahPekarangan; industriRumah += r.industriRumah; kesehatanLingkungan += r.kesehatanLingkungan;
  }
}

class IbuBayiRekap {
  final int hamil, melahirkan, nifas, bayiLahirL, bayiLahirP, aktaAda, aktaTidak, ibuMeninggal, bayiMeninggalL, bayiMeninggalP, balitaMeninggal;
  IbuBayiRekap({this.hamil=0,this.melahirkan=0,this.nifas=0,this.bayiLahirL=0,this.bayiLahirP=0,this.aktaAda=0,this.aktaTidak=0,this.ibuMeninggal=0,this.bayiMeninggalL=0,this.bayiMeninggalP=0,this.balitaMeninggal=0});
}

class RekapitulasiService {
  final _dasawisma = DataKeluargaDasawismaService();
  final _catatan = DasawismaCatatanKeluargaService();
  final _kegiatan = KegiatanWargaService();
  final _tanah = PemanfaatanTanahService();
  final _industri = IndustriRumahTanggaService();
  final _ibu = RekapIbuAnakService();

  bool _matchWilayah({
    required String rt, required String rw, required String dusun, required String desa, required String kecamatan,
    String? fRt, String? fRw, String? fDusun, String? fDesa, String? fKecamatan, String? fTahun,
    String? tahun
  }) {
    if (fRt != null && fRt.isNotEmpty && rt != fRt) return false;
    if (fRw != null && fRw.isNotEmpty && rw != fRw) return false;
    if (fDusun != null && fDusun.isNotEmpty && dusun.toLowerCase() != fDusun.toLowerCase()) return false;
    if (fDesa != null && fDesa.isNotEmpty && desa.toLowerCase() != fDesa.toLowerCase()) return false;
    if (fKecamatan != null && fKecamatan.isNotEmpty && kecamatan.toLowerCase() != fKecamatan.toLowerCase()) return false;
    if (tahun != null && fTahun != null && fTahun.isNotEmpty && tahun != fTahun) return false;
    return true;
  }

  Future<List<RekapRow>> getRekapSheet7({
    String? rt, String? rw, String? dusun, String? desa, String? kecamatan, String? tahun,
  }) async {
    final semua = await _dasawisma.getAll();
    final catatanAll = await _catatan.getAll();
    final tanahAll = await _tanah.getAll();
    final industriAll = await _industri.getAll();

    // Index tambahan per wilayah untuk kolom 27-29
    int countFor(String r, String w, String du, String de, String ke, List list) {
      return list.where((e) {
        final er = (e.rt ?? '') as String;
        final ew = (e.rw ?? '') as String;
        final edu = (e.dusun ?? '') as String;
        final ede = (e.desa ?? '') as String;
        final eke = (e.kecamatan ?? '') as String;
        return _matchWilayah(rt: er, rw: ew, dusun: edu, desa: ede, kecamatan: eke, fRt: r, fRw: w, fDusun: du, fDesa: de, fKecamatan: ke);
      }).length;
    }

    // berkebutuhan khusus count from catatan_keluarga
    final rows = <RekapRow>[];
    for (final d in semua) {
      if (!_matchWilayah(rt: d.rt, rw: d.rw, dusun: '', desa: d.desa, kecamatan: d.kecamatan, fRt: rt, fRw: rw, fDusun: dusun, fDesa: desa, fKecamatan: kecamatan)) continue;
      if (tahun != null && tahun.isNotEmpty) {
        // DataKeluargaDasawisma tidak punya tahun field, skip filter tahun untuk sheet7 utama
      }
      final bkCount = catatanAll.where((c) => c.rt == d.rt && c.rw == d.rw && c.desa == d.desa).fold(0, (sum, c) => sum + c.items.where((it) => it.berkebutuhanKhusus.toLowerCase() != 'tidak' && it.berkebutuhanKhusus.isNotEmpty).length);

      final sAir = d.sumberAir.toLowerCase();
      rows.add(RekapRow(
        namaKepalaRumahTangga: d.namaKepalaRumahTangga,
        dasaWisma: d.dasaWisma,
        rt: d.rt, rw: d.rw, desa: d.desa, kecamatan: d.kecamatan,
        jumlahKk: d.jumlahKk,
        l: d.jumlahLakiLaki, p: d.jumlahPerempuan,
        balitaL: d.jumlahBalita, // tidak split L/P di model existing, sisip ke L
        pus: d.jumlahPus, wus: d.jumlahWus,
        ibuHamil: d.jumlahIbuHamil, ibuMenyusui: d.jumlahIbuMenyusui, lansia: d.jumlahLansia,
        tigaButaL: d.jumlahTigaButa,
        berkebutuhanKhusus: bkCount,
        kriteriaTidakLayak: d.kriteriaRumah.toLowerCase().contains('tidak') || d.kriteriaRumah.toLowerCase().contains('kurang') ? 1 : 0,
        punyaJamban: d.mempunyaiMck ? 1 : 0,
        punyaTempatSampah: d.memilikiTempatSampah ? 1 : 0,
        punyaSpal: d.mempunyaiSpal ? 1 : 0,
        sumberAirPdam: sAir.contains('pdam') ? 1 : 0,
        sumberAirSumur: sAir.contains('sumur') ? 1 : 0,
        sumberAirLainnya: (sAir.contains('sungai') || sAir.contains('lain')) ? 1 : 0,
        makananBeras: d.makananPokok.toLowerCase() == 'beras' ? 1 : 0,
        makananNonBeras: d.makananPokok.toLowerCase() != 'beras' ? 1 : 0,
        up2k: d.aktifitasUp2k ? 1 : 0,
        tanahPekarangan: countFor(d.rt, d.rw, '', d.desa, d.kecamatan, tanahAll) > 0 ? 1 : 0,
        industriRumah: countFor(d.rt, d.rw, '', d.desa, d.kecamatan, industriAll) > 0 ? 1 : 0,
        kesehatanLingkungan: d.aktifitasKesehatanLingkungan ? 1 : 0,
      ));
    }
    return rows;
  }

  Future<RekapTotal> getTotalSheet7({String? rt, String? rw, String? dusun, String? desa, String? kecamatan, String? tahun}) async {
    final rows = await getRekapSheet7(rt: rt, rw: rw, dusun: dusun, desa: desa, kecamatan: kecamatan, tahun: tahun);
    final total = RekapTotal();
    for (final r in rows) total.add(r);
    return total;
  }

  Future<IbuBayiRekap> getRekapSheet8({String? rt, String? rw, String? dusun, String? desa, String? bulan, String? tahun}) async {
    final list = await _ibu.getAll();
    final filtered = list.where((e) {
      if (rt != null && rt.isNotEmpty && e.rt != rt) return false;
      if (rw != null && rw.isNotEmpty && e.rw != rw) return false;
      if (dusun != null && dusun.isNotEmpty && e.dusun.toLowerCase() != dusun.toLowerCase()) return false;
      if (desa != null && desa.isNotEmpty && e.desa.toLowerCase() != desa.toLowerCase()) return false;
      if (bulan != null && bulan.isNotEmpty && e.bulan.toLowerCase() != bulan.toLowerCase()) return false;
      if (tahun != null && tahun.isNotEmpty && e.tahun != tahun) return false;
      return true;
    }).toList();

    int hamil=0, melahirkan=0, nifas=0, bayiL=0, bayiP=0, aktaAda=0, aktaTidak=0, ibuMeninggal=0, bayiML=0, bayiMP=0, balitaM=0;
    for (final e in filtered) {
      final s = e.statusIbu.toLowerCase();
      if (s.contains('hamil')) hamil++;
      else if (s.contains('lahir')) melahirkan++;
      else if (s.contains('nifas')) nifas++;
      if (e.adaKelahiran) {
        if (e.jenisKelaminBayi == 'L') bayiL++; else bayiP++;
        if (e.hasAktaKelahiran) aktaAda++; else aktaTidak++;
      }
      if (e.adaKematian) {
        final sk = e.statusMeninggal.toLowerCase();
        if (sk.contains('ibu')) ibuMeninggal++;
        else if (sk.contains('bayi')) { if (e.jenisKelaminMeninggal=='L') bayiML++; else bayiMP++; }
        else if (sk.contains('balita')) balitaM++;
      }
    }
    return IbuBayiRekap(hamil:hamil, melahirkan:melahirkan, nifas:nifas, bayiLahirL:bayiL, bayiLahirP:bayiP, aktaAda:aktaAda, aktaTidak:aktaTidak, ibuMeninggal:ibuMeninggal, bayiMeninggalL:bayiML, bayiMeninggalP:bayiMP, balitaMeninggal:balitaM);
  }

  Future<Map<String, int>> getDashboardCounts({String? desa, String? kecamatan}) async {
    final dasa = await getTotalSheet7(desa: desa, kecamatan: kecamatan);
    final ibu = await getRekapSheet8(desa: desa);
    final keg = await _kegiatan.getAll();
    final tanah = await _tanah.getAll();
    final industri = await _industri.getAll();
    return {
      'keluarga': dasa.jumlahKk,
      'jiwaL': dasa.l,
      'jiwaP': dasa.p,
      'balita': dasa.balitaL + dasa.balitaP,
      'ibuHamil': dasa.ibuHamil,
      'kegiatanAktif': keg.fold(0, (sum,e)=> sum + e.totalAktif),
      'tanah': tanah.length,
      'industri': industri.length,
      'bayiLahir': ibu.bayiLahirL + ibu.bayiLahirP,
    };
  }
}
