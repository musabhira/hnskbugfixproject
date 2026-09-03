import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PocketVehicle {
  final String id;
  final String name;
  final String brandModel;
  final int unlockDay;
  final String icon;
  final Color primaryColor;
  final Color accentColor;
  final int armorHp;
  final int coinBonusPercent;
  final String description;
  final List<TravelMission> missions;

  const PocketVehicle({
    required this.id,
    required this.name,
    required this.brandModel,
    required this.unlockDay,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.armorHp,
    required this.coinBonusPercent,
    required this.description,
    required this.missions,
  });
}

class TravelMission {
  final String city;
  final String flag;
  final String title;
  final String scenario;
  final int xpReward;
  final int coinReward;

  const TravelMission({
    required this.city,
    required this.flag,
    required this.title,
    required this.scenario,
    required this.xpReward,
    required this.coinReward,
  });
}

final List<PocketVehicle> kPocketVehicles = [
  const PocketVehicle(
    id: 'superbike_30',
    name: 'Shadow Runner',
    brandModel: 'Cyber Sports Superbike',
    unlockDay: 30,
    icon: '🏍️',
    primaryColor: Color(0xFF00F0FF),
    accentColor: Color(0xFF0284C7),
    armorHp: 10,
    coinBonusPercent: 15,
    description: 'Fast, nimble, and street-ready. Built for quick city hops and rapid conversational drills!',
    missions: [
      TravelMission(
        city: 'London',
        flag: '🇬🇧',
        title: 'Soho Specialty Coffee Order',
        scenario: 'Order a custom oat flat-white with subtle syrup adjustments in fast-paced British English.',
        xpReward: 40,
        coinReward: 30,
      ),
      TravelMission(
        city: 'Tokyo',
        flag: '🇯🇵',
        title: 'Shibuya Metro Directions',
        scenario: 'Ask locals and transit officers for the Yamanote line transfer under a tight timetable.',
        xpReward: 45,
        coinReward: 35,
      ),
    ],
  ),
  const PocketVehicle(
    id: 'suv_60',
    name: 'Vanguard Grand',
    brandModel: 'Executive Luxury SUV',
    unlockDay: 60,
    icon: '🚙',
    primaryColor: Color(0xFF8B5CF6),
    accentColor: Color(0xFF6D28D9),
    armorHp: 18,
    coinBonusPercent: 22,
    description: 'Commanding road presence with armored alloy framing. Ideal for long-range cross-country fluency tours!',
    missions: [
      TravelMission(
        city: 'New York',
        flag: '🇺🇸',
        title: 'Manhattan Hotel Concierge',
        scenario: 'Inquire about Broadway musical tickets, dinner reservations, and baggage logistics.',
        xpReward: 60,
        coinReward: 50,
      ),
      TravelMission(
        city: 'Sydney',
        flag: '🇦🇺',
        title: 'Harbor Coastal Tour Booking',
        scenario: 'Negotiate charter boat booking terms, safety regulations, and schedule changes.',
        xpReward: 65,
        coinReward: 55,
      ),
    ],
  ),
  const PocketVehicle(
    id: 'rolls_royce_90',
    name: 'Sovereign Phantom',
    brandModel: 'Imperial 24K Rolls-Royce',
    unlockDay: 90,
    icon: '🏎️',
    primaryColor: Color(0xFFFFD700),
    accentColor: Color(0xFFB45309),
    armorHp: 30,
    coinBonusPercent: 35,
    description: 'The pinnacle of achievement. Handcrafted coachwork with Spirit of Fluency emblem. Crown of the 90-Day Master!',
    missions: [
      TravelMission(
        city: 'Geneva',
        flag: '🇨🇭',
        title: 'Global Summit Keynote & Negotiation',
        scenario: 'Lead an international diplomatic panel discussion, address media questions, and close agreements.',
        xpReward: 100,
        coinReward: 100,
      ),
      TravelMission(
        city: 'Paris',
        flag: '🇫🇷',
        title: 'Eiffel Skyline Gala Networking',
        scenario: 'Mingle with high-society patrons, discuss art history, and deliver an impromptu toast.',
        xpReward: 110,
        coinReward: 120,
      ),
    ],
  ),
];

class PocketVehicleGarageModal extends StatelessWidget {
  final int userDay;

  const PocketVehicleGarageModal({
    super.key,
    required this.userDay,
  });

  static void show(BuildContext context, int userDay) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PocketVehicleGarageModal(userDay: userDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeVehicle = userDay >= 90
        ? kPocketVehicles[2]
        : (userDay >= 60 ? kPocketVehicles[1] : (userDay >= 30 ? kPocketVehicles[0] : null));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Text('🏎️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POCKET ESTATE GARAGE',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Milestone Vehicles & Global Road Trip Missions',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ACTIVE OR UNLOCK PREVIEW CARD ---
                  if (activeVehicle != null)
                    _buildActiveVehicleCard(context, activeVehicle)
                  else
                    _buildLockedPreviewCard(),

                  const SizedBox(height: 22),

                  // --- FLEET MILESTONE PROGRESSION ROADMAP ---
                  Text(
                    '🏆 Milestone Vehicle Fleet',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...kPocketVehicles.map((v) => _buildFleetTile(v, userDay)),

                  const SizedBox(height: 22),

                  // --- GLOBAL ROAD TRIP MISSIONS (IF UNLOCKED) ---
                  if (activeVehicle != null) ...[
                    Text(
                      '🌍 Global Road Trip Missions (${activeVehicle.brandModel})',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Travel to international destinations in your vehicle to practice high-stakes conversational English!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...activeVehicle.missions.map((m) => _buildMissionCard(context, m)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveVehicleCard(BuildContext context, PocketVehicle v) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            v.accentColor.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: v.primaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: v.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                  border: Border.all(color: v.primaryColor),
                ),
                child: Text(v.icon, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: v.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'UNLOCKED AT DAY ${v.unlockDay}',
                        style: GoogleFonts.outfit(
                          color: v.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      v.brandModel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            v.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle Perks
          Row(
            children: [
              _buildStatChip('🛡️ +${v.armorHp} HP', 'House Shield Armor'),
              const SizedBox(width: 8),
              _buildStatChip('🪙 +${v.coinBonusPercent}%', 'Street Coin Boost'),
              const SizedBox(width: 8),
              _buildStatChip('⭐ VIP Status', 'Story Card Flex'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 9.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300, width: 1.2),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Vehicle Unlocks at Day 30!',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Maintain your daily English streak to unlock the Cyber Superbike at Day 30 and the Imperial Rolls-Royce at Day 90!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetTile(PocketVehicle v, int currentDay) {
    final isUnlocked = currentDay >= v.unlockDay;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? v.primaryColor.withValues(alpha: 0.5) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Text(v.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${v.brandModel} • Day ${v.unlockDay}',
                  style: TextStyle(
                    color: isUnlocked ? v.primaryColor : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFF059669) : Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isUnlocked ? 'ACTIVE' : 'LOCKED',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, TravelMission m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF162238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(m.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '${m.city}: ${m.title}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${m.coinReward} 🪙',
                  style: GoogleFonts.outfit(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m.scenario,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🚗 Fastening seatbelts! Road trip to ${m.city} starting...',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
              },
              icon: const Icon(Icons.flight_takeoff_rounded, size: 16),
              label: Text(
                'START ROAD TRIP EXPEDITION',
                style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
