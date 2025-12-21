package ec.edu.espe.Asistencia_con_Geofencing.dto.response;

import ec.edu.espe.Asistencia_con_Geofencing.model.enums.ReportType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportResponse {

    private UUID reportId;
    private ReportType reportType;
    private String filePath;
    private LocalDateTime requestedAt;
    private String downloadUrl;
}
