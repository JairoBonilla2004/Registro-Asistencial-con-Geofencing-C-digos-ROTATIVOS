package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SyncBatchRequest {

    @NotNull(message = "Device ID is required")
    private UUID deviceId;

    @NotEmpty(message = "Attendances list cannot be empty")
    @Valid
    private List<RegisterAttendanceRequest> attendances;

    @Valid
    private List<SensorEventDto> sensorEvents;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SensorEventDto {
        @NotNull
        private UUID sessionId;
        
        private UUID attendanceId;
        
        @NotNull
        private String type;
        
        @NotNull
        private String value;
        
        @NotNull
        private java.time.LocalDateTime deviceTime;
    }
}
