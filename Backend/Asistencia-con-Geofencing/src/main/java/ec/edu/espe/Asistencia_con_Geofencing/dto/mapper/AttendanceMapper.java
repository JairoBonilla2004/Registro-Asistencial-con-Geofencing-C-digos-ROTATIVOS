package ec.edu.espe.Asistencia_con_Geofencing.dto.mapper;

import ec.edu.espe.Asistencia_con_Geofencing.dto.response.AttendanceResponse;
import ec.edu.espe.Asistencia_con_Geofencing.model.Attendance;
import org.springframework.stereotype.Component;

@Component
public class AttendanceMapper {

    public AttendanceResponse toResponse(Attendance attendance) {
        if (attendance == null) {
            return null;
        }

        return AttendanceResponse.builder()
                .id(attendance.getId())
                .sessionId(attendance.getSession() != null ? attendance.getSession().getId() : null)
                .studentId(attendance.getStudent() != null ? attendance.getStudent().getId() : null)
                .studentName(attendance.getStudent() != null ? attendance.getStudent().getFullName() : null)
                .deviceTime(attendance.getDeviceTime())
                .serverTime(attendance.getServerTime())
                .latitude(attendance.getLatitude())
                .longitude(attendance.getLongitude())
                .withinGeofence(attendance.getWithinGeofence())
                .sensorStatus(attendance.getSensorStatus())
                .isSynced(attendance.getIsSynced())
                .build();
    }
}
