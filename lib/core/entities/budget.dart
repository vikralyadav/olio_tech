import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String categoryId;
  final String categoryName;
  final double limit;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.limit,
    required this.spent,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  double get remaining => limit - spent;
  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
  bool get isOverBudget => spent > limit;

  Budget copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? limit,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        categoryName,
        limit,
        spent,
        startDate,
        endDate,
        isActive,
      ];
}
