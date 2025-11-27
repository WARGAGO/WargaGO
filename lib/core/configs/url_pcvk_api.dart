import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlPCVKAPI {
  static String azureUrl = dotenv.env['PCVK_API_URL'] ?? '';

  static Uri buildAzureEndpoint(
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

    final bool isSSL = (dotenv.env['PCVK_API_HTTPS'] ?? 'true') == 'true';

    return isSSL
        ? Uri.https(azureUrl, 'api/$endpoint', cleanParams)
        : Uri.http(azureUrl, 'api/$endpoint', cleanParams);
  }
}
