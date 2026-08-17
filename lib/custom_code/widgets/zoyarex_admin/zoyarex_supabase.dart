import 'package:supabase_flutter/supabase_flutter.dart';

class ZoyarexSupabase {
  // Isolated Supabase instance for Zoyarex POS Admin
  static final SupabaseClient client = SupabaseClient(
    'https://aleovgcuurgknvjuipoe.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsZW92Z2N1dXJna252anVpcG9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMDUzNjYsImV4cCI6MjA5Nzc4MTM2Nn0._ZvWxRsyUFNE7A8tzlybT_Tuflkah5q5K9C1m49z39U',
  );

  static String? _connectedTenantId;

  static void connectToTenant(String tenantId) {
    _connectedTenantId = tenantId;
  }

  static void disconnectTenant() {
    _connectedTenantId = null;
  }

  static String get currentTenantId {
    if (_connectedTenantId != null) {
      return _connectedTenantId!;
    }
    final metadata = client.auth.currentUser?.userMetadata;
    return (metadata?['tenant_id'] as String?) ?? '12345678-1234-1234-1234-123456789012';
  }

  static String get currentUserRole {
    final metadata = client.auth.currentUser?.userMetadata;
    return (metadata?['role'] as String?) ?? 'admin';
  }
}

extension ZoyarexQueryExtension on PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  PostgrestFilterBuilder<List<Map<String, dynamic>>> applyTenantFilter(String tableName) {
    if (ZoyarexSupabase.currentUserRole == 'superadmin') {
      return this;
    }
    
    const tablesWithoutTenantId = [
      'branches', 
      'apps', 
      'waitlist', 
      'kitchen_displays', 
      'printers', 
      'payment_modes',
      'customer_types',
      'customer_groups'
    ];
    
    if (tablesWithoutTenantId.contains(tableName)) {
      return this;
    }
    
    return eq('tenant_id', ZoyarexSupabase.currentTenantId);
  }
}
