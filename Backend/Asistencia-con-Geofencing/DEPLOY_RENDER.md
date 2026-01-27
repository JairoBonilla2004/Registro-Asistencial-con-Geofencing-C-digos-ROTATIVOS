# 🚀 Guía de Deploy en Render

## 📋 Prerequisitos

1. Cuenta en [Render](https://render.com)
2. Repositorio Git con el proyecto
3. Cuenta en [Neon](https://neon.tech) con:
   - Base de datos PostgreSQL configurada
   - Credenciales de conexión (se obtienen automáticamente)
4. Cuenta Supabase (opcional, solo para almacenamiento de reportes):
   - Bucket `reports` creado en Storage
   - API Keys generadas (service_role key)

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

#### Base de Datos (Neon)
```
DATABASE_URL=jdbc:postgresql://[HOST]/[DATABASE]?sslmode=require
DATABASE_USERNAME=neondb_owner
DATABASE_PASSWORD=npg_xxxxxxxxxxxxx
```
**Ejemplo:**
```
DATABASE_URL=TUS_CREDENCIALES
DATABASE_USERNAME=TUS_CREDENCIALES
DATABASE_PASSWORD=TUS_CREDENCIALES
```

> 📝 **Cómo obtener credenciales de Neon:**
> 1. Ve a tu proyecto en [Neon Console](https://console.neon.tech)
> 2. En la sección "Connection Details", copia la cadena de conexión
> 3. Convierte el formato PostgreSQL a JDBC:
>    - De: `postgresql://user:pass@host/db?sslmode=require`
>    - A: `jdbc:postgresql://host/db?sslmode=require`

#### Supabase Storage (Opcional - Solo para reportes)
```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
> ⚠️ Si prefieres almacenamiento local, omite estas variables y configura `REPORTS_PATH`

#### JWT Configuration
```
JWT_SECRET=tu_clave_secreta_super_segura_minimo_256_bits
JWT_EXPIRATION=86400000
```

#### Storage Configuration
Para Supabase Storage:
```
REPORTS_STORAGE_TYPE=supabase
REPORTS_STORAGE_BUCKET_NAME=reports
```

Para almacenamiento local:
```
REPORTS_PATH=/app/reports
```

#### Database Pool (Para Neon)
```
DB_POOL_SIZE=10
```
> ✅ **Neon Free** permite más conexiones concurrentes que Supabase. Pool de 10 es seguro.

#### OAuth (Opcional)
```
GOOGLE_CLIENT_ID=tu-google-client-id.apps.googleusercontent.com
FACEBOOK_APP_ID=tu-facebook-app-id
FACEBOOK_APP_SECRET=tu-facebook-app-secret
```

#### Firebase Cloud Messaging (Opcional)
```
FCM_SERVICE_ACCOUNT=geofencing-firebase-adminsdk.json
```

#### Spring Boot
```
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
CORS_ALLOWED_ORIGINS=https://tu-frontend.com,https://www.tu-frontend.com
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
