import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://gswhynuabdspnwudltth.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIzNTcyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U');
  try {
    final Map<String, dynamic> data = {
        'user_id': '2756a927-85db-4f0e-8220-4f1d4c043149', 
        'profile_id': '2756a927-85db-4f0e-8220-4f1d4c043149', 
        'media_type': 'thought',
        'metadata': null,
        'media_url': null,
        'thumbnail_url': null,
        'caption': 'test',
        'duration': 5,
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'mentioned_group_id': null,
        'mentioned_profile_id': null,
        'is_active': true,
        'thought_id': '2756a927-85db-4f0e-8220-4f1d4c043149'
    };
    final res = await supabase.from('statuses').insert(data);
    print('SUCCESS: $res');
  } catch (e) {
    print('ERROR OCCURRED:');
    print(e);
  }
}
