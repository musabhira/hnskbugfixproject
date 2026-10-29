import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('PocketLanguageService Multi-Language & Persistence Tests', () {
    test('Defaults and language switching to Tamil', () async {
      await PocketLanguageService.init(force: true);

      // Default before switching
      expect(PocketLanguageService.isTamil, isFalse);

      // Switch to Tamil
      await PocketLanguageService.setNativeLanguage('Tamil', userId: 'user_tamil_001');

      expect(PocketLanguageService.currentLanguage, 'Tamil');
      expect(PocketLanguageService.isTamil, isTrue);
      expect(PocketLanguageService.isMalayalam, isFalse);

      // Localized string returns Tamil
      final localized = PocketLanguageService.localize(
        en: 'Defenses Held Firm',
        ml: 'പ്രതിരോധം വിജയിച്ചു',
        ta: 'பாதுகாப்பு உறுதியாக நின்றது',
        hi: 'रक्षा मजबूत रही',
      );
      expect(localized, 'பாதுகாப்பு உறுதியாக நின்றது');
    });

    test('getVocabMeaning returns Tamil translations and NEVER Malayalam for Tamil users', () async {
      await PocketLanguageService.setNativeLanguage('Tamil', userId: 'user_tamil_001');

      // Test words from vocab bank
      expect(PocketLanguageService.getVocabMeaning('water'), 'தண்ணீர்');
      expect(PocketLanguageService.getVocabMeaning('apple'), 'ஆப்பிள்');
      expect(PocketLanguageService.getVocabMeaning('school'), 'பள்ளி');
      expect(PocketLanguageService.getVocabMeaning('friend'), 'நண்பர்');
      expect(PocketLanguageService.getVocabMeaning('mother'), 'அம்மா');

      // Ensure Malayalam character block is NEVER present in Tamil vocab meaning
      final malayalamRegex = RegExp(r'[\u0D00-\u0D7F]');
      expect(malayalamRegex.hasMatch(PocketLanguageService.getVocabMeaning('water')), isFalse);
      expect(malayalamRegex.hasMatch(PocketLanguageService.getVocabMeaning('school')), isFalse);
    });

    test('syncWithUserProfile syncs Supabase profile language to active runtime', () async {
      // Start as Malayalam
      await PocketLanguageService.setNativeLanguage('Malayalam', userId: 'user_profile_sync');
      expect(PocketLanguageService.isMalayalam, isTrue);

      // Simulate profile loaded from Supabase with native_language = 'Tamil'
      final profile = {
        'id': 'user_profile_sync',
        'display_name': 'Kavitha',
        'native_language': 'Tamil',
      };
      await PocketLanguageService.syncWithUserProfile(profile, userId: 'user_profile_sync');

      expect(PocketLanguageService.currentLanguage, 'Tamil');
      expect(PocketLanguageService.isTamil, isTrue);
      expect(PocketLanguageService.isMalayalam, isFalse);
    });

    test('User-specific storage keys persist and reload accurately', () async {
      SharedPreferences.setMockInitialValues({
        'pm_native_language_user_456': 'Tamil',
        'pm_native_language': 'Malayalam', // older global key should not override user-specific key
      });

      await PocketLanguageService.init(force: true, userId: 'user_456');
      expect(PocketLanguageService.currentLanguage, 'Tamil');
      expect(PocketLanguageService.isTamil, isTrue);
    });
  });
}
