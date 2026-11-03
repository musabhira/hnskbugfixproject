import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_guard_service.dart';

void main() {
  group('PocketLanguageGuardService Tests', () {
    test('Personal Chat: allows standard English sentences', () {
      final res = PocketLanguageGuardService.checkPersonalChatMessage('Hello, how are you doing today?');
      expect(res.isValid, isTrue);
    });

    test('Personal Chat: allows short greetings and expressions', () {
      expect(PocketLanguageGuardService.checkPersonalChatMessage('Hi').isValid, isTrue);
      expect(PocketLanguageGuardService.checkPersonalChatMessage('OK').isValid, isTrue);
      expect(PocketLanguageGuardService.checkPersonalChatMessage('thanks').isValid, isTrue);
      expect(PocketLanguageGuardService.checkPersonalChatMessage('see you').isValid, isTrue);
    });

    test('Personal Chat: allows URLs and email addresses', () {
      expect(PocketLanguageGuardService.checkPersonalChatMessage('https://google.com/path').isValid, isTrue);
      expect(PocketLanguageGuardService.checkPersonalChatMessage('user@example.com').isValid, isTrue);
    });

    test('Personal Chat: confidently flags Malayalam script', () {
      final res = PocketLanguageGuardService.checkPersonalChatMessage('ഞാൻ ഇപ്പോൾ വരാം');
      expect(res.isValid, isFalse);
      expect(res.detectedWord, equals('Malayalam'));
    });

    test('Personal Chat: confidently flags Manglish (transliterated Malayalam)', () {
      final res = PocketLanguageGuardService.checkPersonalChatMessage('njan ipol varam');
      expect(res.isValid, isFalse);
      expect(res.detectedWord, contains('Malayalam'));
    });

    test('Personal Chat: confidently flags Hindi / Hinglish', () {
      final resHindi = PocketLanguageGuardService.checkPersonalChatMessage('आप कैसे हैं');
      expect(resHindi.isValid, isFalse);
      expect(resHindi.detectedWord, equals('Hindi'));

      final resHinglish = PocketLanguageGuardService.checkPersonalChatMessage('kya kar rahe ho');
      expect(resHinglish.isValid, isFalse);
      expect(resHinglish.detectedWord, contains('Hindi'));
    });

    test('Personal Chat: confidently flags German', () {
      final res = PocketLanguageGuardService.checkPersonalChatMessage('Guten morgen wie geht es dir');
      expect(res.isValid, isFalse);
      expect(res.detectedWord, equals('German'));
    });

    test('PocketGang: allows permitted languages (en + ml)', () {
      final resMl = PocketLanguageGuardService.checkGangMessage(
        text: 'ഞാൻ ഇപ്പോൾ വരാം',
        allowedLanguageCodes: ['en', 'ml'],
      );
      expect(resMl.isValid, isTrue);

      final resEn = PocketLanguageGuardService.checkGangMessage(
        text: 'Hello team let us meet at 4pm',
        allowedLanguageCodes: ['en', 'ml'],
      );
      expect(resEn.isValid, isTrue);
    });

    test('PocketGang: flags unpermitted language (Arabic when only en + ml are allowed)', () {
      final resAr = PocketLanguageGuardService.checkGangMessage(
        text: 'مرحبا كيف حالك',
        allowedLanguageCodes: ['en', 'ml'],
      );
      expect(resAr.isValid, isFalse);
      expect(resAr.detectedWord, equals('Arabic'));
    });
  });
}

