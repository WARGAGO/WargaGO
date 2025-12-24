// integration_test/dashboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Dashboard Full Test', () {
    testWidgets(
      'Login → Dashboard → Verifikasi semua section & interaksi utama',
      (WidgetTester tester) async {
        // 1. Jalankan aplikasi
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 2. Login sederhana (implementasi sementara)
        // Sesuaikan dengan field login-mu (email/password)
        final emailField = find.byType(TextField).at(0);
        final passwordField = find.byType(TextField).at(1);
        final loginButton = find.text('Masuk');

        await tester.enterText(emailField, 'admin@jawara.com');
        await tester.pump(const Duration(milliseconds: 300));

        await tester.enterText(passwordField, 'admin123');
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(loginButton);
        await tester.pumpAndSettle(
          const Duration(seconds: 8),
        ); // Tunggu auth selesai

        // Verifikasi sudah masuk dashboard
        expect(
          find.text('Dashboard'),
          findsOneWidget,
          reason: 'Harusnya masuk dashboard setelah login',
        );

        // 3. Verifikasi header
        expect(find.text('Selamat Datang 👋'), findsOneWidget);
        expect(find.text('Admin Diana'), findsOneWidget); // Sesuaikan nama user
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

        // 4. Finance overview
        await tester.scrollUntilVisible(find.text('Kas Masuk'), 200.0);
        expect(find.text('Kas Masuk'), findsOneWidget);
        expect(find.text('500JT'), findsOneWidget);
        expect(find.text('Kas Keluar'), findsOneWidget);
        expect(find.text('50JT'), findsOneWidget);
        expect(find.text('Total Transaksi'), findsOneWidget);

        // 5. Activity section
        expect(find.text('Kegiatan'), findsOneWidget);
        expect(find.text('Total Activities'), findsOneWidget);

        // 6. Timeline
        await tester.scrollUntilVisible(find.text('Timeline'), 200.0);
        expect(find.text('Sudah Lewat'), findsOneWidget);
        expect(find.text('Hari ini'), findsOneWidget);
        expect(find.text('Akan Datang'), findsOneWidget);

        // 7. Log aktivitas card
        await tester.scrollUntilVisible(
          find.text('Log Aktivitas Terbaru'),
          200.0,
        );
        expect(find.text('Log Aktivitas Terbaru'), findsOneWidget);
        expect(find.text('Menambah data warga baru'), findsOneWidget);

        // 8. Primary action button
        await tester.scrollUntilVisible(find.text('Selengkapnya'), 200.0);
        expect(find.text('Selengkapnya'), findsOneWidget);

        // 9. Contoh interaksi: Tap "Selengkapnya" → detail page
        await tester.tap(find.text('Selengkapnya'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(find.text('Dashboard Selengkapnya'), findsOneWidget);

        // Back ke dashboard
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        debugPrint('✅ Dashboard full test passed!');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
