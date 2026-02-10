import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime sentAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.sentAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      sentAt: sentAt,
      readAt: readAt,
      data: null,
    );
  }
}
