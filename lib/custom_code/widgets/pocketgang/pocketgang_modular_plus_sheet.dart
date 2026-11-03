import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketgang_tools_service.dart';

class PocketGangToolMetadata {
  final String key;
  final String name;
  final String icon;

  const PocketGangToolMetadata({
    required this.key,
    required this.name,
    required this.icon,
  });
}

/// ➕ Compact Bottom Sheet Tool Menu for PocketGang
class PocketGangModularPlusSheet extends StatelessWidget {
  final List<String> installedToolKeys;
  final Function(String toolKey) onToolToggled;

  const PocketGangModularPlusSheet({
    super.key,
    required this.installedToolKeys,
    required this.onToolToggled,
  });

  static const List<PocketGangToolMetadata> availableTools = [
    PocketGangToolMetadata(key: 'team_mgmt', name: 'Team Management', icon: '👥'),
    PocketGangToolMetadata(key: 'dashboard', name: 'Dashboard', icon: '📊'),
    PocketGangToolMetadata(key: 'diagram_studio', name: 'Diagram Studio', icon: '📐'),
    PocketGangToolMetadata(key: 'calendar', name: 'Calendar', icon: '📅'),
    PocketGangToolMetadata(key: 'todo', name: 'To-do List', icon: '✅'),
    PocketGangToolMetadata(key: 'whiteboard', name: 'Whiteboard', icon: '🎨'),
    PocketGangToolMetadata(key: 'ideas_board', name: 'Ideas Board', icon: '💡'),
  ];

  static Future<List<String>?> show(
    BuildContext context, {
    required String groupId,
    required String userId,
    required List<String> currentInstalledTools,
  }) async {
    List<String>? result;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161924),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PocketGangModularPlusSheet(
        installedToolKeys: currentInstalledTools,
        onToolToggled: (toolKey) async {
          final updated = List<String>.from(currentInstalledTools);
          if (updated.contains(toolKey)) {
            updated.remove(toolKey);
          } else {
            updated.add(toolKey);
          }
          result = updated;
          await PocketGangToolsService.instance.updateInstalledTools(
            groupId: groupId,
            toolKeys: updated,
            userId: userId,
          );
        },
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gang Tools Library',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('GROUP-WIDE',
                    style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...availableTools.map((tool) {
            final isInstalled = installedToolKeys.contains(tool.key);

            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              leading: Text(tool.icon, style: const TextStyle(fontSize: 20)),
              title: Text(
                tool.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: isInstalled
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Installed',
                          style: TextStyle(color: Colors.white54, fontSize: 11)),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                        onToolToggled(tool.key);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
            );
          }),
        ],
      ),
    );
  }
}

