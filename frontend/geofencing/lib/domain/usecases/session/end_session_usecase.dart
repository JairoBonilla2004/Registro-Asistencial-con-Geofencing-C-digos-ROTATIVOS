import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/session_repository.dart';

class EndSessionUseCase {
  final SessionRepository repository;

  EndSessionUseCase(this.repository);

  Future<Either<Failure, void>> call(String sessionId) async {
    if (sessionId.isEmpty) {
      return Left(const ValidationFailure('ID de sesión requerido'));
    }

    return await repository.endSession(sessionId);
  }
}
