import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_service.dart';
import 'dart:convert';

class VoiceState {
  final bool isListening;
  final bool isThinking;
  final bool speechEnabled;
  final String spokenText;
  final String aiResponse;

  VoiceState({
    this.isListening = false,
    this.isThinking = false,
    this.speechEnabled = false,
    this.spokenText = '',
    this.aiResponse = '',
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isThinking,
    bool? speechEnabled,
    String? spokenText,
    String? aiResponse,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isThinking: isThinking ?? this.isThinking,
      speechEnabled: speechEnabled ?? this.speechEnabled,
      spokenText: spokenText ?? this.spokenText,
      aiResponse: aiResponse ?? this.aiResponse,
    );
  }
}

class PocketMatesVoiceNotifier extends Notifier<VoiceState> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final AiService _aiService = AiService();
  final List<Map<String, dynamic>> _rawHistory = [
    {
      'role': 'system',
      'content': 'You are PocketMates Voice AI, a helpful virtual assistant that controls the PocketMates app and the Zoyarex ERP module. Keep responses very short and conversational. When the user wants to go to a page, get data, send a message, or create a task, use the provided tools. You must be able to understand and speak in Malayalam fluently when requested.'
    }
  ];

  final List<Map<String, dynamic>> _tools = [
    {
      'type': 'function',
      'function': {
        'name': 'navigate_to',
        'description': 'Navigates the user to a specific page in the app.',
        'parameters': {
          'type': 'object',
          'properties': {
            'pageName': {'type': 'string', 'description': 'The name of the page to navigate to (e.g., "sales", "expenses", "users", "outlets", "home")'}
          },
          'required': ['pageName']
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_zoyarex_sales',
        'description': 'Retrieves a summary of sales data for the current tenant in Zoyarex.',
        'parameters': {
          'type': 'object',
          'properties': {
            'branch_name': {'type': 'string', 'description': 'Optional. The name of the branch to filter sales by.'}
          }
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'send_chat_message',
        'description': 'Sends a chat message to a specific user in PocketMates.',
        'parameters': {
          'type': 'object',
          'properties': {
            'username': {'type': 'string', 'description': 'The username to send the message to.'},
            'message': {'type': 'string', 'description': 'The message content.'}
          },
          'required': ['username', 'message']
        }
      }
    },
    {
      'type': 'function',
      'function': {
        'name': 'create_new_task',
        'description': 'Creates a new task in PocketMates.',
        'parameters': {
          'type': 'object',
          'properties': {
            'task_name': {'type': 'string', 'description': 'The title of the task.'},
            'deadline': {'type': 'string', 'description': 'Optional. The deadline of the task (e.g. "tomorrow", "next week").'}
          },
          'required': ['task_name']
        }
      }
    }
  ];

  @override
  VoiceState build() {
    _initSpeech();
    _initTts();
    return VoiceState();
  }

  Future<void> _initSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        final enabled = await _speechToText.initialize();
        state = state.copyWith(speechEnabled: enabled);
      }
    } catch (e) {
      debugPrint("Speech init error: $e");
    }
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint("Voice assistant TTS failed to init: $e");
    }
  }

  void startListening() async {
    if (state.speechEnabled) {
      state = state.copyWith(isListening: true, spokenText: '', aiResponse: '');
      await _flutterTts.stop();

      await _speechToText.listen(
        onResult: (result) {
          state = state.copyWith(spokenText: result.recognizedWords);
          
          if (result.finalResult) {
            _handleFinalSpeech(result.recognizedWords);
          }
        },
      );
    }
  }

  void stopListening() async {
    state = state.copyWith(isListening: false);
    await _speechToText.stop();
  }

  Future<void> _handleFinalSpeech(String text) async {
    state = state.copyWith(isListening: false, isThinking: true);

    _rawHistory.add({'role': 'user', 'content': text});

    try {
      final response = await _aiService.sendMessage(
        messages: _rawHistory,
        tools: _tools,
      );

      final choice = response['choices'][0];
      final message = choice['message'];
      
      _rawHistory.add(message);

      if (message['tool_calls'] != null) {
        for (final toolCall in message['tool_calls']) {
          final call = toolCall['function'];
          final name = call['name'];
          final args = call['arguments'] is String ? jsonDecode(call['arguments']) : call['arguments'];
          
          String toolResultString = '';

          if (name == 'navigate_to') {
            final page = args['pageName'] as String?;
            await _speak('Navigating to $page');
            toolResultString = 'Navigated to $page';
          } else if (name == 'get_zoyarex_sales') {
            try {
              final query = SupaFlow.client.from('gt_vouchers').select('total_amount').eq('voucher_type', 'sale');
              final data = await query;
              double total = 0;
              for (var row in data) {
                 total += double.tryParse(row['total_amount']?.toString() ?? '0') ?? 0;
              }
              await _speak('You have ${data.length} recent sales totaling \$${total.toStringAsFixed(2)}.');
              toolResultString = 'Reported ${data.length} sales totaling \$${total.toStringAsFixed(2)}';
            } catch(e) {
              await _speak('Sorry, I could not fetch the sales right now.');
              toolResultString = 'Failed to fetch sales: $e';
            }
          } else if (name == 'send_chat_message') {
            final user = args['username'] as String?;
            final msg = args['message'] as String?;
            await _speak('Message sent to $user saying: $msg');
            toolResultString = 'Sent message to $user';
          } else if (name == 'create_new_task') {
            final task = args['task_name'] as String?;
            final deadline = args['deadline'] as String?;
            await _speak('Created task: $task, due $deadline');
            toolResultString = 'Created task: $task';
          }

          _rawHistory.add({
            'role': 'tool',
            'tool_call_id': toolCall['id'],
            'content': toolResultString
          });
        }
      } else if (message['content'] != null) {
        await _speak(message['content']);
      }
    } catch (e) {
      await _speak('Sorry, I encountered an error connecting to Groq.');
      debugPrint('Groq Error: $e');
    }

    state = state.copyWith(isThinking: false);
  }

  Future<void> _speak(String text) async {
    state = state.copyWith(aiResponse: text);
    await _flutterTts.speak(text);
  }
}

final pocketMatesVoiceProvider = NotifierProvider<PocketMatesVoiceNotifier, VoiceState>(() {
  return PocketMatesVoiceNotifier();
});
