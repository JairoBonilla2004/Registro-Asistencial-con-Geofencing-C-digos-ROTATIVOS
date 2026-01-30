import 'package:equatable/equatable.dart';

/// Entidad de Usuario del dominio
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String provider;
  final List<String> roles;
  final bool enabled;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.provider,
    required this.roles,
    required this.enabled,
    required this.createdAt,
  });

  bool get isStudent => roles.contains('STUDENT');
  bool get isTeacher => roles.contains('TEACHER');

  @override
  List<Object?> get props => [id, email, fullName, provider, roles, enabled, createdAt];
}
