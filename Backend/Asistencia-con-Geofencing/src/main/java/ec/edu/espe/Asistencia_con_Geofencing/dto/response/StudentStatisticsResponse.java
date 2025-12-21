package ec.edu.espe.Asistencia_con_Geofencing.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentStatisticsResponse {

    private Integer totalSessions;
    private Integer attendedSessions;
    private Integer missedSessions;
    private Double attendancePercentage;
    private Integer validGeofenceCount;
    private Integer invalidGeofenceCount;
}
