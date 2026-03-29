// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'dart:math';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:intl/intl.dart';

class EventsDisplayHomePage extends StatefulWidget {
  const EventsDisplayHomePage({
    super.key,
    this.width,
    this.height,
    this.userId,
  });

  final double? width;
  final double? height;
  final String? userId;

  @override
  State<EventsDisplayHomePage> createState() => _EventsDisplayHomePageState();
}

class _EventsDisplayHomePageState extends State<EventsDisplayHomePage> {
  final _supabase = SupaFlow.client;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  bool _isLoading = false;
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _welcomeCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadEvents();
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((event) {
        final title = event['title'].toString().toLowerCase();
        final description = event['description'].toString().toLowerCase();
        final location = event['location'].toString().toLowerCase();
        final creatorName =
            event['creator_profile']?['name']?.toString().toLowerCase() ?? '';

        return title.contains(query) ||
            description.contains(query) ||
            location.contains(query) ||
            creatorName.contains(query);
      }).toList();
    });
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      // First, delete expired events
      await _supabase
          .from('events')
          .delete()
          .lt('event_date', now.toIso8601String());

      // Build the query step by step
      var query = _supabase.from('events').select('''
          id,
          created_at,
          user_id,
          title,
          description,
          location,
          event_date,
          image_url,
          is_active,
          price,
          max_participants,
          current_participants
        ''').eq('is_active', true).gte('event_date', now.toIso8601String());

      // Conditionally add user_id filter if provided
      if (widget.userId != null) {
        query = query.eq('user_id', widget.userId!);
      }

      // Execute the query with ordering
      final List<dynamic> response = await query.order('event_date');
      final eventList = List<Map<String, dynamic>>.from(response);

      if (eventList.isEmpty) {
        setState(() {
          _events = [];
          _filteredEvents = [];
        });
        return;
      }

      // Collect all user IDs involved (creators)
      final creatorIds = eventList.map((e) => e['user_id']).toSet().toList();

      // Fetch creator profiles in bulk
      final creatorsResponse = await _supabase
          .from('profile')
          .select(
              'id, user_id, name, profile_image_url, bio, bg_text_color, phone_no, banner_image_url, button_color_code, bg_color_code, state, city, button_text_color, verified, shop_name')
          .inFilter('user_id', creatorIds);

      final creatorsMap = {
        for (var p in creatorsResponse) p['user_id'].toString(): p
      };

      // Collect all event IDs
      final eventIds = eventList.map((e) => e['id']).toList();

      // Fetch participants for all events in bulk
      final allParticipants = await _supabase
          .from('event_participants')
          .select('id, user_id, event_id, joined_at')
          .inFilter('event_id', eventIds);

      // Group participants by event_id
      final participantsByEvent = <String, List<Map<String, dynamic>>>{};
      final participantUserIds = <String>{};

      for (var p in allParticipants) {
        final eid = p['event_id'].toString();
        participantsByEvent
            .putIfAbsent(eid, () => [])
            .add(Map<String, dynamic>.from(p));
        participantUserIds.add(p['user_id'].toString());
      }

      // Fetch participant profiles in bulk
      final participantProfilesResponse = await _supabase
          .from('profile')
          .select('id, user_id, name, profile_image_url, bio')
          .inFilter('user_id', participantUserIds.toList());

      final participantProfilesMap = {
        for (var p in participantProfilesResponse) p['user_id'].toString(): p
      };

      // Process each event with the pre-fetched data
      final processedEvents = eventList.map((event) {
        final eid = event['id'].toString();
        final eventParticipants = participantsByEvent[eid] ?? [];

        final participantsWithProfiles = eventParticipants.map((p) {
          return {
            ...p,
            'participant_profile':
                participantProfilesMap[p['user_id'].toString()],
          };
        }).toList();

        final isUserJoined = eventParticipants.any(
          (p) => p['user_id'] == _currentUserId,
        );

        return {
          ...event,
          'creator_profile': creatorsMap[event['user_id'].toString()],
          'event_participants': participantsWithProfiles,
          'participant_count': eventParticipants.length,
          'is_user_joined': isUserJoined,
          'participants_list': participantsWithProfiles,
        };
      }).toList();

      setState(() {
        _events = processedEvents;
        _filteredEvents = processedEvents;
      });
    } catch (error) {
      print('Error loading events: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $error'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshSingleEvent(String eventId) async {
    try {
      final eventResponse = await _supabase.from('events').select('''
          id,
          created_at,
          user_id,
          title,
          description,
          location,
          event_date,
          image_url,
          price,
          is_active,
          max_participants,
          current_participants
        ''').eq('id', eventId).single();

      final creatorProfile = await _supabase
          .from('profile')
          .select(
              'id, user_id, name, profile_image_url, bio,bg_text_color, phone_no,banner_image_url,button_color_code,bg_color_code,state,city,button_text_color,verified,shop_name')
          .eq('user_id', eventResponse['user_id'])
          .maybeSingle();

      final participants = await _supabase
          .from('event_participants')
          .select('id, user_id, joined_at')
          .eq('event_id', eventId);

      final participantsWithProfiles = <Map<String, dynamic>>[];
      for (final participant in participants) {
        final participantProfile = await _supabase
            .from('profile')
            .select(
                'id, user_id, name, profile_image_url, bio,bg_text_color, phone_no,banner_image_url,button_color_code,bg_color_code,state,city,button_text_color,verified,shop_name')
            .eq('user_id', participant['user_id'])
            .maybeSingle();

        participantsWithProfiles.add({
          ...participant,
          'participant_profile': participantProfile,
        });
      }

      final isUserJoined = participants.any(
        (p) => p['user_id'] == _currentUserId,
      );

      final updatedEvent = {
        ...eventResponse,
        'creator_profile': creatorProfile,
        'event_participants': participantsWithProfiles,
        'participant_count': participants.length,
        'is_user_joined': isUserJoined,
        'participants_list': participantsWithProfiles,
      };

      setState(() {
        final index = _events.indexWhere((e) => e['id'] == eventId);
        if (index != -1) {
          _events[index] = updatedEvent;
          _filterEvents();
        }
      });
    } catch (error) {
      print('Error refreshing event: $error');
    }
  }

  Future<void> _joinEvent(String eventId) async {
    if (_currentUserId == null) return;

    try {
      final existingParticipation = await _supabase
          .from('event_participants')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (existingParticipation != null) {
        await _supabase
            .from('event_participants')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', _currentUserId!);

        await _supabase.rpc('decrement_event_participants', params: {
          'event_id': eventId,
        });

        _showSnackBar('Left event successfully', Colors.orange);
      } else {
        final event = _events.firstWhere((e) => e['id'] == eventId);
        final maxParticipants = event['max_participants'] ?? 50;
        final currentCount = event['participant_count'] ?? 0;

        if (currentCount >= maxParticipants) {
          _showSnackBar('Event is full!', Colors.red);
          return;
        }

        await _supabase.from('event_participants').insert({
          'event_id': eventId,
          'user_id': _currentUserId!,
        });

        await _supabase.rpc('increment_event_participants', params: {
          'event_id': eventId,
        });

        _showSnackBar('Joined event successfully!', Colors.green);
        // _showWelcomeCard(event);
      }

      _refreshSingleEvent(eventId);
    } catch (error) {
      _showSnackBar('Error: $error', Colors.red);
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      // First, get the event data to retrieve the image URL
      final eventResponse = await _supabase
          .from('events')
          .select('image_url')
          .eq('id', eventId)
          .single();

      final String? imageUrl = eventResponse['image_url'];

      // Delete event participants first (foreign key constraint)
      await _supabase
          .from('event_participants')
          .delete()
          .eq('event_id', eventId);

      // Delete the event from database
      await _supabase.from('events').delete().eq('id', eventId);

      // Delete the image from storage if it exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          // Extract the file path from the public URL
          // Assuming the URL format is: https://your-project.supabase.co/storage/v1/object/public/event_images/filename
          final Uri uri = Uri.parse(imageUrl);
          final String filePath = uri.pathSegments.last; // Gets the filename
          final String storagePath = 'event_images/$filePath';

          await _supabase.storage.from('event_images').remove([storagePath]);

          print('Image deleted successfully: $storagePath');
        } catch (imageError) {
          // Log the error but don't fail the entire operation
          print('Warning: Failed to delete image: $imageError');
          // You might want to show a warning to the user or handle this differently
        }
      }

      // Update local state
      setState(() {
        _events.removeWhere((event) => event['id'] == eventId);
        _filterEvents();
      });

      _showSnackBar(
          'Event and associated image deleted successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error deleting event: $error', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  // void _showWelcomeCard(Map<String, dynamic> event) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (context) => WelcomeCard(
  //       key: _welcomeCardKey,
  //       event: event,
  //       currentUserId: _currentUserId,
  //     ),
  //   );
  // }

  void _showEventDetails(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EventDetailsModal(
        event: event,
        currentUserId: _currentUserId,
        onJoinLeave: () => _joinEvent(event['id']),
        onDelete: event['user_id'] == _currentUserId
            ? () => _deleteEvent(event['id'])
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 395,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Visit @Events',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final isAuthenticated =
                          await AuthAlertBox.checkAuthAndShowAlert(
                        context: context,
                        customMessage: "Please login to continue",
                      );
                      if (isAuthenticated) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const EventsDisplayPage(),
                        //   ),
                        // );
                      }
                    },
                    child: Row(
                      children: [
                        if (widget.userId == null) ...[
                          const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.yellow,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                              width: 4), // spacing between text & icon
                          const Icon(
                            Icons.search,
                            color: Colors.yellow,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: _isLoading
                  ? const SixSquareHorizotalShimmer(
                      cardWidth: 160,
                      cardHeight: 380,
                      itemCount: 6,
                      baseColor: Color.fromARGB(255, 103, 103, 103),
                      highlightColor: Color.fromARGB(255, 188, 187, 187),
                      duration: Duration(milliseconds: 1200),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      color: Colors.yellow,
                      backgroundColor: Colors.black,
                      child: _filteredEvents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchController.text.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.event_busy,
                                    size: 60,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'No matching events found'
                                        : 'No events scheduled currently',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 390, // Fixed height for the ListView
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _filteredEvents[index];
                                  return Container(
                                    width: 180, // Fixed width for each card
                                    margin: const EdgeInsets.only(right: 16),
                                    child: MinimalEventCard(
                                      event: event,
                                      currentUserId: _currentUserId,
                                      onTap: () async {
                                        final isAuthenticated =
                                            await AuthAlertBox
                                                .checkAuthAndShowAlert(
                                          context: context,
                                          customMessage:
                                              "Please login to continue",
                                        );
                                        if (isAuthenticated) {
                                          _showEventDetails(event);
                                        }
                                      },
                                      onJoinLeave: () async {
                                        final isAuthenticated =
                                            await AuthAlertBox
                                                .checkAuthAndShowAlert(
                                          context: context,
                                          customMessage:
                                              "Please login to continue",
                                        );
                                        if (isAuthenticated) {
                                          _joinEvent(event['id']);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MinimalEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback onJoinLeave;
  final VoidCallback? onDelete;

  const MinimalEventCard({
    super.key,
    required this.event,
    required this.currentUserId,
    required this.onTap,
    required this.onJoinLeave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final eventDate = DateTime.parse(event['event_date']);
    final participantCount = event['participant_count'] ?? 0;
    final maxParticipants = event['max_participants'] ?? 50;
    final isUserJoined = event['is_user_joined'] ?? false;
    final creatorProfile = event['creator_profile'];
    final isFull = participantCount >= maxParticipants;
    final isCreator = event['user_id'] == currentUserId;
    final participants = (event['participants_list'] as List).take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.yellow.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with creator and actions
                Row(
                  children: [
                    if (creatorProfile != null) ...[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.yellow,
                        backgroundImage: creatorProfile['profile_image_url'] !=
                                null
                            ? NetworkImage(creatorProfile['profile_image_url'])
                            : null,
                        child: creatorProfile['profile_image_url'] == null
                            ? const Icon(Icons.person,
                                size: 12, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          creatorProfile['name'] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (isCreator && onDelete != null)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1a1a1a),
                              title: const Text(
                                'Delete Event',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this event?',
                                style: TextStyle(color: Colors.grey),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete!();
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ReportButton(
                      contentType: 'event',
                      contentId: event['id'],
                      contentTitle: event['title'],
                      onReportSubmitted: () {
                        // Optional: Show feedback to user
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Thank you for your report. We\'ll review it soon.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.yellow.shade600,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.yellow.shade600,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(eventDate),
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Image.network(
                  event['image_url'],
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image,
                          size: 50, color: Colors.grey),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Participants count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.yellow.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$participantCount/$maxParticipants',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Join/Leave Button
                if (currentUserId != null && !isCreator)
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: isFull && !isUserJoined ? null : onJoinLeave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUserJoined
                            ? Colors.red.shade600
                            : isFull
                                ? Colors.grey.shade600
                                : Colors.yellow,
                        foregroundColor: isUserJoined || isFull
                            ? Colors.white
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: Text(
                        isUserJoined
                            ? 'Leave'
                            : isFull
                                ? 'Full'
                                : 'Join',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // Status indicator for creator
                if (isCreator)
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text(
                        'Your Event',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Joined indicator
                if (isUserJoined && !isCreator)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 40, // avatar size container
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      final profile = participant['participant_profile'];
                      final imageUrl = profile?['profile_image_url'];

                      return Transform.translate(
                        offset: Offset(index * -12.0, 0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              imageUrl != null ? NetworkImage(imageUrl) : null,
                          child: imageUrl == null
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventDetailsModal extends StatelessWidget {
  final Map<String, dynamic> event;
  final String? currentUserId;
  final VoidCallback onJoinLeave;
  final VoidCallback? onDelete;

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.currentUserId,
    required this.onJoinLeave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final eventDate = DateTime.parse(event['event_date']);
    final participantCount = event['participant_count'] ?? 0;
    final maxParticipants = event['max_participants'] ?? 50;
    final isUserJoined = event['is_user_joined'] ?? false;
    final creatorProfile = event['creator_profile'];
    final isFull = participantCount >= maxParticipants;
    final isCreator = event['user_id'] == currentUserId;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with creator info and delete button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VerfiedSwitchPage(userId: event['user_id']),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        if (creatorProfile != null) ...[
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.yellow,
                            backgroundImage:
                                creatorProfile['profile_image_url'] != null
                                    ? NetworkImage(
                                        creatorProfile['profile_image_url'])
                                    : null,
                            child: creatorProfile['profile_image_url'] == null
                                ? const Icon(Icons.person,
                                    size: 20, color: Colors.black)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Created by',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  creatorProfile['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (isCreator && onDelete != null)
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1a1a1a),
                                  title: const Text(
                                    'Delete Event',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to delete this event? This action cannot be undone.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        onDelete!();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Image.network(
                    event['image_url'],
                    // height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    event['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  event['price'] != null && event['price'].toString().isNotEmpty
                      ? Text(
                          '₹${event['price']}',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 6),
                  Text(
                    event['description'],
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Event details
                  _buildDetailRow(
                    Icons.location_on,
                    'Location',
                    event['location'],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.access_time,
                    'Date & Time',
                    DateFormat('EEEE, MMM dd, yyyy - hh:mm a')
                        .format(eventDate),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    Icons.people,
                    'Participants',
                    '$maxParticipants Allowed',
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WhatsAppGroupChat(
                                    groupId: 'p:${creatorProfile['user_id']}',
                                    groupName: creatorProfile['name'] ?? 'User',
                                    groupImage:
                                        creatorProfile['profile_image_url'],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow.shade400,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('Chat to Book now',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Participants list
                  if (event['participants_list'] != null &&
                      (event['participants_list'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              color: Colors.yellow.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Joined Members',
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...((event['participants_list'] as List)
                            .map((participant) {
                          final profile = participant['participant_profile'];
                          final isCurrentUser =
                              participant['user_id'] == currentUserId;
                          final name = profile?['name'] ?? 'Unknown User';
                          final joinedAt =
                              DateTime.parse(participant['joined_at']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.yellow.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: isCurrentUser
                                  ? Border.all(
                                      color:
                                          Colors.yellow.withValues(alpha: 0.3))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isCurrentUser
                                      ? Colors.yellow
                                      : Colors.grey.shade600,
                                  backgroundImage:
                                      profile?['profile_image_url'] != null
                                          ? NetworkImage(
                                              profile['profile_image_url'])
                                          : null,
                                  child: profile?['profile_image_url'] == null
                                      ? Icon(
                                          Icons.person,
                                          color: isCurrentUser
                                              ? Colors.black
                                              : Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isCurrentUser ? 'You' : name,
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? Colors.yellow
                                              : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Joined ${DateFormat('MMM dd, yyyy').format(joinedAt)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentUser)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'You',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    ),
                  const SizedBox(height: 32),

                  // Action Button
                  if (currentUserId != null && !isCreator)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isFull && !isUserJoined
                            ? null
                            : () {
                                Navigator.pop(context);
                                onJoinLeave();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUserJoined
                              ? Colors.red.shade600
                              : isFull
                                  ? Colors.grey.shade600
                                  : Colors.yellow,
                          foregroundColor: isUserJoined || isFull
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isUserJoined
                                  ? Icons.exit_to_app
                                  : isFull
                                      ? Icons.block
                                      : Icons.event_available,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isUserJoined
                                  ? 'Leave Event'
                                  : isFull
                                      ? 'Event Full'
                                      : 'Join Event',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (isCreator)
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Your Event',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.yellow.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiagonalSplitPainter extends CustomPainter {
  final Color color;

  DiagonalSplitPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.7, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
/////////
///
///

class TexturePainter extends CustomPainter {
  final Color color;

  TexturePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Create texture with random dots and lines
    for (int i = 0; i < 30; i++) {
      final x = (size.width * 0.1) + (i % 6) * (size.width * 0.15);
      final y = (size.height * 0.2) + (i ~/ 6) * (size.height * 0.15);

      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }

    // Add some diagonal lines for texture
    paint.strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final startY = size.height * 0.1 + i * (size.height * 0.1);
      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width * 0.3, startY - size.height * 0.05),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
/////
// Shimmer

class SixSquareHorizotalShimmer extends StatefulWidget {
  final double cardWidth;
  final double cardHeight;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final int itemCount;

  const SixSquareHorizotalShimmer({
    super.key,
    this.cardWidth = 350.0,
    this.cardHeight = 350.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
    this.itemCount = 6,
  });

  @override
  State<SixSquareHorizotalShimmer> createState() =>
      _SixSquareHorizotalShimmerState();
}

class _SixSquareHorizotalShimmerState extends State<SixSquareHorizotalShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
      ),
      child: SizedBox(
        height: widget.cardHeight,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.itemCount,
              itemBuilder: (context, index) {
                return Container(
                  width: widget.cardWidth,
                  height: widget.cardHeight,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.baseColor,
                        widget.highlightColor,
                        widget.baseColor,
                      ],
                      stops: [
                        _animation.value - 0.3,
                        _animation.value,
                        _animation.value + 0.3,
                      ].map((e) => e.clamp(0.0, 1.0)).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
