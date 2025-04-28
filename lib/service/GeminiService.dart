import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String? apiKey = dotenv.env['API_KEY']; 
  String get _endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

  static Future<String> askGemini(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(GeminiService()._endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text ?? 'No response from Gemini.';
      } else {
        return 'Failed to get response. Code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error contacting Gemini: $e';
    }
  }
}
