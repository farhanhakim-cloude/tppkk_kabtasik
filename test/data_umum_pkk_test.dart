import 'package:flutter_test/flutter_test.dart';
import 'package:tppkk_kabtasik/models/data_umum_pkk.dart';

void main() {
  test('total jiwa includes population without L/P breakdown', () {
    final item = DataUmumPkkItem.fromJson({
      'id': 1,
      'jiwa_l': 2,
      'jiwa_p': 3,
      'jiwa_tidak_terpilah': 4,
    });

    expect(item.totalJiwa, 9);
    expect(item.jiwaL, 2);
    expect(item.jiwaP, 3);
    expect(item.jiwaTidakTerpilah, 4);
  });

  test('serialization keeps the unclassified population value', () {
    final item = DataUmumPkkItem(
      id: 1,
      jiwaL: 2,
      jiwaP: 3,
      jiwaTidakTerpilah: 4,
    );

    expect(item.toJson()['jiwa_tidak_terpilah'], 4);
  });
}
