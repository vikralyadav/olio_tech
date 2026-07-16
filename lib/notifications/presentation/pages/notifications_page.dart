import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/app_notification.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationCubit>();
    if (cubit.state.status == NotificationStatus.initial) cubit.load();
  }

  ({IconData icon, Color color}) _visual(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return (icon: Icons.warning_amber_rounded, color: Colors.orange);
      case NotificationType.billReminder:
        return (icon: Icons.event_repeat, color: Colors.blue);
      case NotificationType.insight:
        return (icon: Icons.insights, color: Colors.purple);
      case NotificationType.transaction:
        return (icon: Icons.swap_horiz, color: Colors.teal);
      case NotificationType.system:
        return (icon: Icons.info_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.notifications.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'read') cubit.markAllRead();
                  if (v == 'clear') cubit.clearAll();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'read', child: Text('Mark all as read')),
                  PopupMenuItem(value: 'clear', child: Text('Clear all')),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'fab_notifications',
        tooltip: 'Simulate notification',
        onPressed: () async {
          await cubit.simulateIncoming();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New notification received')),
            );
          }
        },
        child: const Icon(Icons.notifications_active_outlined),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const LoadingView();
          }
          if (state.notifications.isEmpty) {
            return const EmptyView(
              icon: Icons.notifications_none,
              title: 'No notifications',
              message: 'You are all caught up!',
            );
          }
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = state.notifications[index];
                final v = _visual(n.type);
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Theme.of(context).colorScheme.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => cubit.remove(n.id),
                  child: Container(
                    color: n.isRead
                        ? null
                        : Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.25),
                    child: ListTile(
                      onTap: () => cubit.markRead(n.id),
                      leading: CircleAvatar(
                        backgroundColor: v.color.withValues(alpha: 0.15),
                        child: Icon(v.icon, color: v.color),
                      ),
                      title: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight:
                              n.isRead ? FontWeight.w500 : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(n.body),
                      isThreeLine: true,
                      trailing: Text(
                        AppFormatters.relativeDate(n.date),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
