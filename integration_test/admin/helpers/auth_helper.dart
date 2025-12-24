// integration_test/helpers/auth_helper.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

Future<void> loginAsAdmin(WidgetTester tester) async {
  // Implementasi login pakai page object atau langsung enter text
  // Contoh sederhana (sesuaikan dengan field login-mu)
  await tester.enterText(find.byType(TextField).at(0), 'admin@jawara.com');
  await tester.enterText(find.byType(TextField).at(1), 'admin123');
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle(const Duration(seconds: 5));
}
