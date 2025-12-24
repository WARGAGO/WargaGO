// integration_test/admin/iuran/iuran_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Iuran & Verifikasi Flow', () {
    testWidgets(
      'Login → Kelola Iuran → Tambah → Detail → Verifikasi Bukti → Approve',
      (tester) async {
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

        // 2. Masuk ke Kelola Iuran
        await tester.tap(find.textContaining('Iuran')); // sesuaikan navigasi
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 3. Verifikasi halaman list iuran
        expect(find.text('Kelola Iuran'), findsOneWidget);

        // 4. Test filter & search (contoh)
        await tester.tap(find.text('Aktif'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'kebersihan');
        await tester.pumpAndSettle();

        // 5. Test FAB → Tambah Iuran
        await tester.tap(find.text('Tambah Iuran'));
        await tester.pumpAndSettle();

        expect(find.text('Tambah Iuran Baru'), findsOneWidget);

        // Isi form minimal
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Iuran Test E2E',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Deskripsi test',
        );
        await tester.enterText(find.byType(TextFormField).at(2), '50000');

        // Pilih tipe & kategori
        await tester.tap(find.text('bulanan'));
        await tester.tap(find.text('Kebersihan'));

        // Submit tambah iuran
        await tester.tap(find.text('Buat Iuran & Generate Tagihan'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.textContaining('Iuran berhasil dibuat!'), findsOneWidget);

        // Back ke list
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // 6. Masuk ke Detail Iuran (tap card pertama)
        await tester.tap(find.textContaining('Iuran Test E2E'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verifikasi halaman detail
        expect(find.text('Detail Iuran'), findsOneWidget);
        expect(find.text('Total Tagihan'), findsOneWidget);
        expect(find.text('Sudah Bayar'), findsOneWidget);

        // 7. Test action popup menu (edit / toggle / delete)
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Test edit → masuk ke TambahIuranPage (edit mode)
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        expect(find.text('Edit Iuran'), findsOneWidget);

        // Back ke detail
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // 8. Masuk ke Verifikasi Pembayaran (asumsi ada menu/navigasi terpisah)
        await tester.tap(
          find.textContaining('Verifikasi Pembayaran'),
        ); // sesuaikan navigasi
        await tester.pumpAndSettle();

        // Verifikasi halaman verifikasi
        expect(find.text('Verifikasi Pembayaran'), findsOneWidget);

        // 9. Test approve bukti pembayaran (asumsi ada card pending)
        await tester.tap(find.text('Approve')); // atau icon check di card
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Pembayaran berhasil diapprove!'),
          findsOneWidget,
        );

        // 10. Test reject (alternatif)
        // await tester.tap(find.text('Tolak'));
        // await tester.enterText(find.byType(TextField), 'Alasan test');
        // await tester.tap(find.text('Tolak'));
        // expect(find.textContaining('Pembayaran ditolak'), findsOneWidget);

        debugPrint('✅ Full Iuran & Verifikasi Flow test passed!');
      },
    );
  });
}
