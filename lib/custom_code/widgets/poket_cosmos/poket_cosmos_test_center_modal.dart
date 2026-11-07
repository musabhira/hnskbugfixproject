import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_born_address_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_referral_gateway_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_navigator_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_setup_onboarding_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_island_inspector_modal.dart';

/// 🪐 Poket Cosmos Testing & Demo Center Modal
/// Allows pairs/testers/admins to:
/// 1. Instantly test the 4-Stage Born Address Ceremony (Newborn, Friend Invite, Veteran).
/// 2. Explore the full Solar System & 35-plot islands.
/// 3. Backfill & allocate all existing registered users with exclusive plots.
/// 4. Reset local deed state for infinite testing.
/// 5. Generate and copy 5-hour friend reservation codes.
class PoketCosmosTestCenterModal extends StatefulWidget {
  const PoketCosmosTestCenterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PoketCosmosTestCenterModal(),
    );
  }

  @override
  State<PoketCosmosTestCenterModal> createState() => _PoketCosmosTestCenterModalState();
}

class _PoketCosmosTestCenterModalState extends State<PoketCosmosTestCenterModal> {
  bool _isAllocating = false;
  String? _allocationResult;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x660284C7),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                  ),
                  child: const Text('🪐', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cosmos Testing Lab',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ടെസ്റ്റ് ചെയ്യാനുള്ള കൺട്രോൾ സെന്റർ',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF38BDF8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // SECTION 1: Born Address Ceremony Tests
            _buildSectionHeader('🎬 1. BORN ADDRESS CEREMONY (ജനന ചടങ്ങ്)', 'ടെസ്റ്റ് സിനാരിയോ തിരഞ്ഞെടുക്കുക'),
            const SizedBox(height: 10),

            _buildActionCard(
              icon: '🏝️',
              title: 'Inspect All 10 Celestial Islands & Oceans 🪐',
              subtitle: 'Earth, Jupiter, Pluto, Moon, Mars, Europa, Titan, Saturn, Venus, Neptune with custom gradient oceans & 18 plots!',
              color: const Color(0xFF38BDF8),
              onTap: () {
                Navigator.pop(context);
                PoketCosmosIslandInspectorModal.show(context);
              },
            ),
            const SizedBox(height: 8),

            _buildActionCard(
              icon: '🚪',
              title: 'Full Flow: Referral Gateway ➔ Born Ceremony',
              subtitle: 'Asks "Do you have an Island Referral Code?" -> Verifies neighbor or assigns destiny',
              color: const Color(0xFF10B981),
              onTap: () async {
                Navigator.pop(context);
                await PoketCosmosAllocationService.instance.resetLocalBirthplace();
                if (context.mounted) {
                  await PoketCosmosReferralGatewayPage.launch(
                    context,
                    userName: 'Learner',
                    userAvatar: '🦁',
                    userAge: 10,
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            _buildActionCard(
              icon: '🪐',
              title: 'Direct 4-Step Born Ceremony (Newborn)',
              subtitle: 'Step 1: Planet -> Step 2: Island -> Step 3: Plot Zoom & Green Tap -> Step 4: Home & Address',
              color: const Color(0xFF38BDF8),
              onTap: () async {
                Navigator.pop(context);
                await PoketCosmosAllocationService.instance.resetLocalBirthplace();
                if (context.mounted) {
                  await PoketCosmosBornAddressPage.launch(
                    context,
                    userName: 'Learner',
                    userAvatar: '🦁',
                    userAge: 10,
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            _buildActionCard(
              icon: '🤝',
              title: 'Test Jupiter Referral Code (User A ➔ User B)',
              subtitle: 'Enters PKT-JUPITER: Switches to Jupiter and reserves Plot #15 adjacent to User A!',
              color: const Color(0xFFF59E0B),
              onTap: () async {
                Navigator.pop(context);
                await PoketCosmosAllocationService.instance.resetLocalBirthplace();
                if (context.mounted) {
                  await PoketCosmosBornAddressPage.launch(
                    context,
                    userName: 'User B',
                    userAvatar: '🦊',
                    userAge: 11,
                    initialInviteCode: 'PKT-JUPITER',
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            _buildActionCard(
              icon: '👤',
              title: 'Full Flow: Profile Setup ➔ Born Ceremony',
              subtitle: 'Name, Phone, DOB, Avatar setup -> Save -> Seamless 4-Step Born Ceremony',
              color: const Color(0xFF10B981),
              onTap: () async {
                Navigator.pop(context);
                await PoketCosmosAllocationService.instance.resetLocalBirthplace();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        backgroundColor: Color(0xFF0F172A),
                        body: SafeArea(child: ProfileSetupOnboardingPage()),
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            _buildActionCard(
              icon: '🏰',
              title: 'Test Veteran Citizen (Day 75 Villa)',
              subtitle: 'Experience ceremony with luxury villa, pool, sun deck & car',
              color: const Color(0xFFF59E0B),
              onTap: () async {
                Navigator.pop(context);
                await PoketCosmosBornAddressPage.launch(
                  context,
                  userName: 'Veteran Musab',
                  userAvatar: '👑',
                  userAge: 14,
                );
              },
            ),
            const SizedBox(height: 20),

            // SECTION 2: Archipelago & Island Explorer
            _buildSectionHeader('🗺️ 2. EXPLORE POKET COSMOS', 'സോളാർ സിസ്റ്റം & ദ്വീപുകൾ പരിശോധിക്കുക'),
            const SizedBox(height: 10),

            _buildActionCard(
              icon: '🌌',
              title: 'Open Full Cosmos Explorer',
              subtitle: 'Flame 3D Solar System -> 30 Archipelago Islands -> 35 Plots',
              color: const Color(0xFF0284C7),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PoketCosmosNavigatorPage()),
                );
              },
            ),
            const SizedBox(height: 20),

            // SECTION 3: Allocate Existing Users Plan
            _buildSectionHeader('👥 3. EXISTING USERS MIGRATION (നിലവിലെ യൂസേഴ്സ്)', 'ഡാറ്റാബേസിലെ എല്ലാവർക്കും എക്സ്ക്ലൂസീവ് പ്ലോട്ട് നൽകുക'),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📌', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Plan for Existing Users:',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All existing users in the profile table are ordered by join date. Every 18 users fill 1 island across 10 celestial colonies (180 citizens per Wave). Each citizen gets a 100% exclusive Cosmos PIN (e.g. PKT-W01-EP-I01-P07) with zero duplicates!',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  if (_allocationResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Text(
                        _allocationResult!,
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF86EFAC), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isAllocating
                        ? null
                        : () async {
                            setState(() => _isAllocating = true);
                            HapticFeedback.mediumImpact();
                            final res = await PoketCosmosAllocationService.instance.syncAndAllocateExistingUsers();
                            if (mounted) {
                              setState(() {
                                _isAllocating = false;
                                if (res.containsKey('error')) {
                                  _allocationResult = '⚠️ Allocation failed: ${res['error']}';
                                } else {
                                  _allocationResult =
                                      '✅ Successfully allocated ${res['newlyAllocated']} users! (${res['alreadyAllocated']} were already assigned)';
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isAllocating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bolt_rounded, size: 18),
                              const SizedBox(width: 6),
                              Text('Auto-Allocate All Users Now (പ്ലോട്ടുകൾ നൽകുക)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 4: Test Utilities
            _buildSectionHeader('🛠️ 4. TEST UTILITIES', 'ഡീഡ് റീസെറ്റ് & കോഡ് കോപ്പി ചെയ്യുക'),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await PoketCosmosAllocationService.instance.resetLocalBirthplace();
                      HapticFeedback.lightImpact();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local Birthplace Deed cleared! You can re-test fresh.'),
                            backgroundColor: Color(0xFF334155),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF87171),
                      side: const BorderSide(color: Color(0xFFF87171)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text('Reset Deed (റീസെറ്റ്)', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final pass = await PoketCosmosAllocationService.instance.generateQuickTestFriendPass(plotNumber: 12);
                      Clipboard.setData(ClipboardData(text: pass.code));
                      HapticFeedback.lightImpact();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pass code ${pass.code} copied to clipboard!'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF38BDF8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text('Copy Code (PKT-TEST)', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.6)),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white60,
                      fontSize: 11.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}

