import '../../../core/entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getAll();
  Future<Subscription> add(Subscription subscription);
  Future<Subscription> update(Subscription subscription);
  Future<void> delete(String id);
}
