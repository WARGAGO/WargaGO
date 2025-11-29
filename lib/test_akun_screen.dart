// Test AkunScreen standalone
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/features/warga/profile/akun_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        home: TestAkunScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class TestAkunScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Profile Warga'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AkunScreen()),
            );
          },
          child: Text('Buka Profile'),
        ),
      ),
    );
  }
}

