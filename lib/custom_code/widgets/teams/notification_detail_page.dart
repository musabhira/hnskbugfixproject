import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

class NotificationDetailPage extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onUpdate;

  const NotificationDetailPage({
    super.key,
    required this.notification,
    required this.onUpdate,
  });

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  bool _isLoading = false;
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.notification['status'] ?? 'unread';
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.notification['type'];
    final message = widget.notification['message'];
    final sourceId = widget.notification['source_id'];
    final teamsService = TeamsService();
    final isInvite = type == 'project_invite';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Notification Details',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (isInvite) ...[
              if (_status == 'approved')
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Text('Accepted',
                          style: GoogleFonts.outfit(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else if (_status == 'rejected')
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      const SizedBox(width: 10),
                      Text('Declined',
                          style: GoogleFonts.outfit(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                await teamsService.declineInvite(sourceId);
                                setState(() {
                                  _status = 'rejected';
                                  _isLoading = false;
                                });
                                widget.onUpdate();
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Decline',
                            style: GoogleFonts.outfit(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                await teamsService.acceptInvite(sourceId);
                                setState(() {
                                  _status = 'approved';
                                  _isLoading = false;
                                });
                                widget.onUpdate();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Accept',
                            style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}