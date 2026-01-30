import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      return Left(const ValidationFailure('Todos los campos son requeridos'));
    }

    if (!_isValidEmail(email)) {
      return Left(const ValidationFailure('Email inválido'));
    }

    if (password.length < 6) {
      return Left(const ValidationFailure('La contraseña debe tener al menos 6 caracteres'));
    }

    if (fullName.length < 3) {
      return Left(const ValidationFailure('El nombre debe tener al menos 3 caracteres'));
    }

    return await repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
