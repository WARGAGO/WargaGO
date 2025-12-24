// integration_test/admin/kelola_lapak/kelola_lapak_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Kelola Lapak Flow', () {
    testWidgets(
      'Login → Kelola Lapak → Verifikasi UI, Tab, Card, Detail & Action',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 1. Login admin
        await tester.enterText(
          find.byType(TextField).at(0),
          'admin@jawara.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'admin123');
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(const Duration(seconds: 8));

        // Verifikasi masuk dashboard
        expect(find.text('Dashboard'), findsOneWidget);

        // 2. Masuk ke Kelola Lapak (sesuaikan navigasi dari dashboard/menu)
        await tester.tap(
          find.textContaining('Lapak'),
        ); // atau 'Kelola Lapak', 'Marketplace'
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 3. Verifikasi header & statistics card
        expect(find.text('Kelola Lapak'), findsOneWidget);
        expect(find.text('Verifikasi & Kelola Penjual'), findsOneWidget);
        expect(find.text('Menunggu'), findsOneWidget);
        expect(find.text('Disetujui'), findsOneWidget);
        expect(find.text('Ditolak'), findsOneWidget);
        expect(find.text('Suspend'), findsOneWidget);

        // 4. Test tab switch
        await tester.tap(find.text('Disetujui'));
        await tester.pumpAndSettle();
        // Verifikasi list update (asumsi ada data)
        // expect(find.textContaining('Aktif'), findsWidgets);

        await tester.tap(find.text('Pending'));
        await tester.pumpAndSettle();

        // 5. Test tap card seller → detail page
        await tester.tap(
          find.textContaining('Test Seller'),
        ); // sesuaikan dengan nama toko/nama lengkap di card
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verifikasi halaman detail
        expect(find.text('Detail Seller'), findsOneWidget);
        expect(find.textContaining('Toko Test'), findsOneWidget); // nama toko
        expect(find.text('Foto KTP'), findsOneWidget);
        expect(find.text('Checklist Verifikasi'), findsOneWidget);

        // 6. Test action approve (hanya muncul kalau pending)
        expect(find.text('Setujui'), findsOneWidget);
        await tester.tap(find.text('Setujui'));
        await tester.pumpAndSettle();

        // Verifikasi dialog approve
        expect(find.text('Setujui Seller?'), findsOneWidget);

        // Isi catatan optional & konfirmasi
        await tester.enterText(find.byType(TextField), 'Approved by E2E test');
        await tester.tap(find.text('Setujui'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.textContaining('Seller telah disetujui!'), findsOneWidget);

        // 7. Back ke list
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        debugPrint('✅ Full Kelola Lapak Flow test passed!');
      },
    );
  });
}
