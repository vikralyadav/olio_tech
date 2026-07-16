import '../../../core/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<List<AppNotification>> getAll() => dataSource.getAll();

  @override
  Future<void> markRead(String id) => dataSource.markRead(id);

  @override
  Future<void> markAllRead() => dataSource.markAllRead();

  @override
  Future<void> delete(String id) => dataSource.delete(id);

  @override
  Future<void> clearAll() => dataSource.clearAll();

  @override
  Future<AppNotification> add(AppNotification notification) =>
      dataSource.add(notification);
}
