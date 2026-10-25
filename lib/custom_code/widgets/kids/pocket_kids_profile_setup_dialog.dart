import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';

/// 👶 Kids Profile Setup & Diagnostic Onboarding Dialog
///
/// Displayed when switching from Adult / Student World to Kids World,
/// or when customizing the Kid Hero's profile from the Hero Tab:
/// - Kid's Name
/// - Kid's Age (Ages 4-8)
/// - English Fluency Level (Beginner / Explorer / Champion)
/// - Favorite Mascot Avatar (🦁, 🐼, 🐯, 🐰, 🐶)
/// - Hero Gender (Boy 👦 / Girl 👧 for PopArt Defense Cards)
class PocketKidsProfileSetupDialog extends StatefulWidget {
  final bool isEditMode;
  final VoidCallback? onCompleted;

  const PocketKidsProfileSetupDialog({
    super.key,
    this.isEditMode = false,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    bool isEditMode = false,
    VoidCallback? onCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: isEditMode,
      builder: (_) => PocketKidsProfileSetupDialog(
        isEditMode: isEditMode,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PocketKidsProfileSetupDialog> createState() =>
      _PocketKidsProfileSetupDialogState();
}

class _PocketKidsProfileSetupDialogState
    extends State<PocketKidsProfileSetupDialog> {
  final TextEditingController _nameController = TextEditingController();

  int _selectedAge = 5;
  String _selectedAvatar = '🦁';
  String _selectedGender = 'boy'; // 'boy' or 'girl'
  int _selectedFluencyIndex = 0; // 0 = Beginner ABC, 1 = Word Explorer, 2 = Sentence Star

  final List<int> _ages = [4, 5, 6, 7, 8];

  final List<Map<String, String>> _mascots = [
    {'emoji': '🦁', 'name': 'Leo'},
    {'emoji': '🐼', 'name': 'Pandy'},
    {'emoji': '🐯', 'name': 'Sparky'},
    {'emoji': '🐰', 'name': 'Bunny'},
    {'emoji': '🐶', 'name': 'Pip'},
  ];

  final List<Map<String, String>> _fluencyLevels = [
    {
      'title': '🐣 Starter Phonics',
      'desc': 'Learning alphabet letters, ABC sounds & colors',
      'level': 'starter',
    },
    {
      'title': '🐥 Word Explorer',
      'desc': 'Knows common animals, fruits & simple words',
      'level': 'explorer',
    },
    {
      'title': '🦁 Speaking Champion',
      'desc': 'Can say small phrases and understand easy questions',
      'level': 'champion',
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = PocketKidsService.kidName.isNotEmpty
        ? PocketKidsService.kidName
        : 'Little Hero';
    if (PocketKidsService.kidAvatar.isNotEmpty) {
      _selectedAvatar = PocketKidsService.kidAvatar;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndProceed() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your kid\'s name! 👶',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCorrectSound();

    await PocketKidsService.activateKidAccount(
      name: name,
      ageGroup: '$_selectedAge',
      avatar: _selectedAvatar,
      isParentSwitched: true,
      isPureKid: true,
    );

    if (!mounted) return;

    if (widget.isEditMode) {
      Navigator.pop(context);
      widget.onCompleted?.call();
    } else {
      Navigator.pop(context); // Close dialog
      PocketPureKidsHomePage.launch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9), // Pastel cream
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF38BDF8), width: 2.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('👶', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEditMode
                              ? 'Edit Kid Profile'
                              : 'Welcome to Kids World!',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Personalize name, age & spoken English level',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isEditMode)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Kid's Name Field
              Text(
                '1. What is your kid\'s name?',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: TextField(
                  controller: _nameController,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. Aryan, Diya, Kumi...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                    icon: const Text('🌟', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Age Selection
              Text(
                '2. How old is your kid?',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: _ages.map((age) {
                  final isSel = _selectedAge == age;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedAge = age);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF38BDF8) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Age $age',
                          style: GoogleFonts.outfit(
                            color: isSel ? Colors.white : const Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 3. Hero Avatar & Gender Choice
              Text(
                '3. Choose Hero Mascot & Gender',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 8),

              // Mascots Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _mascots.map((m) {
                  final isSel = _selectedAvatar == m['emoji'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedAvatar = m['emoji']!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFFEF3C7) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                          width: isSel ? 2.5 : 1.5,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(m['emoji']!, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Gender Selector for PopArt Defense Cards
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedGender = 'boy');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'boy'
                              ? const Color(0xFF38BDF8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedGender == 'boy'
                                ? const Color(0xFF0284C7)
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '👦 Hero Boy Card',
                          style: GoogleFonts.outfit(
                            color: _selectedGender == 'boy'
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedGender = 'girl');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'girl'
                              ? const Color(0xFFEC4899)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedGender == 'girl'
                                ? const Color(0xFFBE185D)
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '👧 Hero Girl Card',
                          style: GoogleFonts.outfit(
                            color: _selectedGender == 'girl'
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. English Fluency Diagnostic
              Text(
                '4. English Speaking Fluency',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 6),
              Column(
                children: List.generate(_fluencyLevels.length, (idx) {
                  final f = _fluencyLevels[idx];
                  final isSel = _selectedFluencyIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFluencyIndex = idx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFECFDF5) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                          width: isSel ? 2.0 : 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSel
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f['title']!,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  f['desc']!,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Launch Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                  onPressed: _saveAndProceed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isEditMode
                            ? 'Save Kid Profile ✨'
                            : 'Launch Kids World! 🚀',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
