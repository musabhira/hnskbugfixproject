import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_kids_service.dart';

/// 📅 Kids Routine Item Model
class KidRoutineItem {
  final String id;
  String time;
  String title;
  String desc;
  String icon;
  String category; // 'morning', 'afternoon', 'evening', 'night'
  bool isCompleted;
  int starReward;

  KidRoutineItem({
    required this.id,
    required this.time,
    required this.title,
    required this.desc,
    required this.icon,
    required this.category,
    this.isCompleted = false,
    this.starReward = 10,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'title': title,
        'desc': desc,
        'icon': icon,
        'category': category,
        'isCompleted': isCompleted,
        'starReward': starReward,
      };

  factory KidRoutineItem.fromJson(Map<String, dynamic> json) => KidRoutineItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        time: json['time'] ?? '08:00 AM',
        title: json['title'] ?? 'Task',
        desc: json['desc'] ?? '',
        icon: json['icon'] ?? '⭐',
        category: json['category'] ?? 'morning',
        isCompleted: json['isCompleted'] ?? false,
        starReward: json['starReward'] ?? 10,
      );
}

/// 📝 Kids Study Note Item Model
class KidStudyNote {
  final String id;
  String title;
  String subject;
  List<String> keyPoints;
  String date;
  String emoji;

  KidStudyNote({
    required this.id,
    required this.title,
    required this.subject,
    required this.keyPoints,
    required this.date,
    required this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'keyPoints': keyPoints,
        'date': date,
        'emoji': emoji,
      };

  factory KidStudyNote.fromJson(Map<String, dynamic> json) => KidStudyNote(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? 'Note',
        subject: json['subject'] ?? 'English',
        keyPoints: List<String>.from(json['keyPoints'] ?? []),
        date: json['date'] ?? 'Today',
        emoji: json['emoji'] ?? '💡',
      );
}

/// 🚀 Service handling Kids Daily Routine, Study Notes, PDF Generation & Sharing
class PocketKidsRoutinePdfService {
  static const String _prefRoutineKey = 'pocket_kids_daily_routine_v2';
  static const String _prefNotesKey = 'pocket_kids_study_notes_v2';

  /// Default Morning-to-Evening Routine for Kids
  static List<KidRoutineItem> getDefaultRoutines() {
    return [
      KidRoutineItem(
        id: 'r_1',
        time: '06:30 AM',
        title: 'Wake Up & Brush Teeth',
        desc: 'Rise and shine! Say "Good Morning!" with a smile ☀️',
        icon: '🌅',
        category: 'morning',
        starReward: 10,
      ),
      KidRoutineItem(
        id: 'r_2',
        time: '07:30 AM',
        title: 'Healthy Breakfast & English Word',
        desc: 'Eat nutritious food and learn 1 new word card 🍎',
        icon: '🍳',
        category: 'morning',
        starReward: 10,
      ),
      KidRoutineItem(
        id: 'r_3',
        time: '08:30 AM',
        title: 'School & Learning Journey',
        desc: 'Listen actively in class and be kind to classmates 🎒',
        icon: '🏫',
        category: 'morning',
        starReward: 15,
      ),
      KidRoutineItem(
        id: 'r_4',
        time: '01:30 PM',
        title: 'Lunch & Short Rest',
        desc: 'Recharge your energy and stay hydrated 🥪',
        icon: '🥛',
        category: 'afternoon',
        starReward: 10,
      ),
      KidRoutineItem(
        id: 'r_5',
        time: '04:30 PM',
        title: 'Outdoor Play & Sports',
        desc: 'Play fun games with friends in the playground ⚽',
        icon: '🎈',
        category: 'afternoon',
        starReward: 10,
      ),
      KidRoutineItem(
        id: 'r_6',
        time: '06:00 PM',
        title: 'Homework & 100-Day Mountain Game',
        desc: 'Climb 1 level on the Adventure Mountain Road 🏔️',
        icon: '🎮',
        category: 'evening',
        starReward: 20,
      ),
      KidRoutineItem(
        id: 'r_7',
        time: '07:30 PM',
        title: 'Pocket Gang Chat & Reading',
        desc: 'Chat in English with Animal Mates or Citadel challenge 🏰',
        icon: '💬',
        category: 'evening',
        starReward: 15,
      ),
      KidRoutineItem(
        id: 'r_8',
        time: '09:00 PM',
        title: 'Bedtime Story & Good Night',
        desc: 'Review flashcards, listen to a story & sweet dreams 🌙',
        icon: '⭐',
        category: 'night',
        starReward: 10,
      ),
    ];
  }

  /// Default Kids Study Notes
  static List<KidStudyNote> getDefaultNotes() {
    return [
      KidStudyNote(
        id: 'n_1',
        title: 'Magic Polite Words in English',
        subject: 'Spoken English',
        emoji: '🪄',
        date: 'Today',
        keyPoints: [
          '"Please" - When asking for anything politely.',
          '"Thank you" - When someone helps or gives you a gift.',
          '"Excuse me" - When you need someone\'s attention.',
          '"I\'m sorry" - When you make a mistake.',
        ],
      ),
      KidStudyNote(
        id: 'n_2',
        title: 'Brave Lion Kingdom Rules',
        subject: 'Adventure Values',
        emoji: '🦁',
        date: 'Today',
        keyPoints: [
          'Be brave: Speak English loudly and clearly without fear.',
          'Be kind: Always share toys and help younger mates.',
          'Never give up: If a word is hard, pronounce it syllable by syllable.',
        ],
      ),
      KidStudyNote(
        id: 'n_3',
        title: '5 Power Action Words (Verbs)',
        subject: 'Vocabulary',
        emoji: '⚡',
        date: 'Yesterday',
        keyPoints: [
          'Climb 🧗 - "I climb the 100-day mountain."',
          'Explore 🧭 - "We explore new cartoon houses."',
          'Protect 🛡️ - "I protect my castle citadel."',
          'Shine ⭐ - "Stars shine brightly in the night sky."',
        ],
      ),
    ];
  }

  /// Load routines from SharedPreferences
  static Future<List<KidRoutineItem>> loadRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefRoutineKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((e) => KidRoutineItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('Error loading routines: $e');
    }
    return getDefaultRoutines();
  }

  /// Save routines to SharedPreferences
  static Future<void> saveRoutines(List<KidRoutineItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_prefRoutineKey, raw);
    } catch (e) {
      debugPrint('Error saving routines: $e');
    }
  }

  /// Load notes from SharedPreferences
  static Future<List<KidStudyNote>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefNotesKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((e) => KidStudyNote.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
    return getDefaultNotes();
  }

  /// Save notes to SharedPreferences
  static Future<void> saveNotes(List<KidStudyNote> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_prefNotesKey, raw);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  /// 📄 Generate Beautiful Kids Routine & Study Notes PDF Document
  static Future<Uint8List> generateRoutineAndNotesPdf({
    required List<KidRoutineItem> routines,
    required List<KidStudyNote> notes,
  }) async {
    final doc = pw.Document();
    final kidName = PocketKidsService.kidName;
    final dayLevel = PocketKidsService.currentUnlockedDay;
    final kidStars = PocketKidsService.kidStars;
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    // Primary Colors for PDF
    final primaryColor = PdfColor.fromInt(0xFF0284C7); // Cyan Blue
    final accentGold = PdfColor.fromInt(0xFFF59E0B); // Amber Gold
    final darkNavy = PdfColor.fromInt(0xFF0F172A); // Midnight Slate
    final lightBg = PdfColor.fromInt(0xFFF8FAFC); // Clean Paper

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // 🌟 TOP HEADER BANNER
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(16),
                border: pw.Border.all(color: accentGold, width: 2),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'POCKET KIDS - DAILY ADVENTURE SCHEDULE',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Student Hero: $kidName  •  Level: Day $dayLevel  •  Date: $dateStr',
                        style: pw.TextStyle(
                          color: darkNavy,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: accentGold,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      '⭐ $kidStars STARS',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // 📅 SECTION 1: DAILY ROUTINE (Morning to Evening)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'DAILY ROUTINE & TIMETABLE (Morning to Evening)',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),

            // Routine Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
              columnWidths: {
                0: const pw.FixedColumnWidth(65),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FixedColumnWidth(50),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Routine Activity & Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Reward', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                ...routines.map((r) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(r.time, style: const pw.TextStyle(fontSize: 9.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(r.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                            if (r.desc.isNotEmpty) ...[
                              pw.SizedBox(height: 1),
                              pw.Text(r.desc, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                            ],
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('+${r.starReward} Stars', style: pw.TextStyle(fontSize: 9.5, color: accentGold, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(r.isCompleted ? '[x] Done' : '[ ] Pending', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),

            // 📝 SECTION 2: STUDY NOTES & KEY POINTS
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: accentGold,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'STUDENT STUDY NOTES & KEY POINTS',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),

            ...notes.map((n) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          n.title,
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                            color: darkNavy,
                          ),
                        ),
                        pw.Text(
                          '${n.subject} • ${n.date}',
                          style: const pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    ...n.keyPoints.map(
                      (pt) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                            pw.Expanded(
                              child: pw.Text(pt, style: const pw.TextStyle(fontSize: 9)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 14),

            // 🏆 PARENT / TEACHER SIGNATURE & BADGE FOOTER
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 1),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Parent / Mentor Signature: _______________________', style: const pw.TextStyle(fontSize: 9.5)),
                      pw.SizedBox(height: 4),
                      pw.Text('Daily Goal Met: [  ] Outstanding  [  ] Good  [  ] Needs Practice', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text(
                    'POCKET MATES KIDS CERTIFIED',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// 🖨️ Export & Preview PDF via Printing package
  static Future<void> printOrPreviewPdf({
    required BuildContext context,
    required List<KidRoutineItem> routines,
    required List<KidStudyNote> notes,
  }) async {
    HapticFeedback.lightImpact();
    final pdfBytes = await generateRoutineAndNotesPdf(
      routines: routines,
      notes: notes,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${PocketKidsService.kidName}_Routine_Timetable.pdf',
    );
  }

  /// 📲 One-tap Share PDF to WhatsApp, Mates, or other users
  static Future<void> sharePdfFile({
    required BuildContext context,
    required List<KidRoutineItem> routines,
    required List<KidStudyNote> notes,
  }) async {
    HapticFeedback.selectionClick();
    final pdfBytes = await generateRoutineAndNotesPdf(
      routines: routines,
      notes: notes,
    );

    final kidName = PocketKidsService.kidName;
    final fileName = '${kidName.replaceAll(' ', '_')}_Daily_Routine.pdf';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }

  /// 💬 One-tap Share Routine as formatted Text directly to WhatsApp or Mates
  static Future<void> shareRoutineAsText({
    required BuildContext context,
    required List<KidRoutineItem> routines,
  }) async {
    HapticFeedback.lightImpact();
    final kidName = PocketKidsService.kidName;
    final dayLevel = PocketKidsService.currentUnlockedDay;

    final buffer = StringBuffer();
    buffer.writeln('🌟 *Pocket Kids Daily Routine - $kidName* (Day $dayLevel) 🎒');
    buffer.writeln('Here is my daily schedule from morning to evening:');
    buffer.writeln('');

    for (final r in routines) {
      final check = r.isCompleted ? '✅' : '⏳';
      buffer.writeln('$check *${r.time}*: ${r.icon} ${r.title}');
      if (r.desc.isNotEmpty) {
        buffer.writeln('    _${r.desc}_');
      }
    }

    buffer.writeln('');
    buffer.writeln('⭐ Stars earned: ${PocketKidsService.kidStars} PTS');
    buffer.writeln('Powered by Pocket Mates Kids 🏰✨');

    await Share.share(buffer.toString());
  }
}
