# Análisis de Arquitectura y Seguridad: Módulo `usuarios`

**Módulos analizados:** `lib/modulos/usuarios/` (`vista_usuarios.dart`, `servicio_usuarios.dart`, `modelos_usuarios.dart`)
**Objetivo del negocio:** Gestión de empleados, roles, permisos y visualización de POS móviles activos ("Sesiones Activas").

---

## 1. El Veredicto de DevSecOps (Cierre de Vulnerabilidad Crítica)
**¡De pie para aplaudir esta decisión!** 
*   **El problema anterior:** Para que un desconocido pudiera "pedir" una cuenta desde el celular, tus reglas de Firebase tenían que decir `allow create: if true;` en la colección `Usuarios`. Esto significaba que un hacker podía inyectar 100,000 usuarios basura en tu base de datos y cobrarte una factura gigante de Firebase, o peor, asignarse a sí mismo el rol de "Admin Master".
*   **El Nuevo Flujo (Solo Admins crean):** Al mover la creación exclusivamente al Web Admin, cerramos la puerta. Ahora las reglas dirán `allow create: if esAdministrador()`. Es un salto de madurez de seguridad absoluto.

## 2. El Veredicto del DBA Firebase (Actualización de Reglas)
*   **Mi error por no intervenir antes.** Con este cambio que ordenas, tengo un trabajo crítico que hacer en el archivo `firestore.rules` que guardamos hace un momento. 
*   Actualmente la colección `Usuarios` tiene `allow create: if true;` y `allow list: if true;`. 
*   **El Cambio:** Bloquearé esto inmediatamente en el nuevo diseño. Solo permitiré la creación y lectura de la lista completa si la función `esAdministrador()` devuelve verdadero. Esto asegura que la base de datos a nivel de servidor rechace cualquier intento de creación que no venga de un Admin validado.

## 3. El Veredicto del Arquitecto (Nuevo Flujo de Creación)
*   Como la creación es exclusiva desde la web, la pestaña de "Solicitudes Pendientes" que tenías en el Web Admin desaparece. 
*   En su lugar, crearemos un formulario robusto ("Nuevo Usuario") que directamente generará el perfil activo con el Rol asignado. 
*   Hemos tomado nota de todos los campos que mandaste en la imagen (`Nombres`, `Apellidos`, `Correo`, `Telefono`, `IdDispositivo`, `FotoUrl`, etc.) para que el modelo de datos sea exactamente el mismo.

## 4. El Veredicto del Frontend Web
*   Diseñaré el nuevo formulario de "Crear Empleado" dentro del Web Admin, manteniendo tu línea gráfica y la paleta de colores. 
*   Agregaremos campos obligatorios como el Teléfono y validaremos el formato del correo.

## 5. El Veredicto del Backend Web
*   El backend ahora será responsable de llamar a Firebase Auth (para crear la credencial) y simultáneamente a Firestore (para guardar el documento del usuario) en una sola transacción cuando el Admin presione "Guardar".

## 6. El Veredicto del Arquitecto (La función "Sesiones Activas")
Noté en tu código (líneas 108 y 151 de la vista) que ya tienes el cuadro "Sesiones Activas" diseñado.
*   **El Reto Técnico:** Saber quién está usando la app móvil "en este preciso momento" es difícil en Firestore porque Firestore no tiene "estado de conexión". Si el celular se apaga de golpe, Firestore nunca se entera.
*   **La Solución Propuesta:** Implementaremos el sistema de **"Presence" (Presencia) de Firebase Realtime Database** exclusivamente para este fin (es gratis y no interfiere con Firestore). El celular escribirá *"Estoy en línea"* al abrir la app, y Firebase detectará automáticamente si el celular pierde el internet o se cierra, actualizando tu cuadro del Web Admin en tiempo real y sin consumir lecturas costosas de Firestore.
