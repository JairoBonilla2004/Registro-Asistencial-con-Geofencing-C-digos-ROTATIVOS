package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.SyncBatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface SyncBatchRepository extends JpaRepository<SyncBatch, UUID> {

    List<SyncBatch> findByUserIdOrderByReceivedAtDesc(UUID userId);

    List<SyncBatch> findByDeviceIdOrderByReceivedAtDesc(UUID deviceId);

    @Query("SELECT sb FROM SyncBatch sb WHERE sb.receivedAt >= :startDate " +
           "AND sb.receivedAt <= :endDate ORDER BY sb.receivedAt DESC")
    List<SyncBatch> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                     @Param("endDate") LocalDateTime endDate);

    @Query("SELECT sb FROM SyncBatch sb WHERE sb.user.id = :userId " +
           "AND sb.receivedAt >= :since ORDER BY sb.receivedAt DESC")
    List<SyncBatch> findRecentByUserId(@Param("userId") UUID userId, 
                                        @Param("since") LocalDateTime since);

    long countByUserId(UUID userId);

    @Query("SELECT SUM(sb.itemCount) FROM SyncBatch sb WHERE sb.user.id = :userId")
    Long sumItemCountByUserId(@Param("userId") UUID userId);
}
