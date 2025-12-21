package ec.edu.espe.Asistencia_con_Geofencing.dto.response;

import ec.edu.espe.Asistencia_con_Geofencing.model.enums.NotificationType;
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
public class NotificationResponse {

    private UUID id;
    private String title;
    private String body;
    private NotificationType type;
    private LocalDateTime sentAt;
}
