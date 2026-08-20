enum KategoriKesehatan { ibuHamil, ibuMenyusui, balita }

class DataKesehatan {
  final int id;
  final String namaIbu;
  final String namaAnak; // kosong kalau kategori ibu hamil
  final KategoriKesehatan kategori;
  final String usiaKehamilanAtauAnak; // "20 minggu" atau "18 bulan"
  final String statusGizi; // Normal, Kurang, Lebih (khusus balita)
  final String rt;
  final String rw;

  DataKesehatan({
    required this.id,
    required this.namaIbu,
    this.namaAnak = '',
    required this.kategori,
    required this.usiaKehamilanAtauAnak,
    this.statusGizi = '-',
    required this.rt,
    required this.rw,
  });


  DataKesehatan salin({
    int? id,
    String? namaIbu,
    String? namaAnak,
    KategoriKesehatan? kategori,
    String? usiaKehamilanAtauAnak,
    String? statusGizi,
    String? rt,
    String? rw,
  }) {
    return DataKesehatan(
      id: id ?? this.id,
      namaIbu: namaIbu ?? this.namaIbu,
      namaAnak: namaAnak ?? this.namaAnak,
      kategori: kategori ?? this.kategori,
      usiaKehamilanAtauAnak: usiaKehamilanAtauAnak ?? this.usiaKehamilanAtauAnak,
      statusGizi: statusGizi ?? this.statusGizi,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
    );
  }
}

extension KategoriKesehatanLabel on KategoriKesehatan {
  String get label {
    switch (this) {
      case KategoriKesehatan.ibuHamil:
        return 'Ibu Hamil';
      case KategoriKesehatan.ibuMenyusui:
        return 'Ibu Menyusui';
      case KategoriKesehatan.balita:
        return 'Balita';
    }
  }
}