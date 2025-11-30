import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlPCVKAPI {
  UrlPCVKAPI._();

  static String get baseUrl => dotenv.maybeGet('PCVK_API_URL') ?? '';
  static bool get isSSL =>
      (dotenv.maybeGet('PCVK_API_HTTPS') ?? 'true') == 'true';

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

    return isSSL
        ? Uri.https(baseUrl, 'api/$endpoint', cleanParams)
        : Uri.http(baseUrl, 'api/$endpoint', cleanParams);
  }

  static Uri buildWebSocketEndpoint(String endpoint) =>
      Uri.parse('${isSSL ? 'wss' : 'ws'}://$baseUrl/api/$endpoint');
}
