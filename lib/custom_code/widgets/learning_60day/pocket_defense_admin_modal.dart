import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_fortress_defense_service.dart';

/// ⚖️ Pocket World Presidential Tribunal & Defense Admin Review Panel
/// Allows game masters & admins to review reported fake/nonsense questions,
/// take disciplinary action, and BAN offending houses from Pocket World Street!
class PocketDefenseAdminModal extends StatefulWidget {
  const PocketDefenseAdminModal({super.key});

  static Future<void> show(BuildContext context) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF070B14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const PocketDefenseAdminModal(),
    );
  }

  @override
  State<PocketDefenseAdminModal> createState() => _PocketDefenseAdminModalState();
}

class _PocketDefenseAdminModalState extends State<PocketDefenseAdminModal> {
  List<DefenseQuestionReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final list = await PocketFortressDefenseService.getDefenseReports();
    if (mounted) {
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBanHouse(DefenseQuestionReport report) async {
    HapticFeedback.heavyImpact();
    await PocketFortressDefenseService.banHouse(
      report.houseId,
      reason: 'Fake or impossible English defense trap reported: "${report.questionText}"',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🚫 ${report.houseOwnerName}-ന്റെ വീട് ബാൻ ചെയ്തു! Presidential Ban Seal applied.',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
    _loadReports();
  }

  Future<void> _handleUnbanHouse(DefenseQuestionReport report) async {
    HapticFeedback.mediumImpact();
    await PocketFortressDefenseService.unbanHouse(report.houseId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        content: Text('🔓 ${report.houseOwnerName}-ന്റെ ബാൻ നീക്കം ചെയ്തു.'),
      ),
    );
    _loadReports();
  }

  Future<void> _handleDismiss(DefenseQuestionReport report) async {
    HapticFeedback.lightImpact();
    await PocketFortressDefenseService.dismissReport(report.reportId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF334155),
        behavior: SnackBarBehavior.floating,
        content: Text('✅ റിപ്പോർട്ട് നിരസിച്ചു (Dismissed).'),
      ),
    );
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _reports.where((r) => r.status == 'pending').length;
    final bannedCount = _reports.where((r) => r.status == 'banned').length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: const Text('⚖️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRESIDENTIAL TRIBUNAL & REVIEW',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Fair Play Moderation • Anti-Cheat Defense Audits',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.5,
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
          const SizedBox(height: 12),

          // Metric Stat Badges
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount Pending',
                        style: GoogleFonts.outfit(
                          color: pendingCount > 0 ? const Color(0xFFFBBF24) : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Text('🚫', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '$bannedCount Banned',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF87171),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '${_reports.length} Total',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fair Play Warning Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF78350F).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ഫേക്ക് ചോദ്യങ്ങളോ തെറ്റായ ഉത്തരങ്ങളോ നൽകി ഡിഫൻസ് നടത്തുന്ന വീടുകൾ ബാൻ ചെയ്യപ്പെടും. അറ്റാക്ക് ചെയ്തവർ നൽകിയ റിപ്പോർട്ടുകൾ താഴെ റിവ്യൂ ചെയ്യുക.',
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Reports List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return _buildReportCard(report);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🕊️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(
            'All Clean! No Violations Reported',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'All defense questions adhere to fair-play English education standards.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(DefenseQuestionReport report) {
    Color statusColor = const Color(0xFFFBBF24);
    String statusLabel = 'PENDING REVIEW';
    if (report.status == 'banned') {
      statusColor = const Color(0xFFEF4444);
      statusLabel = 'HOUSE BANNED';
    } else if (report.status == 'dismissed') {
      statusColor = Colors.white54;
      statusLabel = 'DISMISSED';
    }

    String reasonLabel = 'Fake / Gibberish';
    if (report.reason == 'wrong_answer') {
      reasonLabel = 'Wrong Answer Marked Correct';
    } else if (report.reason == 'impossible_trap') {
      reasonLabel = 'Impossible Unfair Trap';
    } else if (report.reason == 'offensive_content') {
      reasonLabel = 'Offensive Content';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: report.status == 'banned' ? const Color(0xFFEF4444) : Colors.white12,
          width: report.status == 'banned' ? 1.6 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Accused House & Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text('🏡', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.houseOwnerName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reported by ${report.reporterName} • ${_formatTimeAgo(report.reportedAt)}',
                      style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.outfit(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Violation Reason Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_rounded, color: Color(0xFFEF4444), size: 13),
                const SizedBox(width: 4),
                Text(
                  reasonLabel,
                  style: const TextStyle(
                    color: Color(0xFFFCA5A5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (report.details.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Detail: "${report.details}"',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Reported Question Details Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('📝', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 5),
                    Text(
                      'REPORTED QUESTION CONTENT:',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.questionText,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: List.generate(report.options.length, (i) {
                    final isMarkedCorrect = i == report.correctIndex;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMarkedCorrect
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isMarkedCorrect ? const Color(0xFF10B981) : Colors.white12,
                        ),
                      ),
                      child: Text(
                        '${i + 1}. ${report.options[i]}${isMarkedCorrect ? ' (Marked Correct ✓)' : ''}',
                        style: TextStyle(
                          color: isMarkedCorrect ? const Color(0xFF34D399) : Colors.white60,
                          fontSize: 10.5,
                          fontWeight: isMarkedCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              if (report.status != 'banned')
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.gavel_rounded, size: 14),
                    label: const Text(
                      'BAN HOUSE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _handleBanHouse(report),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.lock_open_rounded, size: 14),
                    label: const Text(
                      'UNBAN HOUSE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _handleUnbanHouse(report),
                  ),
                ),
              const SizedBox(width: 8),
              if (report.status != 'dismissed')
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 14),
                  label: const Text(
                    'DISMISS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _handleDismiss(report),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
