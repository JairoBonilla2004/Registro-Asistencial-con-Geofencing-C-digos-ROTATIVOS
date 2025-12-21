package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.ReportRequest;
import ec.edu.espe.Asistencia_con_Geofencing.model.enums.ReportType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface ReportRequestRepository extends JpaRepository<ReportRequest, UUID> {

    List<ReportRequest> findByRequestedByIdOrderByRequestedAtDesc(UUID requestedBy);

    List<ReportRequest> findByReportType(ReportType reportType);

    List<ReportRequest> findByStudentId(UUID studentId);

    List<ReportRequest> findBySessionId(UUID sessionId);

    @Query("SELECT rr FROM ReportRequest rr WHERE rr.filePath IS NULL " +
           "ORDER BY rr.requestedAt ASC")
    List<ReportRequest> findPendingReports();

    @Query("SELECT rr FROM ReportRequest rr WHERE rr.requestedBy.id = :requestedBy " +
           "AND rr.filePath IS NOT NULL ORDER BY rr.requestedAt DESC")
    List<ReportRequest> findCompletedReportsByUser(@Param("requestedBy") UUID requestedBy);

    @Query("SELECT rr FROM ReportRequest rr WHERE rr.requestedAt >= :since " +
           "ORDER BY rr.requestedAt DESC")
    List<ReportRequest> findRecentReports(@Param("since") LocalDateTime since);

    long countByRequestedById(UUID requestedBy);

    long countByReportType(ReportType reportType);
}
