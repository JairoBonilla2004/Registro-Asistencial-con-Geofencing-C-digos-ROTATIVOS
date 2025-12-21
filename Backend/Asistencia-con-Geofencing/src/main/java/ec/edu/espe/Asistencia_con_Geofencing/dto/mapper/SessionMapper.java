package ec.edu.espe.Asistencia_con_Geofencing.dto.mapper;

import ec.edu.espe.Asistencia_con_Geofencing.dto.response.SessionResponse;
import ec.edu.espe.Asistencia_con_Geofencing.model.AttendanceSession;
import org.springframework.stereotype.Component;

@Component
public class SessionMapper {

    public SessionResponse toResponse(AttendanceSession session) {
        if (session == null) {
            return null;
        }

        return SessionResponse.builder()
                .id(session.getId())
                .teacherId(session.getTeacher() != null ? session.getTeacher().getId() : null)
                .teacherName(session.getTeacher() != null ? session.getTeacher().getFullName() : null)
                .geofenceId(session.getGeofence() != null ? session.getGeofence().getId() : null)
                .geofenceName(session.getGeofence() != null ? session.getGeofence().getName() : null)
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .active(session.getActive())
                .attendanceCount(session.getAttendances() != null ? session.getAttendances().size() : 0)
                .build();
    }
}
