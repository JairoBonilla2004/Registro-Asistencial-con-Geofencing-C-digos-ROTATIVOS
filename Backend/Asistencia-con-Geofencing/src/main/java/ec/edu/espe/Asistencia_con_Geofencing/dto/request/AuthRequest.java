package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthRequest {

    @NotBlank(message = "Provider is required (LOCAL, GOOGLE, FACEBOOK, EXTERNAL)")
    private String provider; // "LOCAL", "GOOGLE", "FACEBOOK", "EXTERNAL"
    private String email;
    private String password;
    private String token;

    public void validate() {
        String providerUpper = provider.toUpperCase();
        switch (providerUpper) {
            case "LOCAL":
                if (token == null || token.isEmpty()) {
                    throw new IllegalArgumentException("Token is required for LOCAL authentication (must be base64(email:password))");
                }
                break;

            case "GOOGLE":
            case "FACEBOOK":
            case "EXTERNAL":
                if (token == null || token.isEmpty()) {
                    throw new IllegalArgumentException("Token is required for " + providerUpper + " authentication");
                }
                break;

            default:
                throw new IllegalArgumentException("Unsupported provider: " + provider +
                        ". Supported: LOCAL, GOOGLE, FACEBOOK, EXTERNAL");
        }
    }
}