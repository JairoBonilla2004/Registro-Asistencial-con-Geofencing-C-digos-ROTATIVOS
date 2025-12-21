package ec.edu.espe.Asistencia_con_Geofencing.repository;

import ec.edu.espe.Asistencia_con_Geofencing.model.QrToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface QrTokenRepository extends JpaRepository<QrToken, UUID> {

    @Query("SELECT qt FROM QrToken qt WHERE qt.session.id = :sessionId " +
           "AND qt.expiresAt > :now ORDER BY qt.expiresAt DESC")
    Optional<QrToken> findValidTokenBySessionId(@Param("sessionId") UUID sessionId, 
                                                  @Param("now") LocalDateTime now);

    @Query("SELECT qt FROM QrToken qt WHERE qt.token = :token AND qt.expiresAt > :now")
    Optional<QrToken> findByTokenAndNotExpired(@Param("token") String token, 
                                                 @Param("now") LocalDateTime now);

    List<QrToken> findBySessionId(UUID sessionId);

    @Query("SELECT qt FROM QrToken qt WHERE qt.expiresAt <= :now")
    List<QrToken> findExpiredTokens(@Param("now") LocalDateTime now);

    @Modifying
    @Query("DELETE FROM QrToken qt WHERE qt.session.id = :sessionId AND qt.expiresAt <= :now")
    int deleteExpiredTokensBySessionId(@Param("sessionId") UUID sessionId, 
                                        @Param("now") LocalDateTime now);

    @Query("SELECT COUNT(qt) FROM QrToken qt WHERE qt.session.id = :sessionId AND qt.expiresAt > :now")
    long countValidTokensBySessionId(@Param("sessionId") UUID sessionId, 
                                      @Param("now") LocalDateTime now);
}
