import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ExpenseTypeModel {
  final String id;
  final String name;
  final String? description;

  ExpenseTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory ExpenseTypeModel.fromJson(Map<String, dynamic> json) {
    return ExpenseTypeModel(
      id: json['id']?.toString() ?? json['expense_type_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['type_name']?.toString() ?? 'Unnamed',
      description: json['description']?.toString(),
    );
  }
}

class ExpenseModel {
  final String id;
  final String date;
  final String expenseTypeId;
  final String? expenseTypeName;
  final double amount;
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.date,
    required this.expenseTypeId,
    this.expenseTypeName,
    required this.amount,
    this.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? json['expense_id']?.toString() ?? '',
      date: json['date']?.toString() ?? json['expense_date']?.toString() ?? json['created_at']?.toString() ?? '',
      expenseTypeId: json['expense_type_id']?.toString() ?? '',
      expenseTypeName: json['expense_type']?['name']?.toString() ?? json['expense_type_name']?.toString(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      notes: json['notes']?.toString() ?? json['description']?.toString(),
    );
  }
}

final expenseTypeProvider = FutureProvider<List<ExpenseTypeModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('expense_types')
        .select('*')
      .applyTenantFilter('expense_types')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => ExpenseTypeModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});

final expenseProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  try {
    final response = await ZoyarexSupabase.client
        .from('expenses')
        .select('*, expense_type:expense_types(name)')
        .applyTenantFilter('expenses')
        .order('date', ascending: false);
    final data = response as List<dynamic>;
    return data.map((json) => ExpenseModel.fromJson(json)).toList();
  } catch (e) {
    try {
      final response = await ZoyarexSupabase.client
          .from('expenses')
          .select('*')
      .applyTenantFilter('expenses')
          .order('expense_date', ascending: false);
      final data = response as List<dynamic>;
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (innerE) {
      return [];
    }
  }
});
