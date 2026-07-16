import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit(this.repository) : super(const NotificationState());

  Future<void> load() async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final list = await repository.getAll();
      emit(state.copyWith(
          status: NotificationStatus.loaded, notifications: list));
    } catch (e) {
      emit(state.copyWith(
          status: NotificationStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> markRead(String id) async {
    await repository.markRead(id);
    await load();
  }

  Future<void> markAllRead() async {
    await repository.markAllRead();
    await load();
  }

  Future<void> remove(String id) async {
    await repository.delete(id);
    await load();
  }

  Future<void> clearAll() async {
    await repository.clearAll();
    await load();
  }

  /// Simulates receiving a push notification.
  Future<void> simulateIncoming() async {
    final now = DateTime.now();
    const samples = [
      ('Spending Reminder',
          'You spent \$42.50 today. Tap to review your transactions.',
          NotificationType.insight),
      ('Budget Warning',
          'Your Shopping budget is almost used up for this month.',
          NotificationType.budgetAlert),
      ('Bill Due Soon', 'Adobe Creative Cloud (\$54.99) is due in 2 days.',
          NotificationType.billReminder),
    ];
    final pick = samples[now.second % samples.length];
    await repository.add(AppNotification(
      id: 'ntf_${now.microsecondsSinceEpoch}',
      title: pick.$1,
      body: pick.$2,
      date: now,
      type: pick.$3,
    ));
    await load();
  }
}
