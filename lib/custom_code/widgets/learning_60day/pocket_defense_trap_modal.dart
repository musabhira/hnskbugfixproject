import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_defense_admin_modal.dart';
import 'pocket_fortress_defense_service.dart';

class PocketDefenseTrapModal extends StatefulWidget {
  final int userDay;

  const PocketDefenseTrapModal({
    super.key,
    required this.userDay,
  });

  static void show(BuildContext context, int userDay) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF070B14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PocketDefenseTrapModal(userDay: userDay),
    );
  }

  @override
  State<PocketDefenseTrapModal> createState() => _PocketDefenseTrapModalState();
}

class _PocketDefenseTrapModalState extends State<PocketDefenseTrapModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HouseShieldQuestion> _questions = [];
  List<String> _activeTraps = [];
  int _selectedTrapIdx = 0;
  HouseDefenseStatus _houseStatus = const HouseDefenseStatus();
  bool _isLoading = true;
  bool _isBanned = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final status = await PocketFortressDefenseService.getHouseStatus(widget.userDay);
    final qList = await PocketFortressDefenseService.loadShieldQuestions(widget.userDay);
    final activeTraps = await PocketFortressDefenseService.getActiveShieldTraps(widget.userDay);
    final banned = await PocketFortressDefenseService.isHouseBanned('me');
    if (mounted) {
      setState(() {
        _houseStatus = status;
        _questions = qList;
        _activeTraps = activeTraps;
        if (_selectedTrapIdx >= activeTraps.length) {
          _selectedTrapIdx = 0;
        }
        _isBanned = banned || status.isBanned;
        _isLoading = false;
      });
    }
  }

  void _openAddEditDialog({int? editIndex, String? preselectedTrapType}) {
    if (_isBanned) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Row(
            children: const [
              Icon(Icons.gavel_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('🚫 നിങ്ങളുടെ വീട് അഡ്മിൻ ബാൻ ചെയ്തിരിക്കുന്നു! ചോദ്യങ്ങൾ മാറ്റാൻ കഴിയില്ല.'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final isEdit = editIndex != null;
    final existing = isEdit ? _questions[editIndex] : null;

    final qCtrl = TextEditingController(text: existing?.question ?? '');
    final expCtrl = TextEditingController(text: existing?.explanation ?? '');
    final opCtrls = List.generate(
      4,
      (i) => TextEditingController(
        text: (existing != null && i < existing.options.length) ? existing.options[i] : '',
      ),
    );
    int selectedCorrect = existing?.correctIndex ?? 0;
    String chosenTrapType = preselectedTrapType ??
        existing?.trapType ??
        (_activeTraps.isNotEmpty ? _activeTraps[_selectedTrapIdx.clamp(0, _activeTraps.length - 1)] : 'vocab_gate');
    PresidentVerdict? liveVerdict;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) {
          void runPresidentCheck() {
            final qText = qCtrl.text.trim();
            final ops = opCtrls.map((c) => c.text.trim()).toList();
            setDState(() {
              liveVerdict = PocketFortressDefenseService.validateQuestion(qText, ops, selectedCorrect);
            });
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Shield Trap #${editIndex + 1}' : 'Add New Shield Trap',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // President AI Verification Banner
                  if (liveVerdict != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: liveVerdict!.isApproved
                            ? const Color(0xFF064E3B)
                            : (liveVerdict!.isWarning ? const Color(0xFF78350F) : const Color(0xFF7F1D1D)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: liveVerdict!.isApproved
                              ? const Color(0xFF10B981)
                              : (liveVerdict!.isWarning ? Colors.amber : Colors.redAccent),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(liveVerdict!.sealIcon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  liveVerdict!.title,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  liveVerdict!.feedback,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Gate Assignment Selector
                  Row(
                    children: [
                      const Text('Gate:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1E293B),
                          value: chosenTrapType,
                          isExpanded: true,
                          style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
                          underline: const SizedBox(),
                          items: kDefenseTrapTemplates.map((tmpl) {
                            return DropdownMenuItem(
                              value: tmpl.id,
                              child: Text('${tmpl.icon} ${tmpl.title} (${tmpl.titleMalayalam})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setDState(() => chosenTrapType = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Question Input
                  const Text('English Defense Question (30s Challenge):',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: qCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (_) => runPresidentCheck(),
                    decoration: InputDecoration(
                      hintText: 'e.g., What is the exact antonym of "Meticulous"?',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4 Options
                  const Text('4 Answer Options (Tap radio to mark correct answer):',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 6),
                  ...List.generate(4, (i) {
                    final isCorrect = selectedCorrect == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isCorrect ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isCorrect ? const Color(0xFF10B981) : Colors.white38,
                              size: 20,
                            ),
                            onPressed: () {
                              setDState(() => selectedCorrect = i);
                              runPresidentCheck();
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: opCtrls[i],
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              onChanged: (_) => runPresidentCheck(),
                              decoration: InputDecoration(
                                hintText: 'Option ${i + 1}',
                                hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                                filled: true,
                                fillColor: const Color(0xFF1E293B),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),

                  // Explanation
                  const Text('Explanation / Learning Rule:',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: expCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'e.g., "Careless" is the direct antonym.',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final qText = qCtrl.text.trim();
                  final ops = opCtrls.map((c) => c.text.trim()).toList();
                  final verdict = PocketFortressDefenseService.validateQuestion(qText, ops, selectedCorrect);

                  if (verdict.isBanThreat) {
                    HapticFeedback.vibrate();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🚨 PRESIDENT REJECTED: ${verdict.feedback}', style: GoogleFonts.outfit()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  final tmpl = kDefenseTrapTemplates.firstWhere(
                    (t) => t.id == chosenTrapType,
                    orElse: () => kDefenseTrapTemplates[0],
                  );

                  final newQ = HouseShieldQuestion(
                    id: existing?.id ?? 'q_${DateTime.now().millisecondsSinceEpoch}',
                    question: qText,
                    options: ops,
                    correctIndex: selectedCorrect,
                    explanation: expCtrl.text.trim(),
                    category: tmpl.category,
                    trapType: chosenTrapType,
                    isPresidentApproved: true,
                  );

                  setState(() {
                    if (isEdit) {
                      _questions[editIndex] = newQ;
                    } else {
                      _questions.add(newQ);
                    }
                  });

                  final messenger = ScaffoldMessenger.of(context);
                  await PocketFortressDefenseService.saveShieldQuestions(_questions);
                  if (ctx.mounted) Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('✅ Presidential Seal Approved & Shield Armored!', style: GoogleFonts.outfit()),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                },
                child: const Text('SAVE & DEPLOY', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeTemplateDialog(int trapIndex) {
    if (_isBanned) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🔄', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Select Gate Game Template',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: kDefenseTrapTemplates.length,
            itemBuilder: (context, i) {
              final tmpl = kDefenseTrapTemplates[i];
              final isCurrentlyEquipped = _activeTraps.contains(tmpl.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrentlyEquipped ? tmpl.themeColor.withValues(alpha: 0.15) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isCurrentlyEquipped ? tmpl.themeColor : Colors.white12),
                ),
                child: ListTile(
                  leading: Text(tmpl.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(tmpl.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${tmpl.titleMalayalam} • ${tmpl.description}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  trailing: isCurrentlyEquipped
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    setState(() {
                      _activeTraps[trapIndex] = tmpl.id;
                    });
                    await PocketFortressDefenseService.setActiveShieldTraps(_activeTraps);
                    HapticFeedback.selectionClick();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxAllowed = PocketFortressDefenseService.getMaxQuestionsForStage(widget.userDay);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              const Text('🏰', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POCKET FORTRESS DEFENSE VAULT',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Day ${widget.userDay} • $maxAllowed Max Shield Question Slots • Iron Dome & Army',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => PocketDefenseAdminModal.show(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF854D0E), Color(0xFF713F12)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade400, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('⚖️', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        'Admin Court',
                        style: GoogleFonts.outfit(
                          color: Colors.amber.shade200,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF0284C7),
            indicatorWeight: 3,
            labelColor: const Color(0xFF38BDF8),
            unselectedLabelColor: Colors.white60,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [
              Tab(text: '🛡️ Shield Slots'),
              Tab(text: '⚡ Iron Dome & Army'),
              Tab(text: '🎩 President Decree'),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShieldQuestionsTab(maxAllowed),
                  _buildIronDomeAndArmyTab(),
                  _buildPresidentDecreeTab(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: SHIELD QUESTIONS (STAGE-SCALED)
  // ==========================================
  Widget _buildShieldQuestionsTab(int maxAllowed) {
    final questionsPerGame = PocketFortressDefenseService.getQuestionsPerGameForStage(widget.userDay);
    final activeCount = _activeTraps.length;
    final selectedTrapId = _activeTraps.isNotEmpty
        ? _activeTraps[_selectedTrapIdx.clamp(0, _activeTraps.length - 1)]
        : 'vocab_gate';
    final selectedTemplate = kDefenseTrapTemplates.firstWhere(
      (t) => t.id == selectedTrapId,
      orElse: () => kDefenseTrapTemplates[0],
    );

    // Filter questions for currently selected trap
    final trapQuestions = _questions.where((q) {
      return q.trapType == selectedTrapId || q.category == selectedTemplate.category;
    }).toList();

    return Column(
      children: [
        // Banned Notice Banner if house is banned
        if (_isBanned)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7F1D1D), Color(0xFF450A0A)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.redAccent, width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🚫', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRESIDENTIAL BAN IN EFFECT',
                        style: GoogleFonts.outfit(
                          color: Colors.red.shade200,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ഫേക്ക് അല്ലെങ്കിൽ തെറ്റായ ചോദ്യങ്ങൾ റിപ്പോർട്ട് ചെയ്യപ്പെട്ടതിനാൽ നിങ്ങളുടെ വീട് അഡ്മിൻ ബാൻ ചെയ്തിരിക്കുന്നു. കോട്ട സംരക്ഷണം താൽക്കാലികമായി റദ്ദാക്കി.',
                        style: TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Fair-Play Advisory Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('⚖️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ഫെയർ പ്ലേ: യഥാർത്ഥ ചോദ്യങ്ങൾ മാത്രം നൽകുക. എതിരാളികൾക്ക് ഫേക്ക് ചോദ്യങ്ങൾ റിപ്പോർട്ട് ചെയ്യാം; അഡ്മിൻ റിവ്യൂവിൽ വീട് ബാൻ ചെയ്യപ്പെടും!',
                  style: GoogleFonts.outfit(
                    color: Colors.amber.shade200,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stage & Quota Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '🛡️ STAGE ${widget.userDay} DEFENSE SYSTEM',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF818CF8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${_questions.length} / $maxAllowed Total Armed',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildQuotaBadge('🏰 Active Gates', '$activeCount / ${PocketFortressDefenseService.getUnlockedGamesCountForStage(widget.userDay)}'),
                  const SizedBox(width: 8),
                  _buildQuotaBadge('🎯 Target / Gate', '$questionsPerGame Qs'),
                  const SizedBox(width: 8),
                  _buildQuotaBadge('⏱️ Challenge Time', '30s / Question'),
                ],
              ),
            ],
          ),
        ),

        // Horizontal Gate Selector Bar
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _activeTraps.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final trapId = _activeTraps[i];
              final tmpl = kDefenseTrapTemplates.firstWhere(
                (t) => t.id == trapId,
                orElse: () => kDefenseTrapTemplates[0],
              );
              final isSelected = i == _selectedTrapIdx;
              final gateQCount = _questions.where((q) => q.trapType == trapId || q.category == tmpl.category).length;

              return InkWell(
                onTap: () {
                  setState(() => _selectedTrapIdx = i);
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tmpl.themeColor.withValues(alpha: 0.22)
                        : const Color(0xFF1E293B).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? tmpl.themeColor : Colors.white12,
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: tmpl.themeColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(tmpl.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                'GATE ${i + 1}: ${tmpl.title}',
                                style: GoogleFonts.outfit(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showChangeTemplateDialog(i),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.cyanAccent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$gateQCount / $questionsPerGame Qs Armed',
                            style: TextStyle(
                              color: gateQCount >= questionsPerGame ? const Color(0xFF10B981) : Colors.amber.shade300,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Selected Gate Management Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selectedTemplate.themeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selectedTemplate.themeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(selectedTemplate.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GATE ${_selectedTrapIdx + 1}: ${selectedTemplate.title} (${selectedTemplate.titleMalayalam})',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      selectedTemplate.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Change template icon
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.tune_rounded, size: 14, color: Colors.amber),
                label: const Text('Change', style: TextStyle(color: Colors.amber, fontSize: 11)),
                onPressed: () => _showChangeTemplateDialog(_selectedTrapIdx),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Questions List for this Gate
        Expanded(
          child: trapQuestions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(selectedTemplate.icon, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(
                          'No custom questions for ${selectedTemplate.title} yet.',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Arm this defense gate with custom questions or load high-quality curated challenges below!',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            side: const BorderSide(color: Color(0xFF38BDF8)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: Text(
                            'LOAD CURATED DEFAULT QUESTIONS',
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final curated = PocketFortressDefenseService.getCuratedQuestionsForTrap(selectedTrapId);
                            setState(() {
                              for (final cq in curated) {
                                if (!_questions.any((q) => q.question == cq.question)) {
                                  _questions.add(cq);
                                }
                              }
                            });
                            await PocketFortressDefenseService.saveShieldQuestions(_questions);
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: trapQuestions.length,
                  itemBuilder: (context, i) {
                    final q = trapQuestions[i];
                    final originalIdx = _questions.indexOf(q);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selectedTemplate.themeColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: selectedTemplate.themeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'TRAP #${i + 1} (${q.category.toUpperCase()})',
                                  style: GoogleFonts.outfit(
                                    color: selectedTemplate.themeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('🏅 President Seal', style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                                onPressed: () => _openAddEditDialog(
                                  editIndex: originalIdx != -1 ? originalIdx : null,
                                  preselectedTrapType: selectedTrapId,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                onPressed: () {
                                  setState(() {
                                    if (originalIdx != -1) {
                                      _questions.removeAt(originalIdx);
                                    } else {
                                      _questions.remove(q);
                                    }
                                  });
                                  PocketFortressDefenseService.saveShieldQuestions(_questions);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            q.question,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Correct: ${q.options[q.correctIndex]}',
                            style: TextStyle(color: Colors.greenAccent.shade400, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          if (q.explanation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '💡 ${q.explanation}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 6),

        // Add Button for This Gate
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedTemplate.themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_moderator_rounded, size: 18),
            label: Text(
              'ADD QUESTION TO ${selectedTemplate.title.toUpperCase()} (${trapQuestions.length}/$questionsPerGame)',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
            onPressed: () => _openAddEditDialog(preselectedTrapType: selectedTrapId),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotaBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: IRON DOME & ARMY
  // ==========================================
  Widget _buildIronDomeAndArmyTab() {
    return ListView(
      children: [
        // House HP Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('House Health Status:', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  Text('${_houseStatus.currentHp} / ${_houseStatus.maxHp} HP',
                      style: GoogleFonts.outfit(
                        color: _houseStatus.currentHp > 50 ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      )),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _houseStatus.hpPercentage,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                    _houseStatus.currentHp > 50 ? const Color(0xFF10B981) : Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_houseStatus.currentHp < 100)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.build_rounded, size: 16),
                    label: const Text('REPAIR HOUSE (+50 HP) • 30 COINS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final ok = await PocketFortressDefenseService.repairHouse();
                      if (!mounted) return;
                      if (ok) {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ House Repaired +50 HP!'), backgroundColor: Color(0xFF059669)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ Not enough Pocket Coins to repair!'), backgroundColor: Colors.orange),
                        );
                      }
                    },
                  ),
                )
              else
                Text('🛡️ House is fully repaired and fortified.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Iron Dome Defense
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF131D31),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IRON DOME ANTI-RAID SYSTEM',
                            style: GoogleFonts.outfit(color: const Color(0xFF00F0FF), fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          _houseStatus.hasIronDome
                              ? 'Active Tier ${_houseStatus.ironDomeTier}: Absorbs raid damage'
                              : 'Not installed. Install to intercept raids!',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final ok = await PocketFortressDefenseService.purchaseIronDome(tier: _houseStatus.ironDomeTier + 1);
                    if (!mounted) return;
                    if (ok) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🛡️ Iron Dome Upgraded & Active!'), backgroundColor: Color(0xFF0284C7)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Need 75 Coins to upgrade Iron Dome!'), backgroundColor: Colors.orange),
                      );
                    }
                  },
                  child: Text(
                    _houseStatus.hasIronDome ? 'UPGRADE IRON DOME (75 COINS)' : 'INSTALL IRON DOME (75 COINS)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Army Knights
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF131D31),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STATIONED ARMY GUARDS',
                            style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${_houseStatus.armyKnightsCount} Guards stationed at front staircase.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final ok = await PocketFortressDefenseService.enlistArmyKnights();
                    if (!mounted) return;
                    if (ok) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚔️ +2 Royal Guards Stationed!'), backgroundColor: Color(0xFFB45309)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Need 40 Coins to enlist Guards!'), backgroundColor: Colors.orange),
                      );
                    }
                  },
                  child: const Text('ENLIST +2 GUARDS (40 COINS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: PRESIDENT ANTI-CHEAT DECREE
  // ==========================================
  Widget _buildPresidentDecreeTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('🎩', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 6),
          Text(
            'OFFICIAL DECREE: PRESIDENT OF POCKET WORLD',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              '“Attention citizens! Pocket World is a competitive English learning ground. '
              'Every shield question you deploy to protect your house must be an authentic, '
              'educational English challenge.\n\n'
              'If you attempt to write fake, impossible, or gibberish questions to prevent others from breaching your gate, '
              'my automated AI audit will flag your house with an Official Warning.\n\n'
              'Repeated violations will result in an immediate BAN, resetting your fortress progress back to Day 0!”',
              style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 16),
                const SizedBox(width: 6),
                Text(
                  'AI Anti-Cheat Monitor Active 24/7',
                  style: GoogleFonts.outfit(color: const Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
