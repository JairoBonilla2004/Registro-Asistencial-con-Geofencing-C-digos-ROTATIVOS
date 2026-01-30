import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/qr_token.dart';
import '../../repositories/session_repository.dart';

class GenerateQRUseCase {
  final SessionRepository repository;

  GenerateQRUseCase(this.repository);

  Future<Either<Failure, QRToken>> call(String sessionId) async {
    if (sessionId.isEmpty) {
      return Left(const ValidationFailure('ID de sesión requerido'));
    }

    return await repository.generateQRCode(sessionId);
  }
}
