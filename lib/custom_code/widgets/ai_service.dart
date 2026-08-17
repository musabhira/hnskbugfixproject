import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AiService {
  static const String _openRouterKey = 'YOUR_OPENROUTER_API_KEY';
  
  final String apiKey;
  final String baseUrl;
  final List<String> models;

  AiService({
    this.apiKey = _openRouterKey,
    this.baseUrl = 'https://openrouter.ai/api/v1/chat/completions',
    this.models = const [
      'openai/gpt-oss-20b:free',
      'google/gemma-4-31b-it:free',
      'openrouter/free'
    ],
  });

  Future<Map<String, dynamic>> sendMessage({
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    for (String model in models) {
      try {
        final body = {
          'model': model,
          'messages': messages,
          'max_tokens': 1000, // Safeguard against credit reservation errors
        };

        if (tools != null && tools.isNotEmpty) {
          body['tools'] = tools;
          body['tool_choice'] = 'auto';
        }

        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://pocketmates.app', // Required by OpenRouter
            'X-Title': 'PocketMates AI', // Required by OpenRouter
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          debugPrint('Success with model: $model');
          return jsonDecode(response.body);
        } else if (response.statusCode == 429) {
          // Rate limited, try next model
          debugPrint('Rate limited on model: $model. Switching to next...');
          continue;
        } else {
          // Other error, try next model just in case, but usually means bad request
          debugPrint('AI Error on $model: ${response.statusCode} - ${response.body}');
          continue;
        }
      } catch (e) {
        debugPrint('AI Service Exception on $model: $e');
        continue;
      }
    }
    
    throw Exception('All AI models failed or rate limited.');
  }
}
