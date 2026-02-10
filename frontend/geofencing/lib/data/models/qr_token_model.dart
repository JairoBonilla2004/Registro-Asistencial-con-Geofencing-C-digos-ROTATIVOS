import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/qr_token.dart';

part 'qr_token_model.g.dart';

@JsonSerializable()
class QRTokenModel extends QRToken {
  const QRTokenModel({
    required super.qrId,
    required super.token,
    required super.sessionId,
    required super.expiresAt,
    super.qrCodeBase64,
  });

  factory QRTokenModel.fromJson(Map<String, dynamic> json) =>
      _$QRTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$QRTokenModelToJson(this);

  QRToken toEntity() => QRToken(
        qrId: qrId,
        token: token,
        sessionId: sessionId,
        expiresAt: expiresAt,
        qrCodeBase64: qrCodeBase64,
      );
}
