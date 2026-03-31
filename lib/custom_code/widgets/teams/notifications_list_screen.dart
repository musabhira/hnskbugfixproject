import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/notification_tile.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/notifications_local_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  final NotificationsLocalService _localService = NotificationsLocalService();
  final TeamsService _teamsService = TeamsService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalNotifications();
    _listenToRemoteNotifications();
  }

  Future<void> _loadLocalNotifications() async {
    final localData = await _localService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = localData;
        _isLoading = false;
      });
    }
  }

  void _listenToRemoteNotifications() {
    // Listen to real-time updates from Supabase
    // Note: getNotificationsStream returns a Stream<List<Map<String, dynamic>>>
    // We assume it returns the FULL list or updates. Supabase .stream() usually returns the full list of matching rows.
    _teamsService.getNotificationsStream().listen((remoteData) async {
      // Sync local storage
      await _localService.syncNotifications(remoteData);

      if (mounted) {
        setState(() {
          _notifications = remoteData;
        });
      }
    });
  }

  void _handleRefresh() {
    // Reload local data if needed, or trigger a fetch
    _loadLocalNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onRefresh: _handleRefresh,
                    );
                  },
                ),
    );
  }
}
