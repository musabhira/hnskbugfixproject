import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_action_chat_service.dart';

/// 💬 Pocket Attack Message Composer Modal
/// Presented after Return to Home is tapped following a successful citadel raid.
/// Allows the attacker to select from ~10 predefined playful English challenge messages.
class PocketAttackMessageComposerModal extends StatefulWidget {
  final String attackerId;
  final String defenderId;
  final String defenderName;
  final String? attackEventId;
  final VoidCallback? onCompleted;

  const PocketAttackMessageComposerModal({
    super.key,
    required this.attackerId,
    required this.defenderId,
    required this.defenderName,
    this.attackEventId,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required String attackerId,
    required String defenderId,
    required String defenderName,
    String? attackEventId,
    VoidCallback? onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketAttackMessageComposerModal(
        attackerId: attackerId,
        defenderId: defenderId,
        defenderName: defenderName,
        attackEventId: attackEventId,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PocketAttackMessageComposerModal> createState() =>
      _PocketAttackMessageComposerModalState();
}

class _PocketAttackMessageComposerModalState
    extends State<PocketAttackMessageComposerModal> {
  // Predefined English challenge messages
  static const List<String> _predefinedMessages = [
    "Your house has been attacked! Can you defend it next time?",
    "I made it through your gates!",
    "That was an epic battle! Your turn to fight back.",
    "Your defenses were challenging. Ready for a rematch?",
    "I have reached your house. Can you take revenge?",
    "A successful attack! Now it's your turn.",
    "Your fortress needs stronger defenses!",
    "Come on, challenge me back!",
    "The battle is over. Your revenge starts now!",
    "Can you protect your house from my next attack?",
  ];

  int _selectedIndex = 0;
  bool _isSending = false;

  Future<void> _handleSend() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    final chosenText = _predefinedMessages[_selectedIndex];

    try {
      await PocketActionChatService.sendSelectedAttackChallengeMessage(
        attackerId: widget.attackerId,
        defenderId: widget.defenderId,
        messageText: chosenText,
        attackEventId: widget.attackEventId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Row(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Challenge message sent to ${widget.defenderName}!',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        widget.onCompleted?.call();
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onCompleted?.call();
      }
    }
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          left: BorderSide(color: Colors.white12, width: 1.0),
          right: BorderSide(color: Colors.white12, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text('💬', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send an Attack Message',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Send a playful challenge to ${widget.defenderName}',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleSkip,
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white60, size: 22),
                    tooltip: 'Skip',
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Message Options List
            Flexible(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _predefinedMessages.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final text = _predefinedMessages[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0284C7).withValues(alpha: 0.22)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : Colors.white10,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : Colors.white38,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Action Bar (Send & Skip)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPad + 14),
              child: Row(
                children: [
                  // Skip button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSending ? null : _handleSkip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send button
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSending ? null : _handleSend,
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _isSending ? 'Sending...' : 'Send Message',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

