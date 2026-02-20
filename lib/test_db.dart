import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://gswhynuabdspnwudltth.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIzNTcyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U');
  try {
    final res = await supabase.from('statuses').select('*').limit(1);
    print(res.first.keys);
  } catch (e) {
    print(e);
  }
}
