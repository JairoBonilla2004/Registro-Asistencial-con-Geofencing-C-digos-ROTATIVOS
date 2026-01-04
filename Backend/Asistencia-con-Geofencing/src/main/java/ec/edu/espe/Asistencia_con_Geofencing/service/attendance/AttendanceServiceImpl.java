package ec.edu.espe.Asistencia_con_Geofencing.service.attendance;


import ec.edu.espe.Asistencia_con_Geofencing.dto.mapper.AttendanceMapper;
import ec.edu.espe.Asistencia_con_Geofencing.dto.request.SyncAttendancesRequest;
import ec.edu.espe.Asistencia_con_Geofencing.dto.request.ValidateQrRequest;
import ec.edu.espe.Asistencia_con_Geofencing.dto.response.AttendanceHistoryResponse;
import ec.edu.espe.Asistencia_con_Geofencing.dto.response.AttendanceResponse;
import ec.edu.espe.Asistencia_con_Geofencing.dto.response.SyncResultResponse;
import ec.edu.espe.Asistencia_con_Geofencing.exception.*;
import ec.edu.espe.Asistencia_con_Geofencing.model.*;
import ec.edu.espe.Asistencia_con_Geofencing.model.enums.SensorType;
import ec.edu.espe.Asistencia_con_Geofencing.repository.*;
import ec.edu.espe.Asistencia_con_Geofencing.service.geofence.GeofenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceServiceImpl implements AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final QrTokenRepository qrTokenRepository;
    private final UserRepository userRepository;
    private final DeviceRepository deviceRepository;
    private final SyncBatchRepository syncBatchRepository;
    private final SensorEventRepository sensorEventRepository;
    private final AttendanceSessionRepository sessionRepository;
    private final GeofenceService geofenceService;

    @Override
    @Transactional
    public AttendanceResponse validateQrAndRegisterAttendance(ValidateQrRequest request, UUID studentId) {
        QrToken qrToken = qrTokenRepository.findValidToken(request.getToken(), LocalDateTime.now())
                .orElseThrow(() -> new TokenExpiredException("El código QR ha expirado"));

        AttendanceSession session = qrToken.getSession();

        if (!session.getActive()) {
            throw new SessionInactiveException("La sesión ha finalizado", session.getEndTime());
        }

        attendanceRepository.findBySessionIdAndStudentId(session.getId(), studentId)
                .ifPresent(existing -> {
                    throw new AlreadyRegisteredException(
                            "Ya has registrado tu asistencia en esta sesión",
                            existing.getId(),
                            existing.getServerTime()
                    );
                });

        GeofenceZone geofence = session.getGeofence();
        double distance = geofenceService.calculateDistance(
                request.getLatitude(),
                request.getLongitude(),
                geofence.getLatitude(),
                geofence.getLongitude()
        );

        boolean withinGeofence = distance <= geofence.getRadiusMeters();

        if (!withinGeofence) {
            throw new OutsideGeofenceException(
                    "Debes estar dentro de " + geofence.getName() + " para registrar asistencia",
                    geofence.getName(),
                    distance,
                    geofence.getRadiusMeters()
            );
        }

        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Estudiante no encontrado"));

        Attendance attendance = new Attendance();
        attendance.setSession(session);
        attendance.setStudent(student);
        attendance.setDeviceTime(request.getDeviceTime());
        attendance.setLatitude(request.getLatitude());
        attendance.setLongitude(request.getLongitude());
        attendance.setWithinGeofence(withinGeofence);
        attendance.setIsSynced(true);

        // Registrar el dispositivo de origen si se proporciona
        if (request.getDeviceId() != null) {
            Device sourceDevice = deviceRepository.findById(request.getDeviceId())
                    .orElse(null);
            if (sourceDevice != null && sourceDevice.getUser().getId().equals(studentId)) {
                attendance.setSourceDevice(sourceDevice);
                log.debug("Dispositivo de origen registrado: {}", request.getDeviceId());
            }
        }

        if (request.getSensorData() != null) {
            String sensorStatus = String.format("compass:%s,proximity:%s",
                    request.getSensorData().getOrDefault("compass", "N/A"),
                    request.getSensorData().getOrDefault("proximity", "N/A")
            );
            attendance.setSensorStatus(sensorStatus);
        }

        attendance = attendanceRepository.save(attendance);

        if (request.getSensorData() != null) {
            saveSensorEvents(student, session, attendance, request.getSensorData(), request.getDeviceTime());
        }

        return AttendanceMapper.mapToResponse(attendance);
    }

    @Override
    @Transactional
    public SyncResultResponse syncOfflineAttendances(SyncAttendancesRequest request, UUID userId) {
        Device device = deviceRepository.findById(request.getDeviceId())
                .orElseThrow(() -> new ResourceNotFoundException("Dispositivo no encontrado"));

        if (!device.getUser().getId().equals(userId)) {
            throw new RuntimeException("El dispositivo no pertenece al usuario");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        SyncBatch syncBatch = new SyncBatch();
        syncBatch.setUser(user);
        syncBatch.setDevice(device);
        syncBatch.setItemCount(request.getAttendances().size());
        syncBatch = syncBatchRepository.save(syncBatch);

        List<SyncResultResponse.SyncItemResult> results = new ArrayList<>();
        int syncedCount = 0;
        int failedCount = 0;

        for (SyncAttendancesRequest.OfflineAttendanceData data : request.getAttendances()) {
            try {
                ValidateQrRequest validateRequest = new ValidateQrRequest();
                validateRequest.setToken(data.getToken());
                validateRequest.setLatitude(data.getLatitude());
                validateRequest.setLongitude(data.getLongitude());
                validateRequest.setDeviceTime(data.getDeviceTime());
                validateRequest.setSensorData(data.getSensorData());

                AttendanceResponse response = validateQrAndRegisterAttendance(validateRequest, userId);

                results.add(SyncResultResponse.SyncItemResult.builder()
                        .tempId(data.getTempId())
                        .serverId(response.getAttendanceId())
                        .status("SYNCED")
                        .message("Asistencia registrada correctamente")
                        .build());

                syncedCount++;
            } catch (TokenExpiredException e) {
                results.add(SyncResultResponse.SyncItemResult.builder()
                        .tempId(data.getTempId())
                        .status("FAILED")
                        .errorCode("TOKEN_EXPIRED")
                        .message(e.getMessage())
                        .build());
                failedCount++;
            } catch (OutsideGeofenceException e) {
                results.add(SyncResultResponse.SyncItemResult.builder()
                        .tempId(data.getTempId())
                        .status("FAILED")
                        .errorCode("OUTSIDE_GEOFENCE")
                        .message(e.getMessage())
                        .build());
                failedCount++;
            } catch (AlreadyRegisteredException e) {
                results.add(SyncResultResponse.SyncItemResult.builder()
                        .tempId(data.getTempId())
                        .serverId(e.getAttendanceId())
                        .status("FAILED")
                        .errorCode("ALREADY_REGISTERED")
                        .message(e.getMessage())
                        .build());
                failedCount++;
            } catch (Exception e) {
                log.error("Error sincronizando asistencia: {}", e.getMessage());
                results.add(SyncResultResponse.SyncItemResult.builder()
                        .tempId(data.getTempId())
                        .status("FAILED")
                        .errorCode("SYNC_ERROR")
                        .message("Error al sincronizar")
                        .build());
                failedCount++;
            }
        }

        return SyncResultResponse.builder()
                .batchId(syncBatch.getId())
                .syncedCount(syncedCount)
                .failedCount(failedCount)
                .results(results)
                .build();
    }

    @Override
    public AttendanceHistoryResponse getMyHistory(UUID studentId, LocalDate startDate, LocalDate endDate, Pageable pageable) {
        LocalDateTime start = startDate != null ? startDate.atStartOfDay() : LocalDateTime.now().minusYears(1);
        LocalDateTime end = endDate != null ? endDate.atTime(23, 59, 59) : LocalDateTime.now();

        Page<Attendance> attendancesPage = attendanceRepository.findByStudentIdAndDateRange(studentId, start, end, pageable);

        List<AttendanceResponse> attendances = attendancesPage.getContent().stream()
                .map(AttendanceMapper::mapToResponse)
                .collect(Collectors.toList());

        Long totalAttended = attendanceRepository.countAttendedSessionsByStudentId(studentId);
        Long totalSessions = sessionRepository.count();
        Double attendanceRate = totalSessions > 0 ? (totalAttended.doubleValue() / totalSessions) * 100 : 0.0;
        AttendanceHistoryResponse.AttendanceSummary summary = AttendanceHistoryResponse.AttendanceSummary.builder()
                .totalSessions(totalSessions)
                .attendedSessions(totalAttended)
                .attendanceRate(Math.round(attendanceRate * 100.0) / 100.0)
                .build();

        return AttendanceHistoryResponse.builder()
                .summary(summary)
                .attendances(attendances)
                .totalPages(attendancesPage.getTotalPages())
                .currentPage(attendancesPage.getNumber())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceResponse> getSessionAttendances(UUID sessionId) {
        return attendanceRepository.findBySessionId(sessionId).stream()
                .map(AttendanceMapper::mapToResponse)
                .collect(Collectors.toList());
    }

    private void saveSensorEvents(User user, AttendanceSession session, Attendance attendance,
                                  java.util.Map<String, String> sensorData, LocalDateTime deviceTime) {
        if (sensorData.containsKey("compass")) {
            SensorEvent compassEvent = new SensorEvent();
            compassEvent.setUser(user);
            compassEvent.setSession(session);
            compassEvent.setAttendance(attendance);
            compassEvent.setType(SensorType.COMPASS);
            compassEvent.setValue(sensorData.get("compass"));
            compassEvent.setDeviceTime(deviceTime);
            sensorEventRepository.save(compassEvent);
        }

        if (sensorData.containsKey("proximity")) {
            SensorEvent proximityEvent = new SensorEvent();
            proximityEvent.setUser(user);
            proximityEvent.setSession(session);
            proximityEvent.setAttendance(attendance);
            proximityEvent.setType(SensorType.PROXIMITY);
            proximityEvent.setValue(sensorData.get("proximity"));
            proximityEvent.setDeviceTime(deviceTime);
            sensorEventRepository.save(proximityEvent);
        }
    }


}