package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import ec.edu.espe.Asistencia_con_Geofencing.model.enums.PlatformType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeviceRegisterRequest {

    @NotBlank(message = "Device identifier is required")
    private String deviceIdentifier;

    @NotNull(message = "Platform is required")
    private PlatformType platform;

    private String fcmToken;
}
