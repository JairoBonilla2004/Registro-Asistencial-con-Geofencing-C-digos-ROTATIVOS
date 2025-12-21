package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.AttendanceSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AttendanceSessionRepository extends JpaRepository<AttendanceSession, UUID> {

    List<AttendanceSession> findByTeacherId(UUID teacherId);

    List<AttendanceSession> findByTeacherIdAndActive(UUID teacherId, Boolean active);

    List<AttendanceSession> findByActive(Boolean active);

    List<AttendanceSession> findByGeofenceId(UUID geofenceId);

    @Query("SELECT s FROM AttendanceSession s WHERE s.teacher.id = :teacherId " +
           "AND s.startTime >= :startDate AND s.startTime <= :endDate " +
           "ORDER BY s.startTime DESC")
    List<AttendanceSession> findByTeacherIdAndDateRange(
            @Param("teacherId") UUID teacherId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT s FROM AttendanceSession s LEFT JOIN FETCH s.geofence WHERE s.id = :sessionId")
    Optional<AttendanceSession> findByIdWithGeofence(@Param("sessionId") UUID sessionId);

    @Query("SELECT s FROM AttendanceSession s WHERE s.active = true " +
           "AND s.startTime <= :now " +
           "AND (s.endTime IS NULL OR s.endTime >= :now)")
    List<AttendanceSession> findCurrentlyActiveSessions(@Param("now") LocalDateTime now);
}
