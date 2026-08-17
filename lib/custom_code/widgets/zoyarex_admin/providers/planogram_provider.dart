import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class PlanogramAssignmentModel {
  final String id;
  final String productId;
  final String productName;
  final String floorId;
  final String rackId;
  final String shelfId;
  final String locationId;

  PlanogramAssignmentModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.floorId,
    required this.rackId,
    required this.shelfId,
    required this.locationId,
  });

  factory PlanogramAssignmentModel.fromJson(Map<String, dynamic> json) {
    String prodName = 'Unknown Product';
    final prodData = json['products'];
    if (prodData != null && prodData is Map) {
      prodName = prodData['product_name']?.toString() ?? 'Unknown Product';
    }

    return PlanogramAssignmentModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: prodName,
      floorId: json['floor_id']?.toString() ?? '',
      rackId: json['rack_id']?.toString() ?? '',
      shelfId: json['shelf_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
    );
  }
}

final planogramProvider = FutureProvider<List<PlanogramAssignmentModel>>((ref) async {
  try {
    // Assumes a pos_planogram_assignments table linking products to physical locations
    final response = await ZoyarexSupabase.client
        .from('pos_planogram_assignments')
        .select('*, products(product_name)')
        .applyTenantFilter('pos_planogram_assignments');

    final data = response as List<dynamic>;
    return data.map((json) => PlanogramAssignmentModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
