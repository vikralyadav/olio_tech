import '../../../core/data/app_database.dart';
import '../../../core/entities/subscription.dart';

abstract class SubscriptionLocalDataSource {
  Future<List<Subscription>> getAll();
  Future<Subscription> add(Subscription subscription);
  Future<Subscription> update(Subscription subscription);
  Future<void> delete(String id);
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final AppDatabase db;
  SubscriptionLocalDataSourceImpl(this.db);

  @override
  Future<List<Subscription>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Subscription>.from(db.subscriptions);
  }

  @override
  Future<Subscription> add(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.subscriptions.add(subscription);
    return subscription;
  }

  @override
  Future<Subscription> update(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final i = db.subscriptions.indexWhere((s) => s.id == subscription.id);
    if (i != -1) db.subscriptions[i] = subscription;
    return subscription;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.subscriptions.removeWhere((s) => s.id == id);
  }
}
