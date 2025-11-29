import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jawara/core/configs/url_pcvk_api.dart';
import 'package:jawara/core/models/OCR/health_response.dart';
import 'package:jawara/core/models/OCR/ocr_response.dart';

class OCRService {
  late final http.Client _client;

  OCRService({http.Client? httpClient}) {
    _client = httpClient ?? http.Client();
  }

  Future<OcrHealthResponse> getHealth() async {
    final response = await _client.get(
      UrlPCVKAPI.buildAzureEndpoint('ocr/health'),
    );
    if (response.statusCode == 200) {
      return OcrHealthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch health - ${response.statusCode}');
    }
  }

  Future<OcrResponse> recognizeText(File picture) async {
    final uri = UrlPCVKAPI.buildAzureEndpoint('ocr/recognize');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        picture.path,
        contentType: http.MediaType('image', ''),
      ),
    );
    final response = await _client.send(request);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(await response.stream.bytesToString());
      return OcrResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to predict - ${response.statusCode}');
    }
  }
}
