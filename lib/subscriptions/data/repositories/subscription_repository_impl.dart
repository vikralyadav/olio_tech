import '../../../core/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource dataSource;
  SubscriptionRepositoryImpl(this.dataSource);

  @override
  Future<List<Subscription>> getAll() => dataSource.getAll();

  @override
  Future<Subscription> add(Subscription subscription) =>
      dataSource.add(subscription);

  @override
  Future<Subscription> update(Subscription subscription) =>
      dataSource.update(subscription);

  @override
  Future<void> delete(String id) => dataSource.delete(id);
}
