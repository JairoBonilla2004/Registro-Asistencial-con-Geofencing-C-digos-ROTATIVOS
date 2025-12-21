package ec.edu.espe.Asistencia_con_Geofencing.dto.mapper;

import ec.edu.espe.Asistencia_con_Geofencing.dto.response.ReportResponse;
import ec.edu.espe.Asistencia_con_Geofencing.model.ReportRequest;
import org.springframework.stereotype.Component;

@Component
public class ReportMapper {

    public ReportResponse toResponse(ReportRequest report, String downloadUrl) {
        if (report == null) {
            return null;
        }

        return ReportResponse.builder()
                .reportId(report.getId())
                .reportType(report.getReportType())
                .filePath(report.getFilePath())
                .requestedAt(report.getRequestedAt())
                .downloadUrl(downloadUrl)
                .build();
    }
}
