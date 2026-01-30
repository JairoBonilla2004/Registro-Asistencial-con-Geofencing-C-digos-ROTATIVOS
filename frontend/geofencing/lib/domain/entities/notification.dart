import 'package:equatable/equatable.dart';

/// Entidad de Notificación
class AppNotification extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime sentAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.sentAt,
    this.readAt,
    this.data,
  });

  bool get isRead => readAt != null;
  bool get isUnread => readAt == null;

  @override
  List<Object?> get props => [id, type, title, body, sentAt, readAt, data];
}

/// Entidad de Lista de Notificaciones
class NotificationList extends Equatable {
  final int count;
  final List<AppNotification> notifications;

  const NotificationList({
    required this.count,
    required this.notifications,
  });

  @override
  List<Object?> get props => [count, notifications];
}
