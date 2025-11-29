import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'create_admin.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n========================================');
  print('🔧 MEMBUAT ADMIN BARU');
  print('========================================\n');
  
  print('🚀 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized!\n');
  
  // Buat admin2@jawara.com
  await createAdmin2();
  
  print('\n========================================');
  print('✅ SELESAI!');
  print('========================================\n');
}


