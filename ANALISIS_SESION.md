# Análisis de Arquitectura y Seguridad: Módulo `sesion`

**Módulos analizados:** `vista_sesion.dart` y `viewmodel_sesion.dart`
**Objetivo del negocio:** Preservar la estética visual original (incluyendo la vista del QR) y asegurar el Login Manual clásico mediante Nombre, Apellido y Contraseña.

---

## 1. El Veredicto del Frontend Web (Fidelidad Visual Absoluta)
*   **Regla de Oro:** "No tocar un solo pixel". La interfaz gráfica actual se mantiene idéntica, ni más ni menos.
*   **Implementación:** Esto significa que el panel que muestra el Código QR, la animación de "ESPERANDO ESCANEO..." y el botón de alternar vista seguirán presentes visualmente para mantener la estética y experiencia de usuario deseada, aunque bajo el capó el inicio de sesión se procese exclusivamente por la vía manual. 
*   **Refactorización Interna:** Se reemplazará el `ChangeNotifier` por Riverpod y se limpiará el código interno, pero el resultado visual renderizado será indistinguible de la versión original.

## 2. El Veredicto del Backend Web (Lógica y Seguridad de Datos)
*   **Acuerdo de Login Manual (Trato Hecho):** Se acepta utilizar la combinación de "Nombre", "Apellido" y "Contraseña" para el inicio de sesión. El código interno generará el identificador en Firebase (`nombreapellido@laconfianza.hn`).
*   **Condición Obligatoria:** Para evitar que el sistema colapse por colisiones (Ej. dos personas llamadas "Juan Pérez"), el módulo de creación de usuarios (que desarrollaremos más adelante) tendrá una regla estricta que impedirá guardar un usuario nuevo si la combinación exacta de Nombre y Apellido ya existe en la base de datos.
*   **Separación de Lógica:** Se implementará un `AuthRepository` para aislar el SDK de Firebase de la vista.

## 3. El Veredicto de DevSecOps (Seguridad)
*   Se ajustarán los mensajes de error del login manual ("Usuario deshabilitado", "Contraseña incorrecta", etc.) por un mensaje unificado y seguro: *"Credenciales inválidas"*, protegiendo al sistema de posibles ataques de enumeración de usuarios.

## 4. El Veredicto de Catálogo & Usuarios
*   Monitoreando de cerca el acuerdo del Backend. Cuando toque crear el CRUD de Usuarios, seré el responsable de aplicar la validación masiva para garantizar la unicidad de Nombres+Apellidos.

## 5. El Veredicto del Arquitecto 
*   Arquitectura simplificada y económica. Descartamos el uso de Firebase Cloud Functions y nos apegamos al flujo de Firebase Auth nativo. Sistema limpio, sin costos adicionales y visualmente fiel.

## 6. El Veredicto de QA Web
*   **Checklist de Pruebas a programar:** 
    1. Validar que la UI mantenga el diseño del QR (Mock visual).
    2. Validar que el botón de alternar a "Ingreso Manual" funcione fluidamente.
    3. Validar el inicio de sesión exitoso con Nombre, Apellido y Contraseña.
    4. Validar el rechazo seguro ante intentos fallidos.
