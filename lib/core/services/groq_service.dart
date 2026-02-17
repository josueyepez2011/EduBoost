import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey =
      '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';
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(
      String message, List<Map<String, String>> history) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'Eres un tutor virtual inteligente y amigable para estudiantes de secundaria. Tu objetivo es ayudar con tareas, explicar conceptos difíciles, y motivar al estudiante. Siempre responde en español de manera clara y educativa.'
        },
        ...history,
        {
          'role': 'user',
          'content': message,
        }
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorBody = response.body;
        throw Exception('Error ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      print('Error detallado: $e');
      rethrow;
    }
  }
}
