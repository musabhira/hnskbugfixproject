import 'package:supabase_flutter/supabase_flutter.dart';

export 'database/database.dart';

String _kSupabaseUrl = 'https://gswhynuabdspnwudltth.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
      );
}
