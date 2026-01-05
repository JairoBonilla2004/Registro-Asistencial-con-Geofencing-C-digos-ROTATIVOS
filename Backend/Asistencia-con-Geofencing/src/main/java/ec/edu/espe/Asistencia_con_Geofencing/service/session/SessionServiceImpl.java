package ec.edu.espe.Asistencia_con_Geofencing.service.session;


import ec.edu.espe.Asistencia_con_Geofencing.dto.mapper.SessionMapper;
import ec.edu.espe.Asistencia_con_Geofencing.dto.request.CreateSessionRequest;
import ec.edu.espe.Asistencia_con_Geofencing.dto.response.SessionResponse;
import ec.edu.espe.Asistencia_con_Geofencing.exception.ResourceNotFoundException;
import ec.edu.espe.Asistencia_con_Geofencing.exception.UnauthorizedException;
import ec.edu.espe.Asistencia_con_Geofencing.model.AttendanceSession;
import ec.edu.espe.Asistencia_con_Geofencing.model.GeofenceZone;
import ec.edu.espe.Asistencia_con_Geofencing.model.Notification;
import ec.edu.espe.Asistencia_con_Geofencing.model.User;
import ec.edu.espe.Asistencia_con_Geofencing.repository.AttendanceSessionRepository;
import ec.edu.espe.Asistencia_con_Geofencing.repository.GeofenceZoneRepository;
import ec.edu.espe.Asistencia_con_Geofencing.repository.UserRepository;
import ec.edu.espe.Asistencia_con_Geofencing.service.notification.NotificationService;
import ec.edu.espe.Asistencia_con_Geofencing.service.notification.push.PushNotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SessionServiceImpl implements SessionService {

    private final AttendanceSessionRepository sessionRepository;
    private final GeofenceZoneRepository geofenceZoneRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final PushNotificationService pushNotificationService;

    @Override
    @Transactional
    public SessionResponse createSession(CreateSessionRequest request, UUID teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new ResourceNotFoundException("Docente no encontrado"));

        GeofenceZone geofence = geofenceZoneRepository.findById(request.getGeofenceId())
                .orElseThrow(() -> new ResourceNotFoundException("Zona de geofencing no encontrada"));

        AttendanceSession session = new AttendanceSession();
        session.setName(request.getName());
        session.setTeacher(teacher);
        session.setGeofence(geofence);
        session.setStartTime(request.getStartTime());
        session.setActive(true);
        session = sessionRepository.save(session);
        return SessionMapper.mapToResponse(session);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SessionResponse> getActiveSessions() {
        return sessionRepository.findByActiveTrue().stream()
                .map(SessionMapper::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponse> getMySessionsAsTeacher(UUID teacherId, Pageable pageable) {
        return sessionRepository.findByTeacherId(teacherId, pageable)
                .map(SessionMapper::mapToResponse);
    }

    @Override
    @Transactional
    public SessionResponse endSession(UUID sessionId, UUID teacherId) {

        AttendanceSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Sesión no encontrada"));

        if (!session.getTeacher().getId().equals(teacherId)) {
            throw new UnauthorizedException("No tienes permiso para finalizar esta sesión");
        }

        session.setActive(false);
        session.setEndTime(LocalDateTime.now());
        sessionRepository.save(session);
        
        List<Notification> notifications = notificationService.createAbsenceNotifications(session);
        
        // Enviar pushes deduplicando por token FCM para evitar duplicados en el mismo dispositivo
        notifications.stream()
                .collect(java.util.stream.Collectors.groupingBy(
                        n -> n.getUser().getId(),
                        java.util.stream.Collectors.toList()
                ))
                .values()
                .forEach(userNotifications -> {
                    // Solo enviar la primera notificación de cada usuario
                    // (en caso de múltiples notificaciones del mismo user)
                    if (!userNotifications.isEmpty()) {
                        pushNotificationService.sendAbsencePush(userNotifications.get(0));
                    }
                });
        
        return SessionMapper.mapToResponse(session);
    }


}