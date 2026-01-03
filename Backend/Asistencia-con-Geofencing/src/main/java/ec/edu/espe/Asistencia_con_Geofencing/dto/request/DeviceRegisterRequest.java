package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DeviceRegisterRequest {
    @NotBlank(message = "El identificador del dispositivo es requerido")
    private String deviceIdentifier;

    @NotBlank(message = "La plataforma es requerida")
    private String platform; // "ANDROID" o "WEB"

    private String fcmToken;
}
