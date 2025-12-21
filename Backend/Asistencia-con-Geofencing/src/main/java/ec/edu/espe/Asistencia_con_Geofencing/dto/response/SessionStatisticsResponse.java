package ec.edu.espe.Asistencia_con_Geofencing.dto.response;

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
public class SessionStatisticsResponse {

    private UUID sessionId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer totalAttendances;
    private Integer validGeofenceAttendances;
    private Integer invalidGeofenceAttendances;
    private Double validGeofencePercentage;
}
