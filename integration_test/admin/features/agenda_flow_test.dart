// integration_test/admin/agenda/agenda_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Agenda Flow (Kegiatan + Broadcast)', () {
    testWidgets('Login → Agenda → Switch Broadcast → Tambah → Edit → Delete', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 1. Login admin
      await tester.enterText(find.byType(TextField).at(0), 'admin@jawara.com');
      await tester.enterText(find.byType(TextField).at(1), 'admin123');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 2. Masuk ke Agenda/Kegiatan
      await tester.tap(find.textContaining('Agenda')); // atau 'Kegiatan'
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. Verifikasi halaman kegiatan
      expect(find.text('Kelola Agenda'), findsOneWidget);
      expect(find.text('Kegiatan'), findsOneWidget);
      expect(find.text('Broadcast'), findsOneWidget);

      // 4. Switch ke Broadcast tab
      await tester.tap(find.text('Broadcast'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifikasi halaman broadcast
      expect(find.text('Daftar Broadcast'), findsOneWidget);

      // 5. Test search di broadcast
      await tester.enterText(find.byType(TextFormField), 'pengumuman');
      await tester.pumpAndSettle();
      // Verifikasi list filtered (asumsi ada broadcast dengan kata tersebut)

      // 6. Test FAB → Tambah Broadcast
      await tester.tap(find.text('Tambah')); // atau icon + di FAB
      await tester.pumpAndSettle();

      expect(
        find.text('Tambah Broadcast'),
        findsOneWidget,
      ); // asumsi di TambahBroadcastPage

      // Isi form minimal & simpan (sesuaikan field di TambahBroadcastPage)
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Pengumuman Rapat RT',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.textContaining('Broadcast berhasil dibuat'), findsOneWidget);

      // Back ke list broadcast
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 7. Test expand card broadcast
      await tester.tap(find.textContaining('Pengumuman Rapat RT'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Isi Pesan'), findsOneWidget);

      // 8. Test edit broadcast
      await tester.tap(
        find.byIcon(Icons.edit_rounded),
      ); // tombol edit di expanded card
      await tester.pumpAndSettle();

      expect(
        find.text('Edit Broadcast'),
        findsOneWidget,
      ); // asumsi di EditBroadcastPage

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Pengumuman Rapat RT - Updated',
      );
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(
        find.textContaining('Broadcast berhasil diperbarui'),
        findsOneWidget,
      );

      // 9. Test delete broadcast
      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Broadcast'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.textContaining('Broadcast berhasil dihapus'), findsOneWidget);

      // 10. Switch kembali ke Kegiatan (opsional)
      await tester.tap(find.text('Kegiatan'));
      await tester.pumpAndSettle();

      debugPrint('✅ Full Agenda Flow (Kegiatan + Broadcast) test passed!');
    });
  });
}
