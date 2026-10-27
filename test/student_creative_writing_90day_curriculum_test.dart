import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/letters_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/diaries_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/profiles_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/notices_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/emails_90.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/curriculum_90days/spellings_90.dart';

void main() {
  group('90-Day Student Creative Writing & Puzzle Curriculum Tests', () {
    test('All 6 curriculum lists have exactly 90 entries', () {
      expect(k90UniqueLetters.length, equals(90));
      expect(k90UniqueDiaries.length, equals(90));
      expect(k90UniqueProfiles.length, equals(90));
      expect(k90UniqueNotices.length, equals(90));
      expect(k90UniqueEmails.length, equals(90));
      expect(k90UniqueSpellings.length, equals(90));
    });

    test('Day 1 Profile is Founder Mus\'ab Hira with full bio details', () {
      final day1 = k90UniqueProfiles[0];
      expect(day1['name'], equals("Mus'ab Hira"));
      expect(day1['clues']['Born'], contains('Palakkad'));
      expect(day1['clues']['Founder'], contains('PoketMates'));
      expect(day1['clues']['Position'], contains('Handskill Art Community of India'));

      final profileData = StudentCreativeWriting90DayCurriculum.getProfileData(1);
      expect(profileData.heroName, equals("Mus'ab Hira"));
      expect(profileData.examClues['Born'], contains('Palakkad'));
      expect(profileData.examClues['Founder'], contains('PoketMates'));
      expect(profileData.sentences.isNotEmpty, isTrue);
    });

    test('Zero duplicate profiles across all 90 days', () {
      final names = k90UniqueProfiles.map((p) => p['name'] as String).toList();
      final uniqueNames = names.toSet();
      expect(uniqueNames.length, equals(90), reason: 'Duplicate profile names detected: ${names.length - uniqueNames.length}');
    });

    test('Zero duplicate spellings across all 90 days', () {
      final words = k90UniqueSpellings.map((s) => (s['correct'] as String).toLowerCase()).toList();
      final uniqueWords = words.toSet();
      expect(uniqueWords.length, equals(90), reason: 'Duplicate spelling words detected');
    });

    test('Zero duplicate notice titles across all 90 days', () {
      final titles = k90UniqueNotices.map((n) => n['title'] as String).toList();
      final uniqueTitles = titles.toSet();
      expect(uniqueTitles.length, equals(90), reason: 'Duplicate notice titles detected');
    });

    test('Zero duplicate email subjects across all 90 days', () {
      final subjects = k90UniqueEmails.map((e) => e['subjectCorrect'] as String).toList();
      final uniqueSubjects = subjects.toSet();
      expect(uniqueSubjects.length, equals(90), reason: 'Duplicate email subjects detected');
    });

    test('Zero duplicate diary prompts across all 90 days', () {
      final prompts = k90UniqueDiaries.map((d) => d['prompt'] as String).toList();
      final uniquePrompts = prompts.toSet();
      expect(uniquePrompts.length, equals(90), reason: 'Duplicate diary prompts detected');
    });

    test('Curriculum getters return valid populated data across all 90 days', () {
      for (int day = 1; day <= 90; day++) {
        final letter = StudentCreativeWriting90DayCurriculum.getLetterData(day);
        expect(letter.recipient.isNotEmpty, isTrue);
        expect(letter.line1Words.isNotEmpty, isTrue);
        expect(letter.line2Words.isNotEmpty, isTrue);

        final diary = StudentCreativeWriting90DayCurriculum.getDiaryData(day);
        expect(diary.dateStr.isNotEmpty, isTrue);
        expect(diary.sentence1Words.isNotEmpty, isTrue);

        final profile = StudentCreativeWriting90DayCurriculum.getProfileData(day);
        expect(profile.heroName.isNotEmpty, isTrue);
        expect(profile.sentences.isNotEmpty, isTrue);

        final notice = StudentCreativeWriting90DayCurriculum.getNoticeData(day);
        expect(notice.title.isNotEmpty, isTrue);
        expect(notice.targetParts.isNotEmpty, isTrue);

        final email = StudentCreativeWriting90DayCurriculum.getEmailData(day);
        expect(email.recipient.isNotEmpty, isTrue);
        expect(email.subjectCorrect.isNotEmpty, isTrue);

        final spelling = StudentCreativeWriting90DayCurriculum.getSpellingData(day);
        expect(spelling.wrongWord.isNotEmpty, isTrue);
        expect(spelling.correctWord.isNotEmpty, isTrue);
      }
    });
  });
}
