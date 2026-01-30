import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_session.dart';
import '../../repositories/session_repository.dart';

class CreateSessionUseCase {
  final SessionRepository repository;

  CreateSessionUseCase(this.repository);

  Future<Either<Failure, AttendanceSession>> call({
    required String name,
    required String zoneId,
    required int qrRotationMinutes,
  }) async {
    if (name.isEmpty) {
      return Left(const ValidationFailure('El nombre de la sesión es requerido'));
    }
    
    if (zoneId.isEmpty) {
      return Left(const ValidationFailure('Debe seleccionar una zona'));
    }

    if (qrRotationMinutes < 1 || qrRotationMinutes > 60) {
      return Left(const ValidationFailure('Rotación de QR debe estar entre 1 y 60 minutos'));
    }

    return await repository.createSession(
      name: name,
      zoneId: zoneId,
      qrRotationMinutes: qrRotationMinutes,
    );
  }
}
