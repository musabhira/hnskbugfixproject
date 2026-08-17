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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2C34) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF121B22) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B0D) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121B22) : Colors.grey[200],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.builder(
          reverse: true,
          itemCount: 15,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemBuilder: (context, index) {
            final isMe = index % 2 == 0;
            final width = (index % 3 == 0)
                ? 180.0
                : (index % 3 == 1)
                    ? 130.0
                    : 240.0;
            final height = (index % 4 == 0)
                ? 40.0
                : (index % 4 == 1)
                    ? 50.0
                    : 45.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(12),
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
