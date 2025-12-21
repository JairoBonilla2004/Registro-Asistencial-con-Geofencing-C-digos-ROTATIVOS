package ec.edu.espe.Asistencia_con_Geofencing.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GenerateStudentReportRequest {
    
    private java.time.LocalDateTime startDate;
    private java.time.LocalDateTime endDate;
}
