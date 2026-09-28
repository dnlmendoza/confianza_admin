# Master Plan y Deuda Técnica (La Confianza)

## Estado Actual (Análisis Preliminar)
- **Proyectos:** `confianza_admin` (Web Admin) y `confianza_pos` (Móvil - Pendiente).
- **Stack:** Flutter/Dart, Firebase (Auth, Firestore, Storage, Hosting).

---

## Roadmap Oficial (Web Admin)

### ✅ Fase 1: Análisis Arquitectónico y Auditoría (COMPLETADA)
Se evaluó el estado actual del código, detectando riesgos de seguridad, problemas de rendimiento (StreamBuilders en la raíz) y deuda técnica (archivos monolíticos de hasta 3,000 líneas). 
Módulos auditados y con dictamen cerrado:
- `main` y `firebase_options` (Migración a go_router y App Check).
- `sesion` (Login manual seguro manteniendo el diseño).
- `usuarios` (Creación centralizada en Web Admin, Presencia de Sesiones Activas).
- `generador` (Desacoplamiento visual y DateHelper).
- `inventario` (Operación Rescate: Reconstrucción de la conexión a Firebase).
- `catalogos` (Resolución de desincronización NoSQL al renombrar).

### 🚧 Fase 2: Ejecución y Refactorización Web Admin (PRÓXIMO PASO)
Convertir los análisis de la Fase 1 en código real.
- **Frontend:** Dividir los archivos monolíticos en componentes pequeños respetando **exactamente el diseño visual de producción**.
- **Backend/DBA:** Implementar las consultas rápidas y seguras (Riverpod / Paginación / Reglas).
- **DevSecOps:** Desplegar el nuevo archivo `firestore.rules` definitivo.

### ⏳ Fase 3: Construcción de Módulos Inéditos Web Admin (PAUSADA)
*(A petición del líder, estos módulos se abordarán solo cuando la Fase 2 esté 100% estable)*
- Módulo `inicio` (Dashboard estadístico).
- Módulo `cierre` (Arqueo y finanzas).
- Módulo `pos` (Punto de venta web, si aplica).

### ⏳ Fase 4: Equipo POS Móvil (EN ESPERA)
- Involucrar al equipo móvil para replicar y asegurar la aplicación de cajeros.
