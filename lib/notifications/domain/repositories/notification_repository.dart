import '../../../core/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getAll();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<AppNotification> add(AppNotification notification);
}
