import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlPCVKAPI {
  UrlPCVKAPI._();

  static String get baseUrlEnv => dotenv.maybeGet('PCVK_API_URL') ?? '';
  static String _baseUrl = baseUrlEnv;
  static String get baseUrl => _baseUrl;
  static void setBaseUrl(String url) => _baseUrl = url;

  static bool get isSSLEnv => dotenv.maybeGet('PCVK_API_HTTPS') == 'true';
  static bool _isSSL = isSSLEnv;
  static bool get isSSL => _isSSL;
  static void setIsSSL(bool isSSL) => _isSSL = isSSL;

  static Uri buildEndpoint(
    String endpoint, {
    Map<String, String?>? queryParameters,
  }) {
    Map<String, String>? cleanParams;
    if (queryParameters != null) {
      cleanParams = {};
      queryParameters.forEach((key, value) {
        if (value != null) {
          cleanParams![key] = value;
        }
      });
    }

    return _isSSL
        ? Uri.https(baseUrl, 'api/$endpoint', cleanParams)
        : Uri.http(baseUrl, 'api/$endpoint', cleanParams);
  }

  static Uri buildWebSocketEndpoint(String endpoint) =>
      Uri.parse('${_isSSL ? 'wss' : 'ws'}://$baseUrl/api/$endpoint');
}
