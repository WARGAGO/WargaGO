// integration_test/admin/polling/polling_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;
import 'package:wargago/features/admin/polling/widgets/admin_poll_pie_chart.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Polling Flow', () {
    testWidgets(
      'Login → Poll List → Create → Analytics → Moderation → Logout',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 1. Login admin
        final emailField = find.byType(TextField).at(0);
        final passwordField = find.byType(TextField).at(1);
        final loginButton = find.text('Masuk');

        await tester.enterText(emailField, 'admin@jawara.com');
        await tester.enterText(passwordField, 'admin123');
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 8));

        // Verifikasi masuk dashboard
        expect(find.text('Dashboard'), findsOneWidget);

        // 2. Masuk ke Poll List (sesuaikan navigasi dari dashboard/menu)
        await tester.tap(
          find.textContaining('Polling'),
        ); // atau find.byKey(Key('menu_polling'))
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 3. Verifikasi Poll List
        expect(find.text('Kelola Polling'), findsOneWidget);
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Resmi'), findsOneWidget);
        expect(find.text('Buat Polling Resmi'), findsOneWidget); // FAB

        // 4. Test search
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pumpAndSettle();

        // 5. Test FAB → Create Poll
        await tester.tap(find.text('Buat Polling Resmi'));
        await tester.pumpAndSettle();

        expect(find.text('Buat Polling Resmi'), findsOneWidget);

        // Isi form minimal
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Polling Test E2E',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Deskripsi testing',
        );
        await tester.enterText(find.byType(TextFormField).at(2), 'Opsi A');
        await tester.enterText(find.byType(TextFormField).at(3), 'Opsi B');

        // Submit create
        await tester.tap(find.text('Buat Polling Resmi'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(
          find.textContaining('Polling resmi berhasil dibuat!'),
          findsOneWidget,
        );

        // Back ke list
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // 6. Test tap polling card → Analytics
        await tester.tap(find.textContaining('Polling Test E2E'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Distribusi Suara'), findsOneWidget);
        expect(find.byType(AdminPollPieChart), findsOneWidget); // chart

        // Test options menu
        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Share Hasil'), findsOneWidget);
        await tester.tapAt(const Offset(100, 100)); // close menu

        // Back ke list
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // 7. Test Moderation (tap flag icon)
        await tester.tap(find.byIcon(Icons.flag_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Moderasi Polling'), findsOneWidget);
        expect(find.text('Dilaporkan'), findsOneWidget);

        // Back ke list
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        debugPrint('✅ Full Polling Flow test passed!');
      },
    );
  });
}
