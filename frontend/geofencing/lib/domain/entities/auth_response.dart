import 'package:equatable/equatable.dart';
import 'user.dart';

/// Entidad de Respuesta de Autenticación
class AuthResponse extends Equatable {
  final String token;
  final String type;
  final User user;

  const AuthResponse({
    required this.token,
    required this.type,
    required this.user,
  });

  @override
  List<Object?> get props => [token, type, user];
}
