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
public class SyncBatchResponse {

    private UUID batchId;
    private Integer itemCount;
    private Integer successCount;
    private Integer errorCount;
    private LocalDateTime receivedAt;
}
