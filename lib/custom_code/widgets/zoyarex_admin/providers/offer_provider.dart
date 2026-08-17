import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class OfferModel {
  final String id;
  final String name;
  final String discountType;
  final double discountValue;
  final bool isActive;

  OfferModel({
    required this.id,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id']?.toString() ?? json['offer_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['offer_name']?.toString() ?? 'Unnamed',
      discountType: json['discount_type']?.toString() ?? 'percentage',
      discountValue: json['discount_value'] != null ? (json['discount_value'] as num).toDouble() : 0.0,
      isActive: json['is_active'] ?? json['active'] ?? true,
    );
  }
}

final offerProvider = FutureProvider<List<OfferModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('offers')
        .select('*')
      .applyTenantFilter('offers')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => OfferModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
