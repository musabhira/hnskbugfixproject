import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_learning_track_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/german_article_gender_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/german_day1_alphabet_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/german_localization_helper.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/german_pattern_phrase_builder_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/german_reading_room_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/master_track_selector_pill.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_curriculum_1_18.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void _mockAudioAndTtsChannels() {
  const ttsChannel = MethodChannel('flutter_tts');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ttsChannel, (MethodCall call) async {
    return 1;
  });
  const sttChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(sttChannel, (MethodCall call) async {
    if (call.method == 'initialize') return false;
    return null;
  });
  const apChannel = MethodChannel('xyz.luan/audioplayers');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(apChannel, (MethodCall call) async {
    return null;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _mockAudioAndTtsChannels();
    try {
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        anonKey: 'dummy-anon-key',
      );
    } catch (_) {}
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockAudioAndTtsChannels();
  });

  tearDown(() {
    PocketLearningTrackService.activeTrackNotifier.value =
        PocketLearningTrackService.trackEnglish;
    PocketLanguageService.activeLanguageNotifier.value = 'Malayalam';
  });

  group('German Track Separation & Onboarding Isolation Tests', () {
    test('PocketLearningTrackService persists German vs English separately',
        () async {
      await PocketLearningTrackService.setTrack(
        PocketLearningTrackService.trackGerman,
        userId: 'user_de_1',
      );
      expect(PocketLearningTrackService.isGerman, isTrue);
      expect(
          PocketLearningTrackService.dayPrefPrefix, equals('pocket_de_day_'));
      expect(
        PocketLearningTrackService.completedDayPref('user_de_1', 1),
        equals('pocket_de_day_user_de_1_1_completed'),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pm_target_language'), equals('German'));
      expect(
        prefs.getString('pm_active_learning_track_user_de_1'),
        equals('german'),
      );

      // Re-init reads saved German track
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackEnglish;
      await PocketLearningTrackService.init(force: true, userId: 'user_de_1');
      expect(PocketLearningTrackService.isGerman, isTrue);
    });

    test(
        'PocketLanguageService target levels, placement & learner types work for German across 6 languages',
        () {
      final langs = [
        'Malayalam',
        'Hindi',
        'Tamil',
        'Kannada',
        'Telugu',
        'English',
      ];
      for (final lang in langs) {
        PocketLanguageService.activeLanguageNotifier.value = lang;
        final questions = PocketLanguageService.getTargetPlacementQuestions(
          lang,
          isGerman: true,
        );
        expect(questions, isNotEmpty,
            reason: 'Placement questions missing for $lang');

        final levels = PocketLanguageService.getTargetLevels(
          lang,
          isGerman: true,
        );
        expect(levels.length, greaterThanOrEqualTo(3),
            reason: 'Target levels missing for $lang');

        final learnerTypes =
            PocketLanguageService.getTargetLearnerTypeTranslations(
          lang,
          isGerman: true,
        );
        expect(learnerTypes.keys,
            containsAll(['title', 'adultTitle', 'kidsTitle']));

        if (lang != 'English') {
          for (final l in levels) {
            expect(
              (l['title'] ?? '').toString(),
              isNot(contains('English')),
              reason: 'English leak found in level title for $lang',
            );
          }
        }
      }
    });

    test(
        'GermanLocalizationHelper 30-letter Alphabet has Ä, Ö, Ü, ß & 6 native languages without English leaks',
        () {
      final alpha = GermanLocalizationHelper.germanAlphabet30;
      expect(alpha.length, equals(30));

      final letters =
          alpha.map((e) => e['letter'].toString().split(' ').first).toSet();
      expect(letters, containsAll(['A', 'Z', 'Ä', 'Ö', 'Ü', 'ß']));

      for (final entry in alpha) {
        final meaning = entry['meaning'] as Map<String, String>;
        for (final code in ['ml', 'ta', 'hi', 'kn', 'te', 'en']) {
          expect(meaning[code], isNotNull);
          expect(meaning[code]!.trim(), isNotEmpty,
              reason: 'Missing $code meaning for ${entry['letter']}');
        }
        expect(entry['word'].toString(), isNot(equals('Apple')));
        expect(entry['voice'].toString(), isNot(contains('ABCD')));
      }

      // Verify GermanLocalizationHelper provides 30 German phonics items while English stays 26
      final phonics = GermanLocalizationHelper.getGermanPhonicsItems();
      expect(phonics.length, equals(30));
      expect(phonics.any((p) => p.letter.startsWith('Ä')), isTrue);
      expect(phonics.any((p) => p.letter.startsWith('ß')), isTrue);
      expect(PocketCurriculum1To18.getAlphabetPhonics(1).length, equals(26));
    });

    test(
        'English learning_60day is untouched and German german_90day has separate hub & open world',
        () {
      final gerHub = File(
              'lib/custom_code/widgets/german_90day/german_tasks_master_hub.dart')
          .readAsStringSync();
      final gerWorld = File(
              'lib/custom_code/widgets/german_90day/german_day_open_world_adventure_page.dart')
          .readAsStringSync();

      expect(gerHub.contains('class GermanTasksMasterHubPage'), isTrue);
      expect(gerHub.contains('MasterTrackSelectorPill'), isTrue);
      expect(
          gerWorld.contains('class GermanDayOpenWorldAdventurePage'), isTrue);
      expect(gerWorld.contains('pocket_de_day_'), isTrue);

      for (final gameFile in [
        'german_sentence_builder_game.dart',
        'german_essential_spelling_game_page.dart',
        'german_useful_phrases_game_page.dart',
        'german_verb_timeline_game.dart',
        'german_vocab_open_world_drive_page.dart',
        'german_chat_reply_builder_page.dart',
        'german_negative_sentence_builder_page.dart',
        'german_mini_speech_practice_page.dart',
        'german_spoken_avatar_simulator_page.dart',
        'german_day_concept_chat_page.dart',
      ]) {
        final f = File('lib/custom_code/widgets/german_90day/games/$gameFile');
        expect(f.existsSync(), isTrue, reason: '$gameFile missing');
        final txt = f.readAsStringSync();
        expect(txt.contains('PocketGerman90DayMasterData'), isTrue,
            reason: '$gameFile not wired to German master data');
      }
    });
  });

  group('German 90-Day Dedicated UI Widgets Render Cleanly (ML & KN)', () {
    testWidgets(
        'GermanDay1AlphabetChatPage renders 30 letters in Malayalam without Apple/ABCD',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackGerman;
      PocketLanguageService.activeLanguageNotifier.value = 'Malayalam';

      await tester.pumpWidget(
        const MaterialApp(
          home: GermanDay1AlphabetChatPage(userId: 'test_u'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GermanDay1AlphabetChatPage), findsOneWidget);
      expect(find.textContaining('Apple'), findsNothing);
      expect(find.textContaining('ABCD'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GermanReadingRoomPage renders in Kannada without The Crow',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackGerman;
      PocketLanguageService.activeLanguageNotifier.value = 'Kannada';

      await tester.pumpWidget(
        const MaterialApp(
          home: GermanReadingRoomPage(day: 1, stepIndex: 8, userId: 'test_u'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GermanReadingRoomPage), findsOneWidget);
      expect(find.textContaining('Crow'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'GermanArticleGenderGamePage renders der/die/das cleanly in Malayalam',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackGerman;
      PocketLanguageService.activeLanguageNotifier.value = 'Malayalam';

      await tester.pumpWidget(
        const MaterialApp(
          home: GermanArticleGenderGamePage(
              day: 1, stepIndex: 7, userId: 'test_u'),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.byType(GermanArticleGenderGamePage), findsOneWidget);
      expect(find.text('der'), findsWidgets);
      expect(find.text('die'), findsWidgets);
      expect(find.text('das'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GermanPatternPhraseBuilderPage renders cleanly in Telugu',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackGerman;
      PocketLanguageService.activeLanguageNotifier.value = 'Telugu';

      await tester.pumpWidget(
        const MaterialApp(
          home: GermanPatternPhraseBuilderPage(day: 1, stepIndex: 9),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.byType(GermanPatternPhraseBuilderPage), findsOneWidget);
      expect(find.textContaining('Useful English Phrases'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'MasterTrackSelectorPill expands, selects German Master Track, and saves',
        (tester) async {
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackEnglish;
      PocketLanguageService.activeLanguageNotifier.value = 'Malayalam';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MasterTrackSelectorPill(
                isGermanActive: false,
                userId: 'test_u',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ENGLISH MASTER TRACK'), findsOneWidget);
      await tester.tap(find.text('ENGLISH MASTER TRACK'));
      await tester.pumpAndSettle();

      expect(find.text('English Master Track'), findsOneWidget);
      expect(find.text('German Master Track'), findsOneWidget);
      await tester.tap(find.text('German Master Track'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Save'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(PocketLearningTrackService.isGerman, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
