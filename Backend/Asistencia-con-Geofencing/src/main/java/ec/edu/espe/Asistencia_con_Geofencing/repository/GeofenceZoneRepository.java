package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.GeofenceZone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface GeofenceZoneRepository extends JpaRepository<GeofenceZone, UUID> {

    Optional<GeofenceZone> findByName(String name);

    boolean existsByName(String name);
}
