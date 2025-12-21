package ec.edu.espe.Asistencia_con_Geofencing.dto.mapper;

import ec.edu.espe.Asistencia_con_Geofencing.dto.request.CreateGeofenceZoneRequest;
import ec.edu.espe.Asistencia_con_Geofencing.dto.response.GeofenceZoneResponse;
import ec.edu.espe.Asistencia_con_Geofencing.model.GeofenceZone;
import org.springframework.stereotype.Component;

@Component
public class GeofenceMapper {

    public GeofenceZoneResponse toResponse(GeofenceZone geofence) {
        if (geofence == null) {
            return null;
        }

        return GeofenceZoneResponse.builder()
                .id(geofence.getId())
                .name(geofence.getName())
                .latitude(geofence.getLatitude())
                .longitude(geofence.getLongitude())
                .radiusMeters(geofence.getRadiusMeters())
                .build();
    }

    public GeofenceZone toEntity(CreateGeofenceZoneRequest request) {
        if (request == null) {
            return null;
        }

        GeofenceZone geofence = new GeofenceZone();
        geofence.setName(request.getName());
        geofence.setLatitude(request.getLatitude());
        geofence.setLongitude(request.getLongitude());
        geofence.setRadiusMeters(request.getRadiusMeters());

        return geofence;
    }
}
