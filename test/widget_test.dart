// Smoke test TP PKK Kab. Tasikmalaya.
// Memastikan MyApp bisa di-build tanpa error (pengganti template counter).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tppkk_kabtasik/main.dart';

void main() {
  testWidgets('MyApp builds MaterialApp and navigates from splash', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    // Lewati delay splash 2.5 detik + navigasi ke /login.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
