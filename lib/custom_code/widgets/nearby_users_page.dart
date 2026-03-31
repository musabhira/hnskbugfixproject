import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:pocket_mates_app/custom_code/widgets/verfied_search_profile_detail_page.dart'; // To open profile

class NearbyUsersPage extends StatefulWidget {
  const NearbyUsersPage({super.key});

  @override
  State<NearbyUsersPage> createState() => _NearbyUsersPageState();
}

class _NearbyUsersPageState extends State<NearbyUsersPage> {
  bool _isTravelModeActive = false;
  bool _isLoading = false;
  String _statusMessage = "Enable Travel Mode to find mates nearby.";
  List<Map<String, dynamic>> _nearbyUsers = [];
  Timer? _refreshTimer;
  Position? _currentPosition;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleTravelMode(bool value) async {
    setState(() {
      _isTravelModeActive = value;
    });

    if (value) {
      await _startTracking();
    } else {
      _stopTracking();
    }
  }

  Future<void> _startTracking() async {
    setState(() => _isLoading = true);

    // 1. Check Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isTravelModeActive = false;
          _statusMessage = "Location permissions are denied.";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isTravelModeActive = false;
        _statusMessage = "Location permissions are permanently denied.";
        _isLoading = false;
      });
      return;
    }

    // 2. Get Location
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Update DB
      await _updateLocationInDb(_currentPosition!);

      // 4. Fetch Nearby
      await _fetchNearbyUsers();

      // 5. Start Periodic Timer (Every 30s)
      _refreshTimer =
          Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (!mounted || !_isTravelModeActive) {
          timer.cancel();
          return;
        }
        final pos = await Geolocator.getCurrentPosition();
        await _updateLocationInDb(pos);
        await _fetchNearbyUsers();
      });

      setState(() {
        _statusMessage = "Scanning for nearby mates...";
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error starting travel mode: $e");
      setState(() {
        _isTravelModeActive = false;
        _statusMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  void _stopTracking() {
    _refreshTimer?.cancel();
    setState(() {
      _nearbyUsers = [];
      _statusMessage = "Travel Mode is OFF.";
    });
    // Optional: Mark inactive in DB
    // _supabase.from('user_locations').update({'is_active': false}).eq('user_id', _supabase.auth.currentUser!.id);
  }

  Future<void> _updateLocationInDb(Position position) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('user_locations').upsert({
        'user_id': userId,
        'location':
            'POINT(${position.longitude} ${position.latitude})', // PostGIS format
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  Future<void> _fetchNearbyUsers() async {
    if (_currentPosition == null) return;

    try {
      // Radius: 500 meters (Bus/Train station area)
      final response = await _supabase.rpc('get_nearby_users', params: {
        'lat': _currentPosition!.latitude,
        'long': _currentPosition!.longitude,
        'radius_meters': 500.0,
      });

      if (mounted) {
        setState(() {
          _nearbyUsers = List<Map<String, dynamic>>.from(response);
          _statusMessage = _nearbyUsers.isEmpty
              ? "No mates found nearby. Keep scanning..."
              : "Found ${_nearbyUsers.length} mates nearby!";
        });
      }
    } catch (e) {
      debugPrint("Error fetching nearby users: $e");
      if (e.toString().contains("function get_nearby_users does not exist")) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text("Please run the Setup SQL in Supabase Dashboard!")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Travel Radar',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Switch(
            value: _isTravelModeActive,
            onChanged: _toggleTravelMode,
            activeThumbColor: Colors.blueAccent,
            activeTrackColor: Colors.blueAccent.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Radar Animation / Status
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Column(
              children: [
                if (_isTravelModeActive)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.3),
                              width: 1),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              width: 1),
                        ),
                      ),
                      const Icon(Icons.radar,
                          size: 40, color: Colors.blueAccent),
                    ],
                  )
                else
                  const Icon(Icons.radar_outlined,
                      size: 40, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style:
                      GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent))
                : _nearbyUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_bus,
                                size: 64, color: Colors.white10),
                            const SizedBox(height: 16),
                            Text("Waiting for travelers...",
                                style:
                                    GoogleFonts.outfit(color: Colors.white30)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _nearbyUsers.length,
                        itemBuilder: (context, index) {
                          final user = _nearbyUsers[index];
                          final dist = (user['dist_meters'] as num).toDouble();
                          final distanceStr = dist < 1000
                              ? "${dist.toStringAsFixed(0)}m"
                              : "${(dist / 1000).toStringAsFixed(1)}km";

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user['profile_image_url'] != null
                                  ? NetworkImage(user['profile_image_url'])
                                  : null,
                              child: user['profile_image_url'] == null
                                  ? Text(user['name']?[0] ?? "?")
                                  : null,
                            ),
                            title: Text(
                              user['name'] ?? "Unknown Traveler",
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${user['shop_name'] ?? 'Traveler'} • $distanceStr away",
                              style: GoogleFonts.outfit(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                // Open Chat or Profile
                                // For now, let's open Profile Detail Page
                                // Assuming we have navigation logic
                                // Or show a dialog to request chat
                                _showChatRequestDialog(user);
                              },
                            ),
                            onTap: () {
                              if (user['user_id'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VerfiedSearchProfileDetailPage(
                                      userId: user['user_id'],
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Profile details not available')),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showChatRequestDialog(Map<String, dynamic> user) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: Text("Say Hi?",
                  style: GoogleFonts.outfit(color: Colors.white)),
              content: Text("Send a wave to ${user['name']}?",
                  style: GoogleFonts.outfit(color: Colors.white70)),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Wave 👋",
                      style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Wave sent! (Simulation)")),
                    );
                    // Implementation of actual chat request goes here
                  },
                ),
              ],
            ));
  }
}
