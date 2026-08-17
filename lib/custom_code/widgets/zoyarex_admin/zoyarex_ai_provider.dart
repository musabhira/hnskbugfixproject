import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class ZoyarexChatMessage {
  final String text;
  final bool isUser;

  ZoyarexChatMessage({required this.text, required this.isUser});
}

class ZoyarexAiState {
  final List<ZoyarexChatMessage> messages;
  final List<Map<String, dynamic>> rawHistory;
  final bool isTyping;
  final bool isAuthenticated;
  final String? errorMessage;
  final bool isListening;
  final bool speechEnabled;
  final String spokenText;

  ZoyarexAiState({
    this.messages = const [],
    this.rawHistory = const [],
    this.isTyping = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.isListening = false,
    this.speechEnabled = false,
    this.spokenText = '',
  });

  ZoyarexAiState copyWith({
    List<ZoyarexChatMessage>? messages,
    List<Map<String, dynamic>>? rawHistory,
    bool? isTyping,
    bool? isAuthenticated,
    String? errorMessage,
    bool? isListening,
    bool? speechEnabled,
    String? spokenText,
  }) {
    return ZoyarexAiState(
      messages: messages ?? this.messages,
      rawHistory: rawHistory ?? this.rawHistory,
      isTyping: isTyping ?? this.isTyping,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
      isListening: isListening ?? this.isListening,
      speechEnabled: speechEnabled ?? this.speechEnabled,
      spokenText: spokenText ?? this.spokenText,
    );
  }
}

class ZoyarexAiNotifier extends Notifier<ZoyarexAiState> {
  final AiService _aiService = AiService();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _shouldSpeakNextResponse = false;

  final List<Map<String, dynamic>> _tools = [
    {
      'type': 'function',
      'function': {
        'name': 'get_all_branches',
        'description': 'Retrieves a list of all active branches in the Zoyarex POS system.',
        'parameters': {
          'type': 'object',
          'properties': {}
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_sales_report',
        'description': 'Retrieves a sales report from Zoyarex Supabase.',
        'parameters': {
          'type': 'object',
          'properties': {
            'branch_name': {'type': 'string', 'description': 'Optional. The name of the branch.'}
          }
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_all_products',
        'description': 'Retrieves a list of all products in the Zoyarex POS system.',
        'parameters': {
          'type': 'object',
          'properties': {
            'limit': {'type': 'integer', 'description': 'Optional. Max number of products to return (default 20).'}
          }
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_recent_orders',
        'description': 'Retrieves the most recent orders from the POS system.',
        'parameters': {
          'type': 'object',
          'properties': {
            'limit': {'type': 'integer', 'description': 'Optional. Max number of orders to return (default 10).'}
          }
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_all_tables',
        'description': 'Retrieves all tables and their current status.',
        'parameters': {
          'type': 'object',
          'properties': {}
        }
      }
    }
  ];

  @override
  ZoyarexAiState build() {
    _initSpeech();
    _initTts();
    _checkSavedCredentials();
    return ZoyarexAiState(
      messages: [
        ZoyarexChatMessage(text: 'Hello! I am your Zoyarex AI Assistant. Let me check your login status...', isUser: false),
      ],
      rawHistory: [
        {
          'role': 'system',
          'content': 'You are Zoyarex AI, a helpful virtual assistant that manages the Zoyarex ERP/POS system. You can fetch data directly from Supabase. Format data clearly. You must be able to understand and speak in Malayalam fluently when requested.'
        }
      ],
    );
  }

  Future<void> _initSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        final enabled = await _speechToText.initialize();
        state = state.copyWith(speechEnabled: enabled);
      }
    } catch (e) {
      debugPrint("Zoyarex speech recognition failed to init: $e");
    }
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("ml-IN");
      await _flutterTts.setSpeechRate(0.55);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint("Zoyarex TTS failed to init: $e");
    }
  }

  Future<void> _checkSavedCredentials() async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) {
      state = state.copyWith(
        messages: [...state.messages, ZoyarexChatMessage(text: 'Error: You must be logged into PocketMates first.', isUser: false)],
      );
      return;
    }

    try {
      final res = await SupaFlow.client
          .from('zoyarex_credentials')
          .select('email, password')
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        final email = res['email'];
        final password = res['password'];
        
        final response = await ZoyarexSupabase.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.session != null) {
          state = state.copyWith(
            isAuthenticated: true,
            messages: [...state.messages, ZoyarexChatMessage(text: 'Successfully authenticated to Zoyarex! How can I help you today?', isUser: false)],
          );
        } else {
          state = state.copyWith(
            messages: [...state.messages, ZoyarexChatMessage(text: 'Failed to authenticate to Zoyarex. Please login manually first.', isUser: false)],
          );
        }
      } else {
        state = state.copyWith(
          messages: [...state.messages, ZoyarexChatMessage(text: 'No saved Zoyarex credentials found. Please login via the Zoyarex POS Admin page first.', isUser: false)],
        );
      }
    } catch (e) {
      state = state.copyWith(
        messages: [...state.messages, ZoyarexChatMessage(text: 'Error authenticating: $e', isUser: false)],
      );
    }
  }

  void startListening() async {
    if (state.speechEnabled) {
      state = state.copyWith(isListening: true, spokenText: '');
      await _flutterTts.stop();

      await _speechToText.listen(
        onResult: (result) {
          state = state.copyWith(spokenText: result.recognizedWords);
          
          if (result.finalResult) {
            _shouldSpeakNextResponse = true;
            sendMessage(result.recognizedWords);
          }
        },
      );
    }
  }

  void stopListening() async {
    state = state.copyWith(isListening: false);
    await _speechToText.stop();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = {'role': 'user', 'content': text};
    
    state = state.copyWith(
      messages: [...state.messages, ZoyarexChatMessage(text: text, isUser: true)],
      rawHistory: [...state.rawHistory, userMessage],
      isTyping: true,
      isListening: false,
    );

    try {
      if (!state.isAuthenticated) {
        await _speak('I cannot run queries until you are authenticated.');
        state = state.copyWith(
          messages: [...state.messages, ZoyarexChatMessage(text: 'I cannot run queries until you are authenticated.', isUser: false)],
          isTyping: false,
        );
        return;
      }

      final response = await _aiService.sendMessage(
        messages: state.rawHistory,
        tools: _tools,
      );

      final choice = response['choices'][0];
      final message = choice['message'];
      
      state = state.copyWith(
        rawHistory: [...state.rawHistory, message],
      );

      if (message['tool_calls'] != null) {
        for (final toolCall in message['tool_calls']) {
          final call = toolCall['function'];
          final name = call['name'];
          final args = call['arguments'] is String ? jsonDecode(call['arguments']) : call['arguments'];
          
          String toolResultString = '';

          if (name == 'get_all_branches') {
            try {
              final query = await ZoyarexSupabase.client
                  .from('branches')
                  .select('branch_name, is_open')
                  .applyTenantFilter('branches');
              toolResultString = 'Found ${query.length} branches:\n';
              for (var row in query) {
                final isOpen = row['is_open'] == true;
                toolResultString += '- ${row['branch_name']} (${isOpen ? 'Open' : 'Closed'})\n';
              }
            } catch(e) {
              toolResultString = 'Sorry, I could not fetch the branches right now. Error: $e';
            }
          } else if (name == 'get_sales_report') {
            try {
              final query = await ZoyarexSupabase.client
                  .from('pos_orders')
                  .select('total_amount')
                  .applyTenantFilter('pos_orders')
                  .limit(50);
              double total = 0;
              for (var row in query) {
                 total += double.tryParse(row['total_amount']?.toString() ?? '0') ?? 0;
              }
              toolResultString = 'Analyzed recent orders. Total sales volume: \$${total.toStringAsFixed(2)}.';
            } catch(e) {
              toolResultString = 'Sorry, I could not fetch the sales right now.';
            }
          } else if (name == 'get_all_products') {
            try {
              final limit = (args['limit'] as num?)?.toInt() ?? 20;
              final query = await ZoyarexSupabase.client
                  .from('pos_products')
                  .select('product_name, cost, status')
                  .applyTenantFilter('pos_products')
                  .limit(limit);
              toolResultString = 'Found ${query.length} products:\n';
              for (var row in query) {
                toolResultString += '- ${row['product_name']} (\$${row['cost']}) [${row['status']}]\n';
              }
            } catch(e) {
              toolResultString = 'Sorry, I could not fetch the products right now. Error: $e';
            }
          } else if (name == 'get_recent_orders') {
            try {
              final limit = (args['limit'] as num?)?.toInt() ?? 10;
              final query = await ZoyarexSupabase.client
                  .from('pos_orders')
                  .select('id, total_amount, status')
                  .applyTenantFilter('pos_orders')
                  .order('created_at', ascending: false)
                  .limit(limit);
              toolResultString = 'Recent $limit orders:\n';
              for (var row in query) {
                toolResultString += 'Order #${row['id']}: \$${row['total_amount']} (${row['status']})\n';
              }
            } catch(e) {
              toolResultString = 'Sorry, I could not fetch recent orders right now. Error: $e';
            }
          } else if (name == 'get_all_tables') {
            try {
              final query = await ZoyarexSupabase.client
                  .from('pos_tables')
                  .select('table_number, capacity')
                  .applyTenantFilter('pos_tables');
              toolResultString = 'Available Tables:\n';
              for (var row in query) {
                toolResultString += 'Table ${row['table_number']} (Capacity: ${row['capacity']})\n';
              }
            } catch(e) {
              toolResultString = 'Sorry, I could not fetch tables right now. Error: $e';
            }
          }
          
          await _speak(toolResultString);
          state = state.copyWith(
            messages: [...state.messages, ZoyarexChatMessage(text: toolResultString, isUser: false)],
            rawHistory: [...state.rawHistory, {
              'role': 'tool',
              'tool_call_id': toolCall['id'],
              'content': toolResultString
            }]
          );
        }
      } else if (message['content'] != null) {
        await _speak(message['content']);
        state = state.copyWith(
          messages: [...state.messages, ZoyarexChatMessage(text: message['content'], isUser: false)],
        );
      }
    } catch (e) {
      await _speak('Sorry, I encountered an error.');
      state = state.copyWith(
        messages: [...state.messages, ZoyarexChatMessage(text: 'Sorry, I encountered an error: $e', isUser: false)],
      );
    }

    state = state.copyWith(isTyping: false);
  }

  Future<void> _speak(String text) async {
    if (_shouldSpeakNextResponse) {
      _shouldSpeakNextResponse = false;
      await _flutterTts.speak(text);
    }
  }
}

final zoyarexAiProvider = NotifierProvider<ZoyarexAiNotifier, ZoyarexAiState>(() {
  return ZoyarexAiNotifier();
});
