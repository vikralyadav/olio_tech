import 'package:equatable/equatable.dart';

import '../../../core/entities/subscription.dart';

enum SubscriptionStatusState { initial, loading, loaded, error }

class SubscriptionListState extends Equatable {
  final SubscriptionStatusState status;
  final List<Subscription> subscriptions;
  final String? errorMessage;

  const SubscriptionListState({
    this.status = SubscriptionStatusState.initial,
    this.subscriptions = const [],
    this.errorMessage,
  });

  List<Subscription> get active =>
      subscriptions.where((s) => s.status == SubscriptionStatus.active).toList();

  double get monthlyTotal =>
      active.fold(0.0, (s, sub) => s + sub.monthlyAmount);

  double get yearlyTotal => active.fold(0.0, (s, sub) => s + sub.yearlyAmount);

  /// Active subscriptions sorted by nearest billing date.
  List<Subscription> get upcoming {
    final list = List<Subscription>.from(active)
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return list;
  }

  SubscriptionListState copyWith({
    SubscriptionStatusState? status,
    List<Subscription>? subscriptions,
    String? errorMessage,
  }) {
    return SubscriptionListState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subscriptions, errorMessage];
}
