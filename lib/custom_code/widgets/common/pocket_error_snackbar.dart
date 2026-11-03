import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 📋 Pocket Error SnackBar Helper
/// Provides structured, copyable error reporting for Supabase (PostgREST), network,
/// and client exceptions. Automatically sanitizes sensitive tokens and API keys.
class PocketErrorSnackBar {
  static void show(
    BuildContext context, {
    required dynamic error,
    String? fallbackMessage,
  }) {
    final parsed = _parseError(error, fallbackMessage: fallbackMessage);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parsed.displayTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (parsed.displaySubtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      parsed.displaySubtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Copy Error',
          textColor: const Color(0xFFFFFC00),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: parsed.fullCopyText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error details copied to clipboard 📋',
                  style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFFFFFC00),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  static _ParsedErrorInfo _parseError(dynamic error, {String? fallbackMessage}) {
    String code = '';
    String message = '';
    String details = '';
    String hint = '';

    if (error is PostgrestException) {
      code = error.code ?? 'PGRST';
      message = error.message;
      details = error.details?.toString() ?? '';
      hint = error.hint?.toString() ?? '';
    } else {
      final errStr = error.toString();
      final codeMatch = RegExp(r'(PGRST\d{3}|[A-Z0-9_]{5,})').firstMatch(errStr);
      if (codeMatch != null) {
        code = codeMatch.group(0)!;
      }
      message = fallbackMessage ?? errStr;
    }

    final sanitizedMessage = _sanitize(message.isNotEmpty ? message : (fallbackMessage ?? 'Unknown error'));
    final sanitizedDetails = _sanitize(details);
    final sanitizedHint = _sanitize(hint);

    final displayTitle = code.isNotEmpty ? '[$code] Error' : 'Notice';
    final displaySubtitle = sanitizedMessage;

    final fullCopy = StringBuffer();
    if (code.isNotEmpty) fullCopy.writeln('Code: $code');
    fullCopy.writeln('Message: $sanitizedMessage');
    if (sanitizedDetails.isNotEmpty) fullCopy.writeln('Details: $sanitizedDetails');
    if (sanitizedHint.isNotEmpty) fullCopy.writeln('Hint: $sanitizedHint');

    return _ParsedErrorInfo(
      code: code,
      displayTitle: displayTitle,
      displaySubtitle: displaySubtitle,
      fullCopyText: fullCopy.toString().trim(),
    );
  }

  static String _sanitize(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll(RegExp(r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'), '[REDACTED_TOKEN]')
        .replaceAll(RegExp(r'sbp_[a-zA-Z0-9]+'), '[REDACTED_KEY]')
        .replaceAll(RegExp(r'anon[_-]key[=: ]+[^\s]+'), 'anon_key=[REDACTED]');
  }
}

class _ParsedErrorInfo {
  final String code;
  final String displayTitle;
  final String displaySubtitle;
  final String fullCopyText;

  _ParsedErrorInfo({
    required this.code,
    required this.displayTitle,
    required this.displaySubtitle,
    required this.fullCopyText,
  });
}

