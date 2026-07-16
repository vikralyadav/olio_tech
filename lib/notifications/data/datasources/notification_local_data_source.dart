import '../../../core/data/app_database.dart';
import '../../../core/entities/app_notification.dart';

abstract class NotificationLocalDataSource {
  Future<List<AppNotification>> getAll();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<AppNotification> add(AppNotification notification);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final AppDatabase db;

  NotificationLocalDataSourceImpl(this.db);

  @override
  Future<List<AppNotification>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = List<AppNotification>.from(db.notifications)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> markRead(String id) async {
    final i = db.notifications.indexWhere((n) => n.id == id);
    if (i != -1) db.notifications[i] = db.notifications[i].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    for (int i = 0; i < db.notifications.length; i++) {
      db.notifications[i] = db.notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> delete(String id) async {
    db.notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> clearAll() async {
    db.notifications.clear();
  }

  @override
  Future<AppNotification> add(AppNotification notification) async {
    db.notifications.insert(0, notification);
    return notification;
  }
}
