import 'package:equatable/equatable.dart';

/// Entidad de Token QR
class QRToken extends Equatable {
  final String qrId;
  final String token;
  final String sessionId;
  final DateTime expiresAt;
  final String? qrCodeBase64;

  const QRToken({
    required this.qrId,
    required this.token,
    required this.sessionId,
    required this.expiresAt,
    this.qrCodeBase64,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [qrId, token, sessionId, expiresAt, qrCodeBase64];
}
