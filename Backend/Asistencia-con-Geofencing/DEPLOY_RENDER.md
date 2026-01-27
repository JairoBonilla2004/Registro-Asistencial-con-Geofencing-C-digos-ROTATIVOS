# 🚀 Guía de Deploy en Render

## 📋 Prerequisitos

1. Cuenta en [Render](https://render.com)
2. Repositorio Git con el proyecto
3. Cuenta Supabase con:
   - Base de datos PostgreSQL configurada
   - Bucket `reports` creado en Storage
   - API Keys generadas

## 🔧 Configuración en Render

### Paso 1: Crear Web Service

1. Ve a [Dashboard de Render](https://dashboard.render.com)
2. Click en **"New +"** → **"Web Service"**
3. Conecta tu repositorio Git
4. Selecciona el repositorio del proyecto

### Paso 2: Configuración del Servicio

**Build & Deploy:**
- **Name**: `asistencia-geofencing-api` (o el nombre que prefieras)
- **Region**: Oregon (u otra región cercana)
- **Branch**: `main`
- **Root Directory**: `Backend/Asistencia-con-Geofencing`
- **Runtime**: Docker
- **Dockerfile Path**: `./Dockerfile`
- **Docker Context**: `.`

**Instance:**
- **Plan**: Free (o el plan que necesites)

### Paso 3: Variables de Entorno

Configura las siguientes variables en **Environment** → **Environment Variables**:

#### Base de Datos (Supabase)
```
DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres
```
**Ejemplo:**
```
postgresql://postgres.xxxxxxxx:mypassword@aws-0-us-west-2.pooler.supabase.com:5432/postgres
```

#### Supabase Storage
```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### JWT Configuration
```
JWT_SECRET=tu_clave_secreta_super_segura_minimo_256_bits
JWT_EXPIRATION=86400000
```

#### Storage Configuration
```
REPORTS_STORAGE_TYPE=supabase
REPORTS_STORAGE_BUCKET_NAME=reports
```

#### Spring Boot
```
SPRING_PROFILES_ACTIVE=production
SERVER_PORT=8080
```

### Paso 4: Health Check

- **Health Check Path**: `/actuator/health`

Asegúrate de tener Spring Boot Actuator en tu `pom.xml`:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

## 🔍 Verificación

### 1. Logs de Build
Revisa los logs en tiempo real durante el despliegue:
- Maven descarga dependencias
- Compilación exitosa
- Imagen Docker construida

### 2. Logs de Runtime
Una vez desplegado, verifica:
```
Started AsistenciaConGeofencingApplication in X.XXX seconds
```

### 3. Health Check
Accede a:
```
https://tu-servicio.onrender.com/actuator/health
```

Deberías ver:
```json
{
  "status": "UP"
}
```
