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
public class SessionResponse {

    private UUID id;
    private UUID teacherId;
    private String teacherName;
    private UUID geofenceId;
    private String geofenceName;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Boolean active;
    private Integer attendanceCount;
}
