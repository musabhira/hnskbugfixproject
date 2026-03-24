import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/team_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/user_search_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/running_tasks_widget.dart';

class TeamsHomeWidget extends StatefulWidget {
  const TeamsHomeWidget({Key? key}) : super(key: key);

  @override
  State<TeamsHomeWidget> createState() => _TeamsHomeWidgetState();
}

class _TeamsHomeWidgetState extends State<TeamsHomeWidget> {
  final TeamsService _service = TeamsService();
  List<Team> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);
    try {
      final teams = await _service.getMyTeams();
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading teams: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showCreateTeamDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    List<UserResult> selectedMembers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            title: Text('Create New Team',
                style: GoogleFonts.outfit(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Initial Members:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: selectedMembers
                      .map((u) => Chip(
                            label: Text(u.name, style: TextStyle(fontSize: 12)),
                            backgroundColor: Colors.yellow,
                            deleteIcon: Icon(Icons.close, size: 14),
                            onDeleted: () {
                              setStateDialog(() {
                                selectedMembers
                                    .removeWhere((m) => m.userId == u.userId);
                              });
                            },
                          ))
                      .toList(),
                ),
                TextButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => UserSearchDialog(
                        onUsersSelected: (users) {
                          setStateDialog(() {
                            // Avoid duplicates
                            for (var user in users) {
                              if (!selectedMembers
                                  .any((m) => m.userId == user.userId)) {
                                selectedMembers.add(user);
                              }
                            }
                          });
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.person_add, color: Colors.yellow),
                  label: Text('Search & Add Members',
                      style: TextStyle(color: Colors.yellow)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  try {
                    await _service.createTeam(
                      nameController.text,
                      descController.text,
                      selectedMembers.map((u) => u.userId).toList(),
                    );
                    Navigator.pop(context);
                    _loadTeams();
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.yellow));
    }

    if (_teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No teams yet',
              style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateTeamDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Team'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        RunningTasksWidget(service: _service),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Teams',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.yellow),
                onPressed: _showCreateTeamDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _teams.length,
            itemBuilder: (context, index) {
              final team = _teams[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF424242)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.yellow.withValues(alpha: 0.2),
                    child: Text(
                      team.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    team.name,
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: team.description != null
                      ? Text(
                          team.description!,
                          style: GoogleFonts.outfit(
                              color: Colors.grey, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamDetailPage(team: team),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}