import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔮 Jackie Chan Adventures - The 12 Legendary Zodiac Talismans (മാന്ത്രിക കല്ലുകൾ)
/// In the animated series, each octagonal stone talisman grants its bearer supernatural abilities.
/// In Pocket World, players discover and equip these talismans across their 90-day English journey,
/// unlocking immense battle buffs, defense boosts, speed, and house healing!
class JackieChanTalisman {
  final String id;
  final String zodiacAnimal;
  final String malName;
  final String emoji;
  final String powerTitle;
  final String powerDescription;
  final String malDescription;
  final String runeSymbol;
  final Color stoneColor;
  final Color glowColor;
  final int unlockDay; // Stage milestone when discovered
  final String battleBuff;

  const JackieChanTalisman({
    required this.id,
    required this.zodiacAnimal,
    required this.malName,
    required this.emoji,
    required this.powerTitle,
    required this.powerDescription,
    required this.malDescription,
    required this.runeSymbol,
    required this.stoneColor,
    required this.glowColor,
    required this.unlockDay,
    required this.battleBuff,
  });
}

final List<JackieChanTalisman> kJackieChanTalismans = [
  const JackieChanTalisman(
    id: 'rabbit',
    zodiacAnimal: 'Rabbit Talisman',
    malName: 'മുയൽ കല്ല്',
    emoji: '🐇',
    powerTitle: 'SUPERHUMAN SPEED',
    powerDescription: 'Grants blinding supersonic velocity and instantaneous reaction time.',
    malDescription: 'അതിവേഗത്തിൽ ഇംഗ്ലീഷ് മറുപടി നൽകാനും റെയ്ഡ് ടൈമറിൽ +15 സെക്കൻഡ് അധികം നേടാനും സഹായിക്കുന്നു.',
    runeSymbol: '卯',
    stoneColor: Color(0xFFD97706),
    glowColor: Color(0xFFFBBF24),
    unlockDay: 7,
    battleBuff: '+15s Extra Raid Timer • 2X Speech Sprint Speed',
  ),
  const JackieChanTalisman(
    id: 'dragon',
    zodiacAnimal: 'Dragon Talisman',
    malName: 'ഡ്രാഗൺ കല്ല്',
    emoji: '🐉',
    powerTitle: 'THERMAL COMBUSTION BLAST',
    powerDescription: 'Discharges explosive fiery plasma blasts that incinerate obstacles.',
    malDescription: 'റെയ്ഡുകളിൽ ശത്രുവിന്റെ കോട്ടയെ തകർക്കുന്ന +45% എക്സ്പ്ലോസീവ് ഫയർ ബോംബ് ഡാമേജ് നൽകുന്നു.',
    runeSymbol: '辰',
    stoneColor: Color(0xFFDC2626),
    glowColor: Color(0xFFF87171),
    unlockDay: 14,
    battleBuff: '+45% Fiery Bomb Raid Damage • 1.5x Crit Multiplier',
  ),
  const JackieChanTalisman(
    id: 'ox',
    zodiacAnimal: 'Ox Talisman',
    malName: 'കാള കല്ല്',
    emoji: '🐂',
    powerTitle: 'SUPER STRENGTH',
    powerDescription: 'Imbues the muscles with titanic strength capable of lifting mountain peaks.',
    malDescription: 'ശത്രുവിന്റെ ഇരുമ്പ് ഷീൽഡിനെയും ഗേറ്റുകളെയും ഒരൊറ്റ അടിയിൽ തകർക്കുന്നു.',
    runeSymbol: '丑',
    stoneColor: Color(0xFFB45309),
    glowColor: Color(0xFFF59E0B),
    unlockDay: 21,
    battleBuff: 'Bypasses 1 Enemy Shield Layer • +25 Direct Gate Damage',
  ),
  const JackieChanTalisman(
    id: 'horse',
    zodiacAnimal: 'Horse Talisman',
    malName: 'കുതിര കല്ല്',
    emoji: '🐎',
    powerTitle: 'NOBLE REGENERATION & HEALING',
    powerDescription: 'Purges all physical ailments, structural damage, toxins, and decay.',
    malDescription: 'ഓരോ ദിവസത്തെയും മിഷൻ പൂർത്തിയാക്കുമ്പോൾ നിങ്ങളുടെ വീടിന് +35 HP ഓട്ടോമാറ്റിക് റിപ്പയർ നൽകുന്നു.',
    runeSymbol: '午',
    stoneColor: Color(0xFF059669),
    glowColor: Color(0xFF34D399),
    unlockDay: 28,
    battleBuff: '+35 Auto House HP Repair per Completed Day',
  ),
  const JackieChanTalisman(
    id: 'dog',
    zodiacAnimal: 'Dog Talisman',
    malName: 'നായ കല്ല്',
    emoji: '🐕',
    powerTitle: 'IMMORTALITY & INVULNERABILITY',
    powerDescription: 'Bestows total indestructibility and resistance against all incoming damage.',
    malDescription: 'ശത്രുക്കൾ അറ്റാക്ക് ചെയ്യുമ്പോൾ നിങ്ങളുടെ വീടിന് ഏൽക്കുന്ന നാശനഷ്ടം 50% കുറയ്ക്കുന്നു.',
    runeSymbol: '戌',
    stoneColor: Color(0xFF4F46E5),
    glowColor: Color(0xFF818CF8),
    unlockDay: 35,
    battleBuff: 'Absorbs 50% Raid Damage • Shields House from Collapse',
  ),
  const JackieChanTalisman(
    id: 'snake',
    zodiacAnimal: 'Snake Talisman',
    malName: 'പാമ്പ് കല്ല്',
    emoji: '🐍',
    powerTitle: 'INVISIBILITY & STEALTH',
    powerDescription: 'Renders the bearer completely invisible and undetected by enemy radars.',
    malDescription: 'ശത്രുവിന്റെ വീട് റെയ്ഡ് ചെയ്യുമ്പോൾ ഒരു ചോദ്യം സ്കിപ്പ് ചെയ്ത് രഹസ്യമായി കടക്കാൻ സഹായിക്കുന്നു.',
    runeSymbol: '巳',
    stoneColor: Color(0xFF047857),
    glowColor: Color(0xFF10B981),
    unlockDay: 42,
    battleBuff: 'Stealth Infiltration • Skip 1 Tricky Trap Question',
  ),
  const JackieChanTalisman(
    id: 'rooster',
    zodiacAnimal: 'Rooster Talisman',
    malName: 'പൂവൻകോഴി കല്ല്',
    emoji: '🐓',
    powerTitle: 'LEVITATION & TELEKINESIS',
    powerDescription: 'Grants antigravity flight and telekinetic thought-manipulation of heavy objects.',
    malDescription: 'റെയ്ഡുകളിൽ ഭീമാകാരമായ പാറക്കല്ലുകൾ പറത്തിവിട്ട് instant 30 damage നൽകുന്നു.',
    runeSymbol: '酉',
    stoneColor: Color(0xFFE11D48),
    glowColor: Color(0xFFFB7185),
    unlockDay: 49,
    battleBuff: 'Telekinetic Boulder Hurl • 30 Instant Mind Damage',
  ),
  const JackieChanTalisman(
    id: 'monkey',
    zodiacAnimal: 'Monkey Talisman',
    malName: 'കുരങ്ങ് കല്ല്',
    emoji: '🐒',
    powerTitle: 'SHAPESHIFTING',
    powerDescription: 'Transforms any animate or inanimate entity into harmless creatures.',
    malDescription: 'എതിരാളിയുടെ ഡിഫൻസ് ട്രാപ്പുകളെ 15 സെക്കൻഡ് നേരത്തേക്ക് പൂച്ചക്കുട്ടിയാക്കി മാറ്റുന്നു.',
    runeSymbol: '申',
    stoneColor: Color(0xFF7C3AED),
    glowColor: Color(0xFFA78BFA),
    unlockDay: 56,
    battleBuff: 'Disarms Enemy Traps for 15 Seconds',
  ),
  const JackieChanTalisman(
    id: 'sheep',
    zodiacAnimal: 'Sheep Talisman',
    malName: 'ചെമ്മരിയാട് കല്ല്',
    emoji: '🐑',
    powerTitle: 'ASTRAL PROJECTION',
    powerDescription: 'Separates spirit from body to explore dreams and foresee answers.',
    malDescription: 'ക്വിസ് യുദ്ധങ്ങളിൽ 1 തെറ്റായ ഓപ്ഷൻ ആത്മീയമായി വെളിപ്പെടുത്തി മായ്ച്ചുതരുന്നു.',
    runeSymbol: '未',
    stoneColor: Color(0xFF0284C7),
    glowColor: Color(0xFF38BDF8),
    unlockDay: 63,
    battleBuff: 'Spiritual Vision: Eliminates 1 Wrong Option Automatically',
  ),
  const JackieChanTalisman(
    id: 'rat',
    zodiacAnimal: 'Rat Talisman',
    malName: 'എലി കല്ല്',
    emoji: '🐀',
    powerTitle: 'ANIMATION (MOTION TO MOTIONLESS)',
    powerDescription: 'Breathes life into statues, gargoyles, stone carvings, and toys.',
    malDescription: 'നിങ്ങളുടെ വീട്ടുവാതിൽക്കൽ 2 ജീവനുള്ള കരിങ്കൽ ഗാർഗോയിലുകളെ കാവലിരുത്തുന്നു.',
    runeSymbol: '子',
    stoneColor: Color(0xFF475569),
    glowColor: Color(0xFF94A3B8),
    unlockDay: 70,
    battleBuff: 'Awakens 2 Stone Gargoyle Guardians at your Gates',
  ),
  const JackieChanTalisman(
    id: 'tiger',
    zodiacAnimal: 'Tiger Talisman',
    malName: 'കടുവ കല്ല്',
    emoji: '🐅',
    powerTitle: 'SPIRITUAL BALANCE & YIN-YANG',
    powerDescription: 'Harmonizes light and dark spirits into supreme focus and doubled luck.',
    malDescription: 'റെയ്ഡ് വിജയങ്ങളിൽ ലഭിക്കുന്ന Pocket Coins ഇരട്ടിയാക്കി (2X) നൽകുന്നു.',
    runeSymbol: '寅',
    stoneColor: Color(0xFFEA580C),
    glowColor: Color(0xFFFB923C),
    unlockDay: 78,
    battleBuff: 'Doubled Loot Fortune (2X Coins on Raid Victory)',
  ),
  const JackieChanTalisman(
    id: 'pig',
    zodiacAnimal: 'Pig Talisman',
    malName: 'പന്നി കല്ല്',
    emoji: '🐖',
    powerTitle: 'THERMAL LASER EYE BEAMS',
    powerDescription: 'Shoots high-temperature optic laser beams piercing through titanium armor.',
    malDescription: 'എതിരാളികളുടെ അയൺ ഡോം തുളച്ച് direct laser damage ഏൽപ്പിക്കുന്നു.',
    runeSymbol: '亥',
    stoneColor: Color(0xFFDB2777),
    glowColor: Color(0xFFF472B6),
    unlockDay: 85,
    battleBuff: 'Optic Laser Eye Blast: Melts Enemy Iron Dome',
  ),
];

/// Central Service for Managing Jackie Chan Talismans
class JackieChanTalismanService {
  static const String _equippedKey = 'equipped_jackie_talisman_id';

  /// Get currently equipped talisman
  static Future<JackieChanTalisman> getEquippedTalisman() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_equippedKey) ?? 'rabbit';
    return kJackieChanTalismans.firstWhere(
      (t) => t.id == id,
      orElse: () => kJackieChanTalismans.first,
    );
  }

  /// Equip a talisman
  static Future<void> equipTalisman(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_equippedKey, id);
  }

  /// Get list of unlocked talismans for current day
  static List<JackieChanTalisman> getUnlockedTalismans(int userDay) {
    return kJackieChanTalismans.where((t) => userDay >= t.unlockDay).toList();
  }

  /// Check if a talisman is unlocked
  static bool isTalismanUnlocked(String id, int userDay) {
    final t = kJackieChanTalismans.firstWhere((item) => item.id == id, orElse: () => kJackieChanTalismans.first);
    return userDay >= t.unlockDay;
  }
}

/// 🔮 Interactive Modal to Inspect and Equip Jackie Chan Talisman Stones
class JackieChanTalismanVaultModal extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onEquipped;

  const JackieChanTalismanVaultModal({
    super.key,
    required this.currentDay,
    this.onEquipped,
  });

  static Future<void> show(BuildContext context, {required int currentDay, VoidCallback? onEquipped}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JackieChanTalismanVaultModal(
        currentDay: currentDay,
        onEquipped: onEquipped,
      ),
    );
  }

  @override
  State<JackieChanTalismanVaultModal> createState() => _JackieChanTalismanVaultModalState();
}

class _JackieChanTalismanVaultModalState extends State<JackieChanTalismanVaultModal> {
  JackieChanTalisman _equipped = kJackieChanTalismans.first;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipped();
  }

  Future<void> _loadEquipped() async {
    final eq = await JackieChanTalismanService.getEquippedTalisman();
    if (mounted) {
      setState(() {
        _equipped = eq;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEquip(JackieChanTalisman t) async {
    HapticFeedback.heavyImpact();
    await JackieChanTalismanService.equipTalisman(t.id);
    setState(() => _equipped = t);
    widget.onEquipped?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(t.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t.zodiacAnimal} Equipped! ${t.powerTitle}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: t.stoneColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              children: [
                const Text('🔮', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JACKIE CHAN TALISMAN VAULT',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '12 Zodiac Magic Stones • Equip mystical animal powers & battle buffs',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Grid of 12 Talismans
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    itemCount: kJackieChanTalismans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = kJackieChanTalismans[index];
                      final isUnlocked = widget.currentDay >= t.unlockDay;
                      final isEquipped = _equipped.id == t.id;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isEquipped
                              ? t.stoneColor.withValues(alpha: 0.18)
                              : const Color(0xFF1E293B).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEquipped
                                ? t.glowColor
                                : (isUnlocked ? Colors.white24 : Colors.white10),
                            width: isEquipped ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Octagonal stone look
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isUnlocked ? t.stoneColor : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: t.glowColor, width: 1.5),
                                boxShadow: [
                                  if (isEquipped)
                                    BoxShadow(
                                      color: t.glowColor.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  isUnlocked ? t.emoji : '🔒',
                                  style: TextStyle(fontSize: isUnlocked ? 24 : 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${t.zodiacAnimal} (${t.malName})',
                                        style: GoogleFonts.outfit(
                                          color: isUnlocked ? Colors.white : Colors.white54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: t.stoneColor.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          t.runeSymbol,
                                          style: TextStyle(
                                            color: t.glowColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isEquipped)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD700),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'EQUIPPED',
                                            style: GoogleFonts.outfit(
                                              color: Colors.black,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.powerTitle,
                                    style: GoogleFonts.outfit(
                                      color: isUnlocked ? t.glowColor : Colors.white38,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isUnlocked ? t.battleBuff : 'Unlocks at Day ${t.unlockDay}',
                                    style: GoogleFonts.inter(
                                      color: isUnlocked ? const Color(0xFF38BDF8) : Colors.amber,
                                      fontSize: 11,
                                      fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t.malDescription,
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (isUnlocked && !isEquipped) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: t.stoneColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 2,
                                        ),
                                        onPressed: () => _handleEquip(t),
                                        child: Text(
                                          'EQUIP TALISMAN',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
