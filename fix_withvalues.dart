// ============================================================================
// FIX WITHVALUES TO WITHOPACITY
// ============================================================================
// Script untuk mengganti withValues(alpha:) menjadi withOpacity()
// Untuk kompatibilitas dengan Flutter versi lama
// ============================================================================

import 'dart:io';

void main() async {
  print('🔧 Starting fix withValues to withOpacity...\n');

  final filesToFix = [
    'lib/core/widgets/app_bottom_navigation.dart',
    'lib/features/pre_auth/pre_auth_page.dart',
    'lib/features/onboarding/widgets/onboarding_widgets.dart',
    'lib/features/keuangan/widgets/keuangan_widgets.dart',
    'lib/features/keuangan/widgets/edit_metode_widgets.dart',
    'lib/features/data_warga/data_mutasi/data_mutasi_warga_page_NEW.dart',
  ];

  int totalFixed = 0;
  int filesFixed = 0;

  for (final filePath in filesToFix) {
    final file = File(filePath);

    if (!await file.exists()) {
      print('⚠️  File not found: $filePath');
      continue;
    }

    String content = await file.readAsString();
    final originalContent = content;

    // Replace withValues(alpha: X) with withOpacity(X)
    // Pattern: .withValues(alpha: 0.XX)
    final regex = RegExp(r'\.withValues\(alpha:\s*(\d+\.?\d*)\)');
    final matches = regex.allMatches(content).length;

    if (matches > 0) {
      content = content.replaceAllMapped(
        regex,
        (match) => '.withOpacity(${match.group(1)})',
      );

      await file.writeAsString(content);

      print('✅ Fixed $matches occurrence(s) in: $filePath');
      totalFixed += matches;
      filesFixed++;
    } else {
      print('ℹ️  No changes needed: $filePath');
    }
  }

  print('\n' + '='*60);
  print('📊 Summary:');
  print('   Files fixed: $filesFixed');
  print('   Total replacements: $totalFixed');
  print('✅ Done!');
  print('='*60);
}

