import 'package:equatable/equatable.dart';

enum BillingCycle { weekly, monthly, quarterly, yearly }

enum SubscriptionStatus { active, paused, cancelled, expired }

class Subscription extends Equatable {
  final String id;
  final String name;
  final double amount;
  final BillingCycle cycle;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final String categoryId;
  final String categoryName;
  final SubscriptionStatus status;
  final String? logoUrl;
  final String? note;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.startDate,
    required this.nextBillingDate,
    required this.categoryId,
    required this.categoryName,
    this.status = SubscriptionStatus.active,
    this.logoUrl,
    this.note,
  });

  double get monthlyAmount {
    switch (cycle) {
      case BillingCycle.weekly:
        return amount * 4.33;
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3;
      case BillingCycle.yearly:
        return amount / 12;
    }
  }

  double get yearlyAmount {
    switch (cycle) {
      case BillingCycle.weekly:
        return amount * 52;
      case BillingCycle.monthly:
        return amount * 12;
      case BillingCycle.quarterly:
        return amount * 4;
      case BillingCycle.yearly:
        return amount;
    }
  }

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    BillingCycle? cycle,
    DateTime? startDate,
    DateTime? nextBillingDate,
    String? categoryId,
    String? categoryName,
    SubscriptionStatus? status,
    String? logoUrl,
    String? note,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      startDate: startDate ?? this.startDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
      logoUrl: logoUrl ?? this.logoUrl,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        cycle,
        startDate,
        nextBillingDate,
        categoryId,
        categoryName,
        status,
        logoUrl,
        note,
      ];
}
