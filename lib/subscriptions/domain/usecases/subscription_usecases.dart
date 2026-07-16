import '../../../core/entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptions {
  final SubscriptionRepository repository;
  GetSubscriptions(this.repository);
  Future<List<Subscription>> call() => repository.getAll();
}

class AddSubscription {
  final SubscriptionRepository repository;
  AddSubscription(this.repository);
  Future<Subscription> call(Subscription s) => repository.add(s);
}

class UpdateSubscription {
  final SubscriptionRepository repository;
  UpdateSubscription(this.repository);
  Future<Subscription> call(Subscription s) => repository.update(s);
}

class DeleteSubscription {
  final SubscriptionRepository repository;
  DeleteSubscription(this.repository);
  Future<void> call(String id) => repository.delete(id);
}
