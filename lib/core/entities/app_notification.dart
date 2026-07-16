import 'package:equatable/equatable.dart';

enum NotificationType { budgetAlert, billReminder, insight, transaction, system }

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? date,
    NotificationType? type,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, date, type, isRead];
}
