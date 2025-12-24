// integration_test/admin/profile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Profile & Logout Flow', () {
    testWidgets('Dashboard → Profile → All Menu & Logout', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Login admin (implementasi sederhana, sesuaikan UI login-mu)
      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);
      final loginButton = find.text('Masuk');

      await tester.enterText(emailField, 'admin@jawara.com');
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(passwordField, 'admin123');
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Verifikasi masuk dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // 2. Masuk ke profile (tap avatar di header)
      final profileAvatar = find.byType(CircleAvatar);
      expect(profileAvatar, findsOneWidget);
      await tester.tap(profileAvatar);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. Verifikasi header profile
      expect(find.text('Profile Admin'), findsOneWidget);
      expect(find.text('Admin Diana'), findsOneWidget); // nama dari Firestore
      expect(find.textContaining('admin@'), findsOneWidget); // email
      expect(find.text('ADMIN'), findsOneWidget); // role badge

      // 4. Verifikasi info card personal
      expect(find.text('Informasi Personal'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Admin Diana'), findsOneWidget);
      expect(find.textContaining('Tanggal Lahir'), findsOneWidget);

      // 5. Test tap Edit Profile
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      // Back ke profile
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 6. Test tap Settings
      await tester.tap(find.text('Pengaturan'));
      await tester.pumpAndSettle();
      expect(find.text('Pengaturan'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 7. Test tap FAQ → bottom sheet
      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();
      expect(find.text('Frequently Asked Questions'), findsOneWidget);

      // Expand satu FAQ
      await tester.tap(find.text('Bagaimana cara mengelola data penduduk?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Buka menu Data Penduduk'), findsOneWidget);

      // Close FAQ
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 8. Test tap About
      await tester.tap(find.text('Tentang Aplikasi'));
      await tester.pumpAndSettle();
      expect(find.text('Tentang Aplikasi'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 9. Test Logout flow
      await tester.scrollUntilVisible(find.text('Logout'), 200.0);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verifikasi dialog logout
      expect(find.text('Logout'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin keluar dari akun admin?'),
        findsOneWidget,
      );

      // Konfirmasi logout
      await tester.tap(find.text('Logout')); // tombol di dialog
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verifikasi kembali ke login
      expect(find.text('Masuk'), findsOneWidget); // atau teks login page
      expect(find.text('Dashboard'), findsNothing);

      debugPrint('✅ Full Profile & Logout test passed!');
    });
  });
}
