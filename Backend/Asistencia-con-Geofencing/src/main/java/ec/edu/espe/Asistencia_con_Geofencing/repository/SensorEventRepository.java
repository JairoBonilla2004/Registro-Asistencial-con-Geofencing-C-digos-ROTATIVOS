package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.SensorEvent;
import ec.edu.espe.Asistencia_con_Geofencing.model.enums.SensorType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface SensorEventRepository extends JpaRepository<SensorEvent, UUID> {

    List<SensorEvent> findByUserId(UUID userId);

    List<SensorEvent> findBySessionId(UUID sessionId);

    List<SensorEvent> findByAttendanceId(UUID attendanceId);

    List<SensorEvent> findByType(SensorType type);

    List<SensorEvent> findByUserIdAndType(UUID userId, SensorType type);

    @Query("SELECT se FROM SensorEvent se WHERE se.user.id = :userId " +
           "AND se.deviceTime >= :startTime AND se.deviceTime <= :endTime " +
           "ORDER BY se.deviceTime ASC")
    List<SensorEvent> findByUserIdAndTimeRange(
            @Param("userId") UUID userId,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );

    @Query("SELECT se FROM SensorEvent se WHERE se.session.id = :sessionId " +
           "AND se.type = :type ORDER BY se.deviceTime ASC")
    List<SensorEvent> findBySessionIdAndType(@Param("sessionId") UUID sessionId, 
                                              @Param("type") SensorType type);

    long countBySessionIdAndType(UUID sessionId, SensorType type);
}
