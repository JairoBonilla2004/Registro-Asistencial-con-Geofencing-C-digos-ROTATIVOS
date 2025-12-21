package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExternalLoginRequest {

    @NotBlank(message = "External token is required")
    private String token;

    @NotBlank(message = "Provider is required")
    private String provider;
}
