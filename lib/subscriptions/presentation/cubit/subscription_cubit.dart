import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/subscription.dart';
import '../../domain/usecases/subscription_usecases.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionListState> {
  final GetSubscriptions getSubscriptions;
  final AddSubscription addSubscription;
  final UpdateSubscription updateSubscription;
  final DeleteSubscription deleteSubscription;

  SubscriptionCubit({
    required this.getSubscriptions,
    required this.addSubscription,
    required this.updateSubscription,
    required this.deleteSubscription,
  }) : super(const SubscriptionListState());

  Future<void> load() async {
    emit(state.copyWith(status: SubscriptionStatusState.loading));
    try {
      final list = await getSubscriptions();
      emit(state.copyWith(
          status: SubscriptionStatusState.loaded, subscriptions: list));
    } catch (e) {
      emit(state.copyWith(
          status: SubscriptionStatusState.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> create(Subscription s) async {
    await addSubscription(s);
    await load();
  }

  Future<void> edit(Subscription s) async {
    await updateSubscription(s);
    await load();
  }

  Future<void> remove(String id) async {
    await deleteSubscription(id);
    await load();
  }

  Future<void> setStatus(Subscription s, SubscriptionStatus status) async {
    await updateSubscription(s.copyWith(status: status));
    await load();
  }
}
