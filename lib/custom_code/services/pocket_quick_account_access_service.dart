import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';

/// 🔐 Service to manage Quick Account Switch / Auto Login permission
class PocketQuickAccountAccessService {
  static const String toolPermissionKey = 'quick_account_switch';

  /// Check whether the current user is permitted to see the Quick Account Switch button.
  /// Allowed if:
  /// 1. Current user is Master Admin (musabthonippadam@gmail.com / musabhira / mussabira).
  /// 2. User has explicit private access granted in `user_tool_permissions` with `tool_name = 'quick_account_switch'`.
  static Future<bool> canAccessQuickSwitch({String? userId, String? email}) async {
    try {
      final curEmail = email ?? SupaFlow.client.auth.currentUser?.email;
      if (AdminAuthService.isMasterAdminEmail(curEmail)) {
        return true;
      }

      final uid = userId ?? SupaFlow.client.auth.currentUser?.id;
      if (uid == null || uid.isEmpty) return false;

      final res = await SupaFlow.client
          .from('user_tool_permissions')
          .select('has_private_access, is_blocked')
          .eq('user_id', uid)
          .eq('tool_name', toolPermissionKey)
          .maybeSingle();

      if (res != null) {
        final isBlocked = res['is_blocked'] == true;
        if (isBlocked) return false;
        final hasAccess = res['has_private_access'] == true;
        return hasAccess;
      }
    } catch (e) {
      debugPrint('[QuickSwitchAccess] Error checking permission: $e');
    }
    return false;
  }

  /// Grant or revoke access for a specific user
  static Future<bool> setAccess(String targetUserId, bool hasAccess) async {
    try {
      await SupaFlow.client.from('user_tool_permissions').upsert({
        'user_id': targetUserId,
        'tool_name': toolPermissionKey,
        'has_private_access': hasAccess,
        'is_blocked': false,
      }, onConflict: 'user_id, tool_name');
      return true;
    } catch (e) {
      debugPrint('[QuickSwitchAccess] Error setting permission: $e');
      return false;
    }
  }

  /// Fetch all users with granted access
  static Future<List<Map<String, dynamic>>> getGrantedUsers() async {
    try {
      final res = await SupaFlow.client
          .from('user_tool_permissions')
          .select('user_id, has_private_access, is_blocked')
          .eq('tool_name', toolPermissionKey)
          .eq('has_private_access', true);

      final list = List<Map<String, dynamic>>.from(res as List);
      if (list.isEmpty) return [];

      final userIds = list.map((e) => e['user_id'].toString()).toList();
      final profiles = await SupaFlow.client
          .from('profile')
          .select('user_id, name, shop_name, profile_image_url')
          .inFilter('user_id', userIds);

      final profileMap = {
        for (var p in profiles) p['user_id']?.toString() ?? '': p
      };

      return list.map((item) {
        final uid = item['user_id'].toString();
        final prof = profileMap[uid];
        return {
          'user_id': uid,
          'name': prof?['name'] ?? 'Unknown User',
          'shop_name': prof?['shop_name'] ?? '',
          'profile_image_url': prof?['profile_image_url'],
          'has_private_access': item['has_private_access'] == true,
        };
      }).toList();
    } catch (e) {
      debugPrint('[QuickSwitchAccess] Error fetching granted users: $e');
      return [];
    }
  }
}
