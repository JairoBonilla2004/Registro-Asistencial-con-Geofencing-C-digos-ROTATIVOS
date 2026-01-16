package ec.edu.espe.Asistencia_con_Geofencing.utils.pdf;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;


@Component
@Slf4j
public class PdfFileManager {
    
    @Value("${reports.storage.path}")
    private String storageBasePath;
    
    private static final DateTimeFormatter TIMESTAMP_FORMATTER = 
            DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss");
    

    public void ensureReportDirectoryExists() throws IOException {
        Path reportsDir = Paths.get(storageBasePath);
        if (!Files.exists(reportsDir)) {
            Files.createDirectories(reportsDir);
            log.info("Directorio de reportes creado: {}", reportsDir);
        }
    }
    

    public String generateFileName(String prefix, String identifier) {
        String timestamp = LocalDateTime.now().format(TIMESTAMP_FORMATTER);
        return String.format("%s_%s_%s.pdf", prefix, identifier, timestamp);
    }
    

    public String getFullPath(String fileName) {
        return Paths.get(storageBasePath, fileName).toString();
    }
    public boolean fileExists(String filePath) {
        return Files.exists(Paths.get(filePath));
    }
    public void deleteFile(String filePath) throws IOException {
        Files.deleteIfExists(Paths.get(filePath));
        log.info("Archivo eliminado: {}", filePath);
    }
}
