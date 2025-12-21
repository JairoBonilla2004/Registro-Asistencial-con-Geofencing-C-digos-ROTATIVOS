package ec.edu.espe.Asistencia_con_Geofencing.dto.response;

import ec.edu.espe.Asistencia_con_Geofencing.model.enums.PlatformType;
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
public class DeviceResponse {

    private UUID id;
    private String deviceIdentifier;
    private PlatformType platform;
    private String fcmToken;
    private LocalDateTime lastSeen;
}
