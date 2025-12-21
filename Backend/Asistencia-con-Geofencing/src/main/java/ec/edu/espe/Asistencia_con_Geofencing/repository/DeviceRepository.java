package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.Device;
import ec.edu.espe.Asistencia_con_Geofencing.model.enums.PlatformType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeviceRepository extends JpaRepository<Device, UUID> {

    Optional<Device> findByUserIdAndDeviceIdentifier(UUID userId, String deviceIdentifier);

    List<Device> findByUserId(UUID userId);

    List<Device> findByPlatform(PlatformType platform);

    Optional<Device> findByFcmToken(String fcmToken);

    List<Device> findByUserIdAndFcmTokenIsNotNull(UUID userId);
}
