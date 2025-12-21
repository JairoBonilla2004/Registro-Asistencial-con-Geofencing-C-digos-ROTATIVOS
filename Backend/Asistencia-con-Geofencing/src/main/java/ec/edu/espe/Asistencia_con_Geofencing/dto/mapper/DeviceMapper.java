package ec.edu.espe.Asistencia_con_Geofencing.dto.mapper;

import ec.edu.espe.Asistencia_con_Geofencing.dto.response.DeviceResponse;
import ec.edu.espe.Asistencia_con_Geofencing.model.Device;
import org.springframework.stereotype.Component;

@Component
public class DeviceMapper {

    public DeviceResponse toResponse(Device device) {
        if (device == null) {
            return null;
        }

        return DeviceResponse.builder()
                .id(device.getId())
                .deviceIdentifier(device.getDeviceIdentifier())
                .platform(device.getPlatform())
                .fcmToken(device.getFcmToken())
                .lastSeen(device.getLastSeen())
                .build();
    }
}
