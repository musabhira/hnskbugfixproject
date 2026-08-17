import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';

class AIBusinessAssistant extends StatefulWidget {
  final double? width;
  final double? height;

  const AIBusinessAssistant({super.key, this.width, this.height});

  @override
  State<AIBusinessAssistant> createState() => _AIBusinessAssistantState();
}

class _AIBusinessAssistantState extends State<AIBusinessAssistant>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _shimmerController;
  String _currentPlan = 'free';
  bool _isTyping = false;

  List<Map<String, String>> _messages = [];

  final List<Map<String, String>> _quickPrompts = [
    {
      'emoji': '💰',
      'label': 'Pricing Strategy',
      'prompt': 'How should I price my products/services to maximize profit while staying competitive?',
    },
    {
      'emoji': '📣',
      'label': 'Marketing Tips',
      'prompt': 'Give me 5 low-cost marketing strategies for a small business in India.',
    },
    {
      'emoji': '👥',
      'label': 'Attract Customers',
      'prompt': 'How can I attract more customers to my local business using social media?',
    },
    {
      'emoji': '📦',
      'label': 'Inventory Tips',
      'prompt': 'How do I manage inventory efficiently to avoid stockouts and overstocking?',
    },
    {
      'emoji': '🧾',
      'label': 'GST Basics',
      'prompt': 'Explain GST for small businesses in India. What do I need to know?',
    },
    {
      'emoji': '🚀',
      'label': 'Scale Up',
      'prompt': 'My business is doing well. What are the best steps to scale up and grow?',
    },
    {
      'emoji': '📊',
      'label': 'Read My Numbers',
      'prompt': 'What key metrics should I track daily to know if my business is healthy?',
    },
    {
      'emoji': '🤝',
      'label': 'Partner Strategy',
      'prompt': 'How do I find and approach the right business partners or distributors?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadHistory();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentPlan = prefs.getString('handskill_plan') ?? 'free';
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('ai_assistant_history');
    if (saved != null) {
      final decoded = jsonDecode(saved) as List;
      setState(() {
        _messages = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
      _scrollToBottom();
    } else {
      setState(() {
        _messages = [
          {
            'role': 'assistant',
            'content':
                'Hello! I\'m your **Handskill AI Business Assistant** 🤖\n\nI can help you with:\n• 💰 Pricing & profitability strategies\n• 📣 Marketing & customer acquisition\n• 📊 Understanding your business metrics\n• 🧾 Tax & GST guidance\n• 🚀 Growth & scaling advice\n\nWhat business challenge can I help you with today?',
          }
        ];
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_assistant_history', jsonEncode(_messages));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messageController.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text.trim()});
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final contents = _messages
          .where((m) => m['role'] != null && m['content'] != null)
          .map((m) => {
                'role': m['role'] == 'assistant' ? 'model' : 'user',
                'parts': [
                  {'text': m['content']}
                ]
              })
          .toList();

      final systemInstruction = '''You are an expert AI Business Consultant for small businesses, startups, and entrepreneurs in India. 
      You specialize in: POS systems, inventory management, pricing strategy, GST & tax basics, marketing for small businesses, 
      CRM and customer loyalty, business analytics, and growth strategies. 
      Keep responses concise, practical, and actionable. Use emojis occasionally for friendliness.
      Format key points as bullet points when helpful. Mention Indian context (₹, GST, UPI, etc.) where relevant.''';

      final payload = {
        'system_instruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
        },
      };

      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key') ?? '';

      if (apiKey.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        final response = _getLocalResponse(text);
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
          _isTyping = false;
        });
        await _saveHistory();
        _scrollToBottom();
        return;
      }

      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reply = decoded['candidates'][0]['content']['parts'][0]['text'] as String;
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _isTyping = false;
        });
        await _saveHistory();
        _scrollToBottom();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              '⚠️ I couldn\'t connect right now. Please check your internet connection and try again.\n\nTip: You can set your Gemini API key in settings for full AI capabilities.',
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  String _getLocalResponse(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains('price') || lower.contains('pricing')) {
      return '💰 **Pricing Strategy Tips:**\n\n• **Cost-plus pricing**: Add 20–40% margin to your total cost\n• **Competitor research**: Check what similar businesses charge\n• **Value-based pricing**: Charge based on the value you deliver, not just cost\n• **Tiered pricing**: Offer Basic / Standard / Premium options\n• **Psychological pricing**: Use ₹499 instead of ₹500 — it converts better\n\n💡 Rule of thumb: Your price should cover all costs + leave at least 25% net margin.';
    } else if (lower.contains('market') || lower.contains('customer') || lower.contains('attract')) {
      return '📣 **Low-Cost Marketing Strategies:**\n\n• **WhatsApp Business**: Share daily offers with your contacts\n• **Google My Business**: Free listing — gets you found on Google Maps\n• **Instagram Reels**: Show your product/service in 30-second videos\n• **Referral Program**: Give existing customers ₹50 discount for bringing a friend\n• **Local partnerships**: Partner with nearby complementary businesses\n\n🔑 Focus on 1–2 channels first and do them consistently.';
    } else if (lower.contains('gst') || lower.contains('tax')) {
      return '🧾 **GST Basics for Small Businesses:**\n\n• **Registration**: Required if annual turnover > ₹40 Lakhs (₹20L for services)\n• **GST Rates**: 0%, 5%, 12%, 18%, 28% depending on category\n• **GSTR-1**: File monthly/quarterly — sales invoices\n• **GSTR-3B**: Monthly — pay tax due\n• **Input Tax Credit**: Claim GST paid on your business purchases\n\n⚠️ Always issue proper GST invoices to your customers — Handskill POS does this automatically!';
    } else if (lower.contains('scale') || lower.contains('grow')) {
      return '🚀 **Steps to Scale Your Business:**\n\n1. **Systemize** — Document your processes so others can follow them\n2. **Hire** — Bring in help for repetitive tasks (delivery, billing, support)\n3. **Automate** — Use tools like Handskill to run billing, CRM, invoicing automatically\n4. **Add revenue streams** — Can you offer delivery? Subscription? Online sales?\n5. **Track your numbers** — Know your daily revenue, top products, and profit margin\n6. **Reinvest** — Put 30% of profits back into the business\n\n💡 The biggest mistake? Trying to scale before systemizing. Fix the process first.';
    } else if (lower.contains('inventory') || lower.contains('stock')) {
      return '📦 **Smart Inventory Management:**\n\n• **ABC Analysis**: Focus on your top 20% items that drive 80% of revenue\n• **Reorder Points**: Set minimum stock levels — reorder before running out\n• **FIFO**: First In, First Out — sell oldest stock first\n• **Dead Stock**: Items not sold in 60 days — discount them to free up cash\n• **Track Shrinkage**: Monitor theft or damage losses\n\n📊 Use Handskill\'s inventory tracker to get low-stock alerts automatically!';
    } else {
      return '🤖 **Business Insight:**\n\nGreat question! Here\'s what I recommend:\n\n• Focus on your **most profitable products/services** first\n• Track your **daily revenue and top customers** using your POS\n• Build **customer loyalty** through repeat orders and referrals\n• Always know your **cost before setting price**\n• Review your **P&L (Profit & Loss)** every week\n\n💡 The most successful small businesses win by being **consistent, customer-focused, and data-driven**.\n\n📝 Want a more specific answer? Tell me more about your business type and challenge!';
    }
  }

  void _clearHistory() {
    setState(() {
      _messages = [
        {
          'role': 'assistant',
          'content': 'History cleared! How can I help you with your business today? 🚀',
        }
      ];
    });
    SharedPreferences.getInstance().then((prefs) => prefs.remove('ai_assistant_history'));
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      controller.text = prefs.getString('gemini_api_key') ?? '';
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Gemini API Key', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your free Gemini API key from aistudio.google.com for full AI capabilities.',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('gemini_api_key', controller.text.trim());
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key saved! AI is now fully active.')),
                );
              }
            },
            child: Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A22),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Business Assistant',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Gemini AI',
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined, color: Colors.white54),
            onPressed: _showApiKeyDialog,
            tooltip: 'Set API Key',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
            onPressed: _clearHistory,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_messages.length <= 1)
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = _quickPrompts[index];
                      return GestureDetector(
                        onTap: () => _sendMessage(prompt['prompt']!),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E24),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(prompt['emoji']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                prompt['label']!,
                                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return _buildMessageBubble(msg['content']!, isUser);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                color: const Color(0xFF1A1A22),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A32),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Ask about pricing, marketing, GST...',
                            hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _sendMessage(_messageController.text),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_currentPlan == 'free')
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 64),
                      const SizedBox(height: 24),
                      Text(
                        'Premium AI Assistant',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Upgrade to unlock the AI Business Assistant\nand get expert startup advice.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())).then((_) {
                            _loadCurrentPlan();
                          });
                        },
                        icon: const Icon(Icons.workspace_premium),
                        label: Text('Upgrade Plan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF59E0B)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.black, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFFFD700) : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                content,
                style: GoogleFonts.outfit(
                  color: isUser ? Colors.black : Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white54, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF59E0B)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_alt_rounded, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (_, __) {
                    final offset = (i * 0.3);
                    final progress = (_shimmerController.value + offset) % 1.0;
                    final opacity = (progress < 0.5 ? progress * 2 : (1 - progress) * 2).clamp(0.2, 1.0);
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
