import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pocketgang_task_service.dart';

/// 🚀 Service to share PocketGang items (Tasks, Diagrams) directly into group chat
class PocketGangChatShareService {
  PocketGangChatShareService._();
  static final PocketGangChatShareService instance = PocketGangChatShareService._();

  static const String _messagesTable = 'group_messages';

  /// Share a Task directly into the Gang's group chat
  Future<bool> shareTaskToGroupChat({
    required String groupId,
    required String userId,
    required PocketGangTask task,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final text = '📋 Task Shared: ${task.title}';

      final metadata = {
        'share_kind': 'gang_task',
        'task_id': task.id,
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'estimated_hours': task.estimatedHours,
        'assignees': task.assignedMemberNames,
      };

      await supabase.from(_messagesTable).insert({
        'group_id': groupId,
        'sender_id': userId,
        'message_text': text,
        'message_type': 'gang_share',
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabase.from('groups').update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      return true;
    } catch (e) {
      debugPrint('Error sharing task to group chat: $e');
      return false;
    }
  }

  /// Share a Diagram directly into the Gang's group chat
  Future<bool> shareDiagramToGroupChat({
    required String groupId,
    required String userId,
    required String diagramId,
    required String diagramTitle,
    required String templateKey,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final text = '📐 Diagram Shared: $diagramTitle';

      final metadata = {
        'share_kind': 'gang_diagram',
        'diagram_id': diagramId,
        'title': diagramTitle,
        'template': templateKey,
      };

      await supabase.from(_messagesTable).insert({
        'group_id': groupId,
        'sender_id': userId,
        'message_text': text,
        'message_type': 'gang_share',
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabase.from('groups').update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      return true;
    } catch (e) {
      debugPrint('Error sharing diagram to group chat: $e');
      return false;
    }
  }
}

