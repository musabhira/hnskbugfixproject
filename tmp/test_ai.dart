import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const String apiKey =
      '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';
  const String baseUrl = 'https://openrouter.ai/api/v1';

  print('Testing OpenRouter API Key...');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/key'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('Token is VALID.');
    } else {
      print('Token is INVALID or EXPIRED.');
    }

    // Test a basic completion
    print('\nTesting Basic Completion (google/gemini-2.0-flash-exp:free)...');
    final completionResponse = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'google/gemini-2.0-flash-exp:free',
        'messages': [
          {'role': 'user', 'content': 'Say hello!'}
        ],
      }),
    );

    print('Completion Status: ${completionResponse.statusCode}');
    if (completionResponse.statusCode == 200) {
      print('Completion Body: ${completionResponse.body}');
      print('AI is WORKING.');
    } else {
      print('Completion Failed: ${completionResponse.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
