package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.Notification;
import ec.edu.espe.Asistencia_con_Geofencing.model.enums.NotificationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    List<Notification> findByUserIdOrderBySentAtDesc(UUID userId);

    List<Notification> findByUserIdAndType(UUID userId, NotificationType type);

    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId " +
           "AND n.sentAt >= :since ORDER BY n.sentAt DESC")
    List<Notification> findRecentByUserId(@Param("userId") UUID userId, 
                                           @Param("since") LocalDateTime since);

    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId " +
           "AND n.sentAt >= :startDate AND n.sentAt <= :endDate " +
           "ORDER BY n.sentAt DESC")
    List<Notification> findByUserIdAndDateRange(
            @Param("userId") UUID userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    long countByUserId(UUID userId);

    long countByUserIdAndType(UUID userId, NotificationType type);

    @Query("SELECT n FROM Notification n WHERE n.sentAt >= :startOfDay")
    List<Notification> findSentToday(@Param("startOfDay") LocalDateTime startOfDay);
}
