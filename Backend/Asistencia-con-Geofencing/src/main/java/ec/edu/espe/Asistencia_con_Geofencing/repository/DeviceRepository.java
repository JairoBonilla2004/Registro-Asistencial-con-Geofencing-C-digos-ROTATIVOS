package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.Query;

@Repository
public interface DeviceRepository extends JpaRepository<Device, UUID> {
    Optional<Device> findByUserIdAndDeviceIdentifier(UUID userId, String deviceIdentifier);
    
    @Query("SELECT d.fcmToken FROM Device d WHERE d.user.id = :userId AND d.fcmToken IS NOT NULL AND d.isActive = true ORDER BY d.lastSeen DESC")
    Optional<String> findActiveFcmTokenByUserId(UUID userId);
    List<Device> findByDeviceIdentifierAndUserIdNot(String deviceIdentifier, UUID userId);
}