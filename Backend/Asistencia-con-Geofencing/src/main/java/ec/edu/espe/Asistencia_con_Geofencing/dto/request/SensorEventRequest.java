package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import ec.edu.espe.Asistencia_con_Geofencing.model.enums.SensorType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SensorEventRequest {

    @NotNull(message = "Session ID is required")
    private UUID sessionId;

    private UUID attendanceId;

    @NotNull(message = "Sensor type is required")
    private SensorType type;

    @NotNull(message = "Sensor value is required")
    private String value;

    @NotNull(message = "Device time is required")
    private LocalDateTime deviceTime;
}
