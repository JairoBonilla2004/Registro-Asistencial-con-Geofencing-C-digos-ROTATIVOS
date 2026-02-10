import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'dependency_providers.dart';

// Provider de notificaciones no leídas
final unreadNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getUnreadNotifications();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (notifications) => notifications,
  );
});

// Provider para contar notificaciones no leídas
final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(unreadNotificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.length,
    orElse: () => 0,
  );
});

// Provider para marcar notificación como leída
final markNotificationAsReadProvider = Provider<Future<void> Function(String)>((ref) {
  return (String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAsRead(notificationId);
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Invalidar el provider para refrescar la lista
        ref.invalidate(unreadNotificationsProvider);
      },
    );
  };
});

// Provider para marcar todas como leídas
final markAllAsReadProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAllAsRead();
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Invalidar el provider para refrescar la lista
        ref.invalidate(unreadNotificationsProvider);
      },
    );
  };
});
