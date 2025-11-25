class UrlConstant {
  static const String azureUrl =
      'pcvk-containerapp.lemonisland-43c085da.southeastasia.azurecontainerapps.io';

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
    return Uri.https(azureUrl, 'api/$endpoint', cleanParams);
  }
}
