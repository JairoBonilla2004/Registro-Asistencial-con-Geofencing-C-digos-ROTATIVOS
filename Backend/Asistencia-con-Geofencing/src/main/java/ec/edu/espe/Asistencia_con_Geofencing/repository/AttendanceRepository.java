package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, UUID> {

    Optional<Attendance> findBySessionIdAndStudentId(UUID sessionId, UUID studentId);

    List<Attendance> findBySessionId(UUID sessionId);

    List<Attendance> findByStudentId(UUID studentId);

    List<Attendance> findBySessionIdAndWithinGeofence(UUID sessionId, Boolean withinGeofence);

    List<Attendance> findByIsSynced(Boolean isSynced);

    List<Attendance> findBySyncBatchId(UUID syncBatchId);

    List<Attendance> findBySourceDeviceId(UUID sourceDeviceId);

    @Query("SELECT COUNT(a) FROM Attendance a WHERE a.session.id = :sessionId")
    long countBySessionId(@Param("sessionId") UUID sessionId);

    @Query("SELECT COUNT(a) FROM Attendance a WHERE a.session.id = :sessionId " +
           "AND a.withinGeofence = :withinGeofence")
    long countBySessionIdAndWithinGeofence(@Param("sessionId") UUID sessionId, 
                                            @Param("withinGeofence") Boolean withinGeofence);

    @Query("SELECT a FROM Attendance a WHERE a.student.id = :studentId " +
           "AND a.serverTime >= :startDate AND a.serverTime <= :endDate " +
           "ORDER BY a.serverTime DESC")
    List<Attendance> findByStudentIdAndDateRange(
            @Param("studentId") UUID studentId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT a FROM Attendance a " +
           "LEFT JOIN FETCH a.session " +
           "LEFT JOIN FETCH a.student " +
           "WHERE a.session.id = :sessionId")
    List<Attendance> findBySessionIdWithDetails(@Param("sessionId") UUID sessionId);
}
