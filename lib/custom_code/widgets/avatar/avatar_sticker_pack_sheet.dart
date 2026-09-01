import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_widget.dart';
import 'avatar_comic_strip_page.dart';

/// Modal Bottom Sheet & Screen to view, send in chat, and share Personalized Avatar English Chat Stickers
class AvatarStickerPackSheet extends StatelessWidget {
  final VectorAvatarConfig config;
  final Function(AvatarStickerTemplate sticker)? onStickerSelected;

  const AvatarStickerPackSheet({
    super.key,
    required this.config,
    this.onStickerSelected,
  });

  static void show(
    BuildContext context,
    VectorAvatarConfig config, {
    Function(AvatarStickerTemplate sticker)? onStickerSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0E15),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => AvatarStickerPackSheet(
        config: config,
        onStickerSelected: onStickerSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stickers = VectorAvatarPalette.stickerTemplates;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0E15),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Avatar Chat Stickers 🎨',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      onStickerSelected != null
                          ? 'Tap a sticker to send directly in chat!'
                          : '12 Personalized stickers for Pocket Mates & WhatsApp',
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Comic Strip Banner Promo
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvatarComicStripPage(avatarConfig: config),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFFF9900)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create 3-Panel Avatar Comic Strip 📰',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Star in English comedy stories with your avatar!',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Grid of 12 Personalized Avatar Stickers
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: stickers.length,
              itemBuilder: (context, index) {
                final sticker = stickers[index];
                return _buildStickerCard(context, sticker);
              },
            ),
          ),

          // Footer Action
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text: 'Check out my custom Pocket Mates English Avatar! Let\'s practice English together: https://pocketmates.app',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.black, size: 20),
                  label: Text(
                    'Share Sticker Pack to WhatsApp',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerCard(BuildContext context, AvatarStickerTemplate sticker) {
    return GestureDetector(
      onTap: () {
        if (onStickerSelected != null) {
          onStickerSelected!(sticker);
          Navigator.pop(context);
        } else {
          _showStickerPreviewDialog(context, sticker);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: sticker.badgeColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: sticker.badgeColor.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Speech Bubble Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: sticker.badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sticker.badgeColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                sticker.speechText,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Live Customized Avatar
            Hero(
              tag: 'sticker_${sticker.id}',
              child: VectorAvatarWidget(
                config: config,
                size: 78,
                showAura: true,
              ),
            ),

            const SizedBox(height: 6),

            // Tag & Emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sticker.emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    sticker.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStickerPreviewDialog(BuildContext context, AvatarStickerTemplate sticker) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF161822),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speech bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sticker.badgeColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: sticker.badgeColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  sticker.speechText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Avatar
              VectorAvatarWidget(
                config: config,
                size: 140,
                showAura: true,
              ),

              const SizedBox(height: 20),

              // Copy / Use in Chat button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: sticker.speechText));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied "${sticker.speechText}"! Paste in chat.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                      label: Text(
                        'Copy Text',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: '${sticker.speechText}\n— Sent via Pocket Mates Avatar',
                          ),
                        );
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.send, size: 16, color: Colors.black),
                      label: Text(
                        'Send / Share',
                        style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
