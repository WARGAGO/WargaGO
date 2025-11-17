import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/warga_provider.dart';
import 'core/providers/rumah_provider.dart';
import 'core/providers/keluarga_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WargaProvider()),
        ChangeNotifierProvider(create: (_) => RumahProvider()),
        ChangeNotifierProvider(create: (_) => KeluargaProvider()),
      ],
      child: const JawaraApp(),
    ),
  );
}
