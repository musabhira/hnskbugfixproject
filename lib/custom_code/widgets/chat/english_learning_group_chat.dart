import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/supabase/supabase.dart';
import 'whatsapp_group_chat.dart';
import 'package:shimmer/shimmer.dart';

class EnglishLearningGroupChatWidget extends ConsumerStatefulWidget {
  final VoidCallback onCancel;

  const EnglishLearningGroupChatWidget({
    super.key,
    required this.onCancel,
  });

  @override
  ConsumerState<EnglishLearningGroupChatWidget> createState() =>
      _EnglishLearningGroupChatWidgetState();
}

class _EnglishLearningGroupChatWidgetState
    extends ConsumerState<EnglishLearningGroupChatWidget> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isMember = false;
  String? _groupId;
  String? _currentUserProfileId;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    _initGroupAndMembership();
  }

  Future<void> _initGroupAndMembership() async {
    if (_currentUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Get user profile
      final profileResponse = await _supabase
          .from('profile')
          .select('id')
          .eq('user_id', _currentUserId!)
          .single();
      _currentUserProfileId = profileResponse['id'];

      // 2. Find group named 'English Hub'
      final groups = await _supabase
          .from('groups')
          .select('id')
          .eq('name', 'English Hub')
          .limit(1);

      String? tempGroupId;
      if ((groups as List).isEmpty) {
        // Group doesn't exist, create it
        final newGroup = await _supabase
            .from('groups')
            .insert({
              'name': 'English Hub',
              'description': 'Welcome to the English Hub!',
              'created_by': _currentUserId!,
              'is_public': true,
            })
            .select('id')
            .single();
        tempGroupId = newGroup['id']?.toString();
      } else {
        tempGroupId = (groups as List).first['id']?.toString();
      }

      _groupId = tempGroupId;

      if (_groupId != null) {
        // 3. Check membership
        final membership = await _supabase
            .from('group_members')
            .select('id')
            .eq('group_id', _groupId!)
            .eq('user_id', _currentUserId!)
            .eq('is_active', true)
            .limit(1);

        if ((membership as List).isNotEmpty) {
          _isMember = true;
        } else {
          // Auto-join silently
          await _supabase.from('group_members').insert({
            'group_id': _groupId!,
            'user_id': _currentUserId!,
            'role': 'member',
            'profile_id': _currentUserProfileId!,
            'is_active': true,
          });
          _isMember = true;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing English Hub group: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildShimmerLoading(BuildContext context) {
    const baseColor = Color(0xFF1E293B);
    const highlightColor = Color(0xFF334155);
    const darkBg = Color(0xFF070B0D);
    const appBarColor = Color(0xFF121B22);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 65,
                    height: 10,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.builder(
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 14,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemBuilder: (context, index) {
            final isMe = index % 2 == 0;
            final bubbleWidths = [170.0, 240.0, 130.0, 210.0, 280.0, 150.0, 220.0];
            final width = bubbleWidths[index % bubbleWidths.length];
            final height = (index % 3 == 0) ? 56.0 : ((index % 3 == 1) ? 40.0 : 48.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerLoading(context);
    }

    if (_isMember && _groupId != null) {
      return WhatsAppGroupChat(
        groupId: _groupId!,
        groupName: 'English Hub',
        showBackButton: false,
      );
    }

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('Failed to load group. Please try again.', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
