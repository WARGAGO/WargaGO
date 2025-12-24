import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Alur Manajemen Keuangan RT/RW', () {
    testWidgets('Login → Kelola Pemasukan → Kelola Pengeluaran', (
      WidgetTester tester,
    ) async {
      // 1. START APP & LOGIN
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Masukkan kredensial admin (mengikuti base code agenda)
      await tester.enterText(find.byType(TextField).at(0), 'admin@jawara.com');
      await tester.enterText(find.byType(TextField).at(1), 'admin123');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 2. MASUK KE MENU KEUANGAN (Bottom Nav)
      // Mencari icon dompet/wallet sesuai implementasi navbar Anda
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. ALUR PEMASUKAN (Iuran)
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Klik FAB untuk tambah (Logic di KelolaPemasukanPage)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Isi form Jenis Iuran (Tab pertama)
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Iuran Keamanan',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '50000');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verifikasi snackbar atau dialog sukses
      expect(find.textContaining('berhasil'), findsWidgets);

      // Kembali ke dashboard keuangan
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 4. ALUR PENGELUARAN
      await tester.tap(find.text('Pengeluaran'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tambah pengeluaran baru
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Sesuai dengan widget TambahPengeluaranPage yang menggunakan widgetWithText
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Apa nama pengeluarannya?'),
        'Bayar Gaji Satpam',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          '0',
        ), // Hint default nominal adalah 0
        '1000000',
      );

      // Pilih kategori (scroll jika perlu)
      await tester.tap(find.text('Operasional'));

      await tester.tap(find.text('Simpan Laporan'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 5. VERIFIKASI & EDIT PENGELUARAN
      // Pastikan data muncul di list
      expect(find.text('Bayar Gaji Satpam'), findsOneWidget);

      // Test Expand Card (mengacu pada logic di KelolaPengeluaranPage)
      await tester.tap(find.text('Bayar Gaji Satpam'));
      await tester.pumpAndSettle();

      // Klik Edit di dalam card yang ter-expand
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Update nominal
      await tester.enterText(
        find.widgetWithText(TextFormField, '0'),
        '1100000',
      );
      await tester.tap(find.text('Perbarui Laporan'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 6. SELESAI
      // Kembali ke dashboard utama
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      debugPrint(
        '✅ E2E Alur Keuangan (Login -> Pemasukan -> Pengeluaran) Berhasil!',
      );
    });
  });
}
