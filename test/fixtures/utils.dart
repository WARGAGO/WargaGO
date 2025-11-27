import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http show post;

class Utils {
  static Future<String> getAuthToken() async {
    await dotenv.load(fileName: "..env");

    final apiKey = dotenv.env['FIREBASE_API_KEY_WEB'] ?? '';
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        'email': dotenv.env['TEST_EMAIL'] ?? '',
        'password': dotenv.env['TEST_PASSWORD'] ?? '',
        'returnSecureToken': true,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['idToken'];
    } else {
      throw Exception('Failed to get token: ${response.body}');
    }
  }
}
