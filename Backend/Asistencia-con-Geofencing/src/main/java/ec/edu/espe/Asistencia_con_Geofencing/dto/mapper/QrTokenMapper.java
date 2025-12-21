package ec.edu.espe.Asistencia_con_Geofencing.dto.mapper;

import ec.edu.espe.Asistencia_con_Geofencing.dto.response.QrTokenResponse;
import ec.edu.espe.Asistencia_con_Geofencing.model.QrToken;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;

@Component
public class QrTokenMapper {

    public QrTokenResponse toResponse(QrToken token) {
        if (token == null) {
            return null;
        }

        Integer validitySeconds = null;
        if (token.getExpiresAt() != null) {
            validitySeconds = (int) Duration.between(LocalDateTime.now(), token.getExpiresAt()).getSeconds();
            if (validitySeconds < 0) {
                validitySeconds = 0;
            }
        }

        return QrTokenResponse.builder()
                .token(token.getToken())
                .expiresAt(token.getExpiresAt())
                .validitySeconds(validitySeconds)
                .build();
    }
}
