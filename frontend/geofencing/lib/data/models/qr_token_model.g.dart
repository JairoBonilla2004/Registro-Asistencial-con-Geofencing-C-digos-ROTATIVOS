// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QRTokenModel _$QRTokenModelFromJson(Map<String, dynamic> json) => QRTokenModel(
      qrId: json['qrId'] as String,
      token: json['token'] as String,
      sessionId: json['sessionId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      qrCodeBase64: json['qrCodeBase64'] as String?,
    );

Map<String, dynamic> _$QRTokenModelToJson(QRTokenModel instance) =>
    <String, dynamic>{
      'qrId': instance.qrId,
      'token': instance.token,
      'sessionId': instance.sessionId,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'qrCodeBase64': instance.qrCodeBase64,
    };
