import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getUnreadNotifications();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();
}
