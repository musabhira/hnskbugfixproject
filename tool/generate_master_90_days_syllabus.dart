import 'dart:convert';
import 'dart:io';

/// Rebuilds the master index from the 90 canonical daily curriculum files.
/// Do not hand-edit master_90_days_syllabus.json; edit a daily file and run
/// this generator instead.
void main() {
  const root = 'assets/curriculum';
  final days = <Map<String, dynamic>>[];
  final houses = <int, Map<String, dynamic>>{};

  for (var day = 1; day <= 90; day++) {
    final source = File('$root/day_${day}_curriculum.json');
    final document = jsonDecode(source.readAsStringSync()) as Map<String, dynamic>;
    final course = document['course'] as Map<String, dynamic>;
    final grammar = document['grammarRule'] as Map<String, dynamic>? ?? const {};
    final vocabulary = document['vocabulary'] as Map<String, dynamic>? ?? const {};
    final steps = (document['steps'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final house = course['house'] as int;
    final houseTitle = course['houseTitle'] as Map<String, dynamic>? ?? const {};

    houses.putIfAbsent(house, () => {
          'house': house,
          'titleEn': houseTitle['en'] ?? 'House $house',
          'titleMl': houseTitle['ml'] ?? '',
          'dayRange': house == 1 ? 'Days 1–30' : house == 2 ? 'Days 31–60' : 'Days 61–90',
          'colorHex': house == 1 ? '#10B981' : house == 2 ? '#38BDF8' : '#A855F7',
          'gateExamDay': house * 30,
        });

    days.add({
      'day': day,
      'house': house,
      'topic': course['topic'],
      'themeEn': (course['topic'] as Map<String, dynamic>?)?['en'] ?? '',
      'themeMl': (course['topic'] as Map<String, dynamic>?)?['ml'] ?? '',
      'grammarTarget': grammar['formula'] ?? '',
      'grammarRule': grammar,
      'vocabulary': vocabulary,
      'gameMetadata': steps
          .map((step) => {
                'stepNumber': step['stepNumber'],
                'id': step['id'],
                'gameType': step['gameType'],
                if (step['targetObjects'] != null) 'targetObjects': step['targetObjects'],
                if (step['challengePatterns'] != null) 'challengePatterns': step['challengePatterns'],
                if (step['passScore'] != null) 'passScore': step['passScore'],
              })
          .toList(),
    });
  }

  final master = {
    'curriculum_version': '90_day_master_v3',
    'sourceOfTruth': 'assets/curriculum/day_{N}_curriculum.json',
    'title': 'Pocket Mates 90-Day Spoken English Master Roadmap',
    'houses': houses.values.toList()..sort((a, b) => (a['house'] as int).compareTo(b['house'] as int)),
    'days': days,
  };
  File('$root/master_90_days_syllabus.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(master));
  stdout.writeln('Generated ${days.length} canonical master syllabus entries.');
}
