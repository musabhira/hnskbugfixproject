import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 📜 POCKET WORLD GAME RULES & 90-DAY SOVEREIGN CHARTER MODAL
///
/// Deeply explains:
/// 1. 90-Day Guaranteed Transformation & Completion Certificate (100% Fluency Assurance).
/// 2. The English Home & Home Defense Architecture (1 Day = 1 Defense Slot, Breaches, Loot).
/// 3. Direct Attack Raids (No Doorbell Delay) & Pocket Robo Fallback 🤖.
/// 4. 48-Hour Presidential Police Protection (Stationed Police Guards).
/// 5. Daily 40–60 Minute Practice Rule (The Focus Timer Commitment).
/// 6. Multi-Language Explanations (Malayalam, Tamil, Hindi, Telugu, Kannada, English).
/// 7. Interactive Sovereign Pledge Acceptance.
class PocketWorldGameRulesModal extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onPledgeAccepted;

  const PocketWorldGameRulesModal({
    super.key,
    this.currentDay = 1,
    this.onPledgeAccepted,
  });

  static Future<bool?> show(BuildContext context, {int currentDay = 1, VoidCallback? onPledgeAccepted}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketWorldGameRulesModal(
        currentDay: currentDay,
        onPledgeAccepted: onPledgeAccepted,
      ),
    );
  }

  @override
  State<PocketWorldGameRulesModal> createState() => _PocketWorldGameRulesModalState();
}

class _PocketWorldGameRulesModalState extends State<PocketWorldGameRulesModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLanguage = 'malayalam';
  bool _hasAcceptedPledge = false;
  bool _isSavingPledge = false;

  static const String kPrefsRulesAccepted = 'pocket_world_rules_accepted_v1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPledgeStatus();
  }

  Future<void> _loadPledgeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hasAcceptedPledge = prefs.getBool(kPrefsRulesAccepted) ?? false;
      });
    }
  }

  Future<void> _acceptPledge() async {
    setState(() => _isSavingPledge = true);
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsRulesAccepted, true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _hasAcceptedPledge = true;
        _isSavingPledge = false;
      });
      widget.onPledgeAccepted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sovereign Pledge Accepted! Your 90-Day English journey is locked in.',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 2)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                  ),
                  child: const Text('📜', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POCKET WORLD RULES & PLEDGE',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '90-Day English Mastery & Home Defense Charter',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Language Dropdown
                _buildLanguageSelector(),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF38BDF8),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11.5),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11.5),
              tabs: const [
                Tab(icon: Text('🎓'), text: '90-Day Guarantee'),
                Tab(icon: Text('🏠'), text: 'Home Defense'),
                Tab(icon: Text('⚔️'), text: 'Raids & Robo'),
                Tab(icon: Text('👮‍♂️'), text: 'President Guard'),
                Tab(icon: Text('⏱️'), text: '40-60m Immersion'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _build90DayGuaranteeTab(),
                _buildHomeDefenseTab(),
                _buildRaidsAndRoboTab(),
                _buildPresidentGuardTab(),
                _buildTimeCommitmentTab(),
              ],
            ),
          ),

          // Bottom Pledge Agreement Bar
          _buildPledgeAgreementFooter(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF38BDF8), size: 16),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          onChanged: (val) {
            if (val != null) setState(() => _selectedLanguage = val);
          },
          items: const [
            DropdownMenuItem(value: 'malayalam', child: Text('മലയാളം')),
            DropdownMenuItem(value: 'english', child: Text('English')),
            DropdownMenuItem(value: 'tamil', child: Text('தமிழ்')),
            DropdownMenuItem(value: 'hindi', child: Text('हिन्दी')),
            DropdownMenuItem(value: 'telugu', child: Text('తెలుగు')),
            DropdownMenuItem(value: 'kannada', child: Text('ಕನ್ನಡ')),
          ],
        ),
      ),
    );
  }

  // TAB 1: 90-Day Guarantee & Certificate
  Widget _build90DayGuaranteeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(
            badge: '100% FLUENCY ASSURANCE',
            title: _selectedLanguage == 'malayalam'
                ? '90 ദിവസം കൊണ്ട് പ്രൊഫഷണൽ ഇംഗ്ലീഷ് ഗ്യാരണ്ടി'
                : '100% Guaranteed Professional English Fluency in 90 Days',
            subtitle: _selectedLanguage == 'malayalam'
                ? '90 ദിവസത്തെ സമ്പൂർണ്ണ കരിക്കുലം പൂർത്തിയാക്കുന്ന ഓരോ പഠിതാവിനും ഒഫീഷ്യൽ സർട്ടിഫിക്കറ്റ് ലഭിക്കും. സംസാരത്തിലും എഴുത്തിലും 100% ആത്മവിശ്വാസം!'
                : 'Complete the 90-day progressive curriculum to unlock your official Certificate of Fluency Mastery. Professional speaking, grammar, and writing guaranteed.',
            icon: '🏆',
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 14),

          _buildSectionHeader('📈 4-Stage Progressive Transformation Matrix', const Color(0xFF38BDF8)),
          _buildProgressionStep(
            stage: 'STAGE 1 (Days 1–15)',
            tier: 'Foundation & Conversational Agility',
            desc: _selectedLanguage == 'malayalam'
                ? 'അടിസ്ഥാന വാക്യഘടന, ദിനചര്യകൾ, സംസാരിക്കാനുള്ള മടി മാറ്റൽ, 150 പുതിയ ഹൈ-ഇംപാക്ട് വാക്കുകൾ.'
                : 'Core S-V-O syntax, daily routines, breaking hesitation, 150 high-frequency spoken vocabulary words.',
            color: const Color(0xFF10B981),
            icon: '🌱',
          ),
          _buildProgressionStep(
            stage: 'STAGE 2 (Days 16–30)',
            tier: 'Nuanced Register & Polite Diplomacy',
            desc: _selectedLanguage == 'malayalam'
                ? 'നയതന്ത്ര മൃദുഭാഷണം (Softeners), Cleft Sentences, മിക്സഡ് കണ്ടീഷണലുകൾ, ശ്രോതാക്കളെ ആകർഷിക്കുന്ന സംസാരം.'
                : 'Diplomatic softeners, cleft sentences, mixed conditionals, persuasive conversational flow.',
            color: const Color(0xFF3B82F6),
            icon: '⚔️',
          ),
          _buildProgressionStep(
            stage: 'STAGE 3 (Days 31–60)',
            tier: 'Executive Spotlight & Leadership Oratory',
            desc: _selectedLanguage == 'malayalam'
                ? 'ഇന്റർവ്യൂ മാസ്റ്ററി (STAR ടെക്നിക്ക്), മീറ്റിംഗ് പ്രസന്റേഷൻ, നെഗറ്റീവ് ഇൻവേർഷൻ, തെറ്റ് കണ്ടെത്താനുള്ള കഴിവ്.'
                : 'Job interview mastery (STAR method), executive meetings, negative inversion, deep error detection.',
            color: const Color(0xFF8B5CF6),
            icon: '👑',
          ),
          _buildProgressionStep(
            stage: 'STAGE 4 (Days 61–90)',
            tier: 'Grandmaster Celestial & Global Eloquence',
            desc: _selectedLanguage == 'malayalam'
                ? 'ഉന്നത ഭരണതന്ത്ര വാഗ്മിത്വം, പോളിസി ചർച്ചകൾ, പ്രൊഫഷണൽ ഇംഗ്ലീഷ് സമ്പൂർണ്ണ സിദ്ധിയും ഒഫീഷ്യൽ സർട്ടിഫിക്കറ്റും!'
                : 'Sovereign diplomacy, constitutional jurisprudence, native executive presence + Accredited Day 90 Certificate!',
            color: const Color(0xFFFFD700),
            icon: '🐉',
          ),
        ],
      ),
    );
  }

  // TAB 2: Home Defense Concept
  Widget _buildHomeDefenseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(
            badge: 'POCKET WORLD SANCTUARY',
            title: _selectedLanguage == 'malayalam'
                ? 'എന്താണ് നിങ്ങളുടെ ഇംഗ്ലീഷ് വീട്? (Home Defense)'
                : 'What is Your English Home & Home Defense?',
            subtitle: _selectedLanguage == 'malayalam'
                ? 'പോക്കറ്റ് വേൾഡിൽ ഓരോ പഠിതാവിനും സ്വന്തമായി ഒരു വീടുണ്ട്. നിങ്ങൾ പഠിക്കുന്ന ഇംഗ്ലീഷ് ചോദ്യങ്ങളാണ് നിങ്ങളുടെ വീടിന്റെ കോട്ടമതിലുകൾ!'
                : 'In Pocket World, every learner owns a virtual home on the street. Your English skills are your castle walls!',
            icon: '🏠',
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 14),

          _buildRuleCard(
            title: '1 Day = 1 Defense Slot (ഹോം ഡിഫൻസ് സ്ലോട്ടുകൾ)',
            desc: _selectedLanguage == 'malayalam'
                ? 'Day 1 ൽ 1 ഡിഫൻസ് സ്ലോട്ട്. Day 10 ൽ 10 എണ്ണം. Day 90 ൽ 90 സ്ലോട്ടുകൾ (9 ഗേറ്റുകൾ)! ഓരോ ദിവസത്തെയും പാഠം വെച്ച് നിങ്ങൾ സ്വന്തം വീടിന് കാവലൊരുക്കുന്നു.'
                : 'Day 1 = 1 slot. Day 10 = 10 slots. Day 90 = 90 slots across 9 challenge gates! You arm your house with authentic English questions you learned.',
            icon: '🛡️',
          ),
          _buildRuleCard(
            title: 'House HP & Vault Coins (ആരോഗ്യവും നാണയങ്ങളും)',
            desc: _selectedLanguage == 'malayalam'
                ? 'ഓരോ വീടിനും 100 HP ഉണ്ട്. റൈഡർമാർ നിങ്ങളുടെ ഡിഫൻസ് ചോദ്യങ്ങൾ ശരിയായി ഉത്തരം നൽകി ബ്രീച്ച് ചെയ്താൽ 45 കോയിൻ നഷ്ടപ്പെടും. ചോദ്യങ്ങൾ പരാജയപ്പെട്ടാൽ അവർക്ക് നാശം!'
                : 'Every home has 100 HP. If an attacker solves your defense traps, they breach your vault for 45 coins. If they fail, their raid ends in defeat!',
            icon: '🪙',
          ),
          _buildRuleCard(
            title: 'No Complex Academic Jargon (ലളിതമായ പേര്)',
            desc: _selectedLanguage == 'malayalam'
                ? '"Citadel Defense Shield" പോലുള്ള കഠിനമായ വാക്കുകൾ മാറ്റി എല്ലാവർക്കും പെട്ടെന്ന് മനസ്സിലാകുന്ന "Home Defense" എന്ന് മാറ്റിയിരിക്കുന്നു.'
                : 'Confusing terms like "Citadel Defense Shield" are replaced with simple, crystal-clear "Home Defense" for effortless understanding.',
            icon: '✨',
          ),
        ],
      ),
    );
  }

  // TAB 3: Direct Raids & Pocket Robo
  Widget _buildRaidsAndRoboTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(
            badge: 'NO DOORBELL • DIRECT BATTLES',
            title: _selectedLanguage == 'malayalam'
                ? 'ഡയറക്റ്റ് അറ്റാക്കും പോക്കറ്റ് റോബോയും 🤖'
                : 'Direct Raids & Pocket Robo AI Fallback 🤖',
            subtitle: _selectedLanguage == 'malayalam'
                ? 'ബെല്ലടിക്കേണ്ട ആവശ്യമില്ല, നേരിട്ട് അറ്റാക്ക് ചെയ്യുക! നിങ്ങൾ ഉയർന്ന ലെവലിൽ എത്തുമ്പോൾ ശത്രുക്കൾ ഇല്ലെങ്കിൽ പോക്കറ്റ് റോബോ വരും!'
                : 'No doorbell delays. Direct action raids in the Battle Arena. If no peers exist at your level, Pocket Robo defends automatically!',
            icon: '⚔️',
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 14),

          _buildRuleCard(
            title: 'Direct Attack (ഡോർബെൽ ഇല്ലാതെ നേരിട്ട് അറ്റാക്ക്)',
            desc: _selectedLanguage == 'malayalam'
                ? 'വീട്ടിലേക്ക് നോക്കുക, അറ്റാക്ക് ബട്ടൺ ക്ലിക്ക് ചെയ്യുക. ബാറ്റിൽ അരീനയിൽ അവരുടെ ചോദ്യങ്ങൾ തോൽപ്പിച്ച് നാണയങ്ങൾ പിടിച്ചെടുക്കുക!'
                : 'Tap Attack on any neighbor. Step into the Battle Arena, conquer their defense traps, and claim vault loot!',
            icon: '⚡',
          ),
          _buildRuleCard(
            title: 'Pocket Robo 🤖 (പോക്കറ്റ് റോബോ കാവൽക്കാരൻ)',
            desc: _selectedLanguage == 'malayalam'
                ? 'നിങ്ങൾ ലെവൽ 18, 40, 60 ഒക്കെ എത്തുമ്പോൾ ആ ലെവലിൽ റിയൽ പ്ലെയേഴ്സ് ഇല്ലെങ്കിലും കളി നിന്നുപോകില്ല. പോക്കറ്റ് റോബോ ശരിയായ ലെവൽ ചോദ്യങ്ങളുമായി റെഡിയായി നിൽക്കും!'
                : 'When you advance to high levels where few human players exist, Pocket Robo automatically generates authentic level-matched challenges so progress never stops!',
            icon: '🤖',
          ),
          _buildRuleCard(
            title: 'Daily Attack Limit (ദിവസം 2 അറ്റാക്ക് മാത്രം)',
            desc: _selectedLanguage == 'malayalam'
                ? 'പഠനത്തിന് പ്രാധാന്യം നൽകാൻ ദിവസം പരമാവധി 2 അറ്റാക്കുകൾ മാത്രമേ അനുവദിക്കൂ. ഓരോ അറ്റാക്കും ഉയർന്ന ചിന്താശേഷി ആവശ്യപ്പെടുന്നു.'
                : 'Maximum 2 attacks per day to guarantee focused, quality learning over mindless spamming.',
            icon: '🎯',
          ),
        ],
      ),
    );
  }

  // TAB 4: 48-Hour Presidential Police Protection
  Widget _buildPresidentGuardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(
            badge: 'SECURITY ASSURANCE',
            title: _selectedLanguage == 'malayalam'
                ? '48-മണിക്കൂർ പ്രസിഡൻഷ്യൽ പോലീസ് പ്രൊട്ടക്ഷൻ 👮‍♂️'
                : '48-Hour Presidential Police Protection 👮‍♂️',
            subtitle: _selectedLanguage == 'malayalam'
                ? 'ഒരു തവണ വീട് ബ്രീച്ച് ചെയ്യപ്പെട്ടാൽ ഉടൻ പോലീസ് കാവൽ നിലവിൽ വരും. 48 മണിക്കൂർ ആരും നിങ്ങളെ അറ്റാക്ക് ചെയ്യില്ല!'
                : 'Once your home is breached in a raid, it enters 48-hour Presidential Immunity with stationed police guards so you can rebuild in peace.',
            icon: '👮‍♂️',
            color: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 14),

          _buildRuleCard(
            title: 'Stationed Police Guards (പോലീസ് കാവൽ)',
            desc: _selectedLanguage == 'malayalam'
                ? 'ബ്രീച്ച് ചെയ്യപ്പെട്ട വീട്ടിൽ പോലീസ് കാവൽക്കാരുടെ ചിഹ്നം തെളിയും. മറ്റ് പ്ലെയേഴ്സിന് ആ വീട് അറ്റാക്ക് ചെയ്യാൻ കഴിയില്ല.'
                : 'A prominent Presidential Guard barrier appears on the house. Rivals cannot raid or loot while protection is active.',
            icon: '🛡️',
          ),
          _buildRuleCard(
            title: 'Peaceful Recovery Period (സുരക്ഷിതമായി പുനർനിർമ്മിക്കുക)',
            desc: _selectedLanguage == 'malayalam'
                ? 'തുടരെത്തുടരെ അറ്റാക്ക് ചെയ്യപ്പെട്ട് നാണയങ്ങൾ നഷ്ടപ്പെടില്ല. 48 മണിക്കൂറിനുള്ളിൽ നിങ്ങളുടെ ചുമരുകൾ നന്നാക്കാനും പുതിയ ചോദ്യങ്ങൾ സ്ഥാപിക്കാനും സമയം ലഭിക്കും.'
                : 'Prevents repeated farming. You have full 48 hours to study daily lessons, repair your walls, and arm new traps without fear.',
            icon: '🕊️',
          ),
          _buildRuleCard(
            title: 'President Call Anti-Cheat (പ്രസിഡന്റ് റിപ്പോർട്ടിംഗ്)',
            desc: _selectedLanguage == 'malayalam'
                ? 'ആരെങ്കിലും മോശം വാക്കുകളോ നിലവാരമില്ലാത്ത തെറ്റായ ചോദ്യങ്ങളോ സ്ഥാപിച്ചാൽ "President Call" വഴി റിപ്പോർട്ട് ചെയ്യാം. നിയമനടപടികൾ ഉടൻ ഉണ്ടാകും.'
                : 'Encounter offensive or nonsense defense questions? Report them via President Call for instant review and penalties.',
            icon: '📞',
          ),
        ],
      ),
    );
  }

  // TAB 5: 40-60 Minute Immersion Commitment
  Widget _buildTimeCommitmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(
            badge: 'DAILY FOCUS PROTOCOL',
            title: _selectedLanguage == 'malayalam'
                ? 'എന്തിനാണ് ഡെയിലി 40–60 മിനിറ്റ് ടൈമർ? ⏱️'
                : 'Why the Daily 40–60 Minute Study Timer? ⏱️',
            subtitle: _selectedLanguage == 'malayalam'
                ? 'ഇംഗ്ലീഷ് മനസ്സിൽ ഉറയ്ക്കണമെങ്കിൽ ദിവസേന 40 മുതൽ 60 മിനിറ്റ് വരെ ശ്രദ്ധയോടെയുള്ള പരിശീലനം അത്യന്താപേക്ഷിതമാണ്. ഇത് വെറുമൊരു ഗെയിമല്ല, വിദ്യാഭ്യാസമാണ്!'
                : 'Fluency requires consistent daily cognitive immersion. Spending 40 to 60 minutes daily ensures irreversible neurological language wiring.',
            icon: '⏱️',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 14),

          _buildRuleCard(
            title: 'Automatic Focus Timer (ഫോക്കസ് ടൈമർ പ്രവർത്തനം)',
            desc: _selectedLanguage == 'malayalam'
                ? 'നിങ്ങൾ ആപ്പിൽ പഠിക്കുമ്പോൾ ടൈമർ തനിയെ സമയം കണക്കാക്കും. ബാക്ക്ഗ്രൗണ്ടിലേക്ക് പോയാൽ ടൈമർ തനിയെ പോസ് ആകും. സത്യസന്ധമായ പരിശീലനം മാത്രം!'
                : 'The timer runs only while you are actively learning inside the app. Backgrounding pauses the timer automatically to ensure genuine practice.',
            icon: '⏳',
          ),
          _buildRuleCard(
            title: 'Multi-Skill Daily Habit (വായന, എഴുത്ത്, സംസാരം)',
            desc: _selectedLanguage == 'malayalam'
                ? '• 📚 റീഡിങ് ലൈബ്രറി: കഥകളും കവിതകളും വായിക്കുക\n• 🗣️ സ്പീക്കിംഗ്: ഡ്യുവൽ വോയിസ് പ്രാക്ടീസ്\n• ⚡ കോഡ് ഇംഗ്ലീഷ്: ഫോർമുലകൾ വെച്ച് വ്യാകരണം ഓർക്കുക\n• ✍️ റൈറ്റിംഗ്: സ്വന്തം ചിന്തകൾ ഇംഗ്ലീഷിൽ കുറിക്കുക'
                : '• 📚 Reading Library: Books, stories, poems\n• 🗣️ Speaking: AI Voice duels & roleplays\n• ⚡ Code English: Grammar formula mnemonics\n• ✍️ Writing: Daily reflective sentences',
            icon: '📖',
          ),
          _buildRuleCard(
            title: 'Reward for 40-60 Min Completion (പ്രതിഫലം)',
            desc: _selectedLanguage == 'malayalam'
                ? 'ദിവസേന ടാർഗെറ്റ് തികയ്ക്കുമ്പോൾ +50 ബോണസ് കോയിനുകളും സ്ട്രീക്ക് പോയിന്റുകളും ലഭിക്കും. 90 ദിവസവും പൂർത്തിയാക്കാൻ ഇത് നിങ്ങളെ സഹായിക്കും!'
                : 'Completing your 40-60 min daily target awards +50 Bonus Coins and keeps your sovereign streak alive toward the Day 90 Certificate!',
            icon: '💎',
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildHeroBanner({
    required String badge,
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.outfit(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProgressionStep({
    required String stage,
    required String tier,
    required String desc,
    required Color color,
    required String icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      stage,
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '• $tier',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String desc,
    required String icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPledgeAgreementFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasAcceptedPledge)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'You have accepted the 90-Day Sovereign English Pledge',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10B981),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSavingPledge ? null : _acceptPledge,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasAcceptedPledge
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _hasAcceptedPledge
                        ? const Color(0xFF10B981).withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
                elevation: 0,
              ),
              child: _isSavingPledge
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _hasAcceptedPledge ? '✓' : '📜',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasAcceptedPledge
                              ? 'RE-AFFIRM SOVEREIGN PLEDGE'
                              : 'I ACCEPT THE 90-DAY PLEDGE & RULES',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
