import 'package:dio/dio.dart';
import '../../../shared/data/api_key_store.dart';

class MissingApiKey implements Exception {
  const MissingApiKey();
}

/// Pulls the answer text out of a Gemini generateContent response.
String parseGeminiText(Object? data) {
  if (data is Map) {
    final candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final content = (candidates.first as Map?)?['content'];
      final parts = content is Map ? content['parts'] : null;
      if (parts is List && parts.isNotEmpty) {
        final text = (parts.first as Map?)?['text'];
        if (text is String && text.trim().isNotEmpty) return text;
      }
    }
  }
  throw const FormatException('Empty or blocked AI response');
}

class GeminiRemoteSource {
  GeminiRemoteSource(this._dio, this._keys);

  // Check the current model name in Google AI Studio (see docs/ai-log.md).
  static const model = 'gemini-3.8-flash';
  static const _base = 'https://generativelanguage.googleapis.com/v1beta/models';

  final Dio _dio;
  final ApiKeyStore _keys;

  Future<String> generate({
    required String system,
    required List<Map<String, dynamic>> contents,
  }) async {
    final key = await _keys.read();
    if (key == null || key.isEmpty) throw const MissingApiKey();

    final res = await _dio.post(
      '$_base/$model:generateContent',
      options: Options(
        headers: {'x-goog-api-key': key, 'Content-Type': 'application/json'},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
      data: {
        'systemInstruction': {
          'parts': [
            {'text': system}
          ]
        },
        'contents': contents,
      },
    );
    return parseGeminiText(res.data);
  }
}
