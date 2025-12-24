// integration_test/admin/tagihan/tagihan_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;
import 'package:wargago/features/admin/tagihan/widgets/tagihan_card.dart'; // <-- INI YANG HILANG!

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Tagihan Flow', () {
    testWidgets('Login → Tagihan List → Filter → Add → Mark Paid → Delete', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Login admin
      await tester.enterText(find.byType(TextField).at(0), 'admin@jawara.com');
      await tester.enterText(find.byType(TextField).at(1), 'admin123');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 2. Masuk ke Tagihan List (sesuaikan navigasi dari dashboard/menu)
      await tester.tap(find.textContaining('Tagihan'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. Verifikasi halaman list muncul
      expect(find.text('Manajemen Tagihan'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget); // refresh button
      expect(find.byIcon(Icons.filter_list), findsOneWidget); // filter button
      expect(find.text('Tambah Tagihan'), findsOneWidget); // FAB

      // 4. Test refresh indicator (pull to refresh)
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pumpAndSettle();

      // 5. Test filter dialog
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      expect(find.text('Filter Tagihan'), findsOneWidget);

      await tester.tap(find.text('Lunas'));
      await tester.pumpAndSettle();
      // Verifikasi list update berdasarkan status (asumsi ada data lunas)
      // expect(find.textContaining('Lunas'), findsWidgets);

      // Close dialog
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();

      // 6. Test FAB → Add Tagihan
      await tester.tap(find.text('Tambah Tagihan'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Tagihan'), findsOneWidget);

      // Back ke list
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 7. Test tap tagihan card → Detail
      await tester.tap(find.byType(TagihanCard).first); // asumsi ada card
      await tester.pumpAndSettle();
      expect(find.text('Detail Tagihan'), findsOneWidget);

      // Back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 8. Test mark as paid (dialog)
      // Asumsi ada card dengan status 'Belum Dibayar'
      await tester.tap(find.text('Bayar')); // atau icon di TagihanCard
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);

      // Pilih metode & konfirmasi
      await tester.tap(find.text('Cash')); // dropdown
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.textContaining('Tagihan berhasil dibayar'), findsOneWidget);

      // 9. Test delete tagihan
      await tester.tap(find.text('Hapus')); // atau icon di card
      await tester.pumpAndSettle();
      expect(find.text('Hapus Tagihan?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.textContaining('Tagihan berhasil dihapus'), findsOneWidget);

      debugPrint('✅ Full Tagihan Flow test passed!');
    });
  });
}
