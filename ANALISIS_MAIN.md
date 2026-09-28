# Análisis de Arquitectura y Seguridad: `main.dart` y `firebase_options.dart`

**Módulos analizados:** Configuración base de la aplicación.
**Equipo involucrado:** Arquitecto, DevSecOps, Frontend Web.

---

## 1. El Veredicto del Arquitecto (Estructura y Rendimiento)

El archivo `main.dart` es la puerta de entrada a tu aplicación. Aquí encontramos un problema de rendimiento fundamental:

*   **El problema del `StreamBuilder` en la raíz:** Tienes un `StreamBuilder` escuchando el estado de autenticación envolviendo a todo el widget `MaterialApp`.
    *   *Por qué es malo:* Cada vez que el token de Firebase se refresca (lo cual ocurre por debajo cada cierto tiempo) o el estado cambia, **toda la aplicación se reconstruye desde cero**, redibujando rutas y reseteando estados visuales que no deberían tocarse.
    *   *La Solución:* Moveremos el `MaterialApp` fuera del `StreamBuilder`. La lógica de autenticación se manejará mediante un sistema de enrutamiento moderno (como `go_router` o `auto_route`) usando *Redirects*. Esto es el estándar en web para evitar recargas completas.

## 2. El Veredicto del Frontend Web (UX y Navegación)

*   **Ruteo Básico:** Usar el mapa `routes: {}` nativo de Flutter está bien para apps pequeñas, pero para un sistema web profesional, el estándar es usar `go_router`. Este paquete nos permitirá manejar URLs limpias (`laconfianza.hn/inventario`), proteger rutas privadas (si no estás logueado, la URL te redirige al login sin parpadear) y evitar el problema del `StreamBuilder`.
*   **Tema (ThemeData):** Tienes el color semilla estático en `main.dart`. Lo moveremos a un archivo `core/theme/app_theme.dart` para mantener el `main` lo más limpio y legible posible.

## 3. El Veredicto de DevSecOps (Seguridad)

### A. Lo Excelente: El Auto-Logout por inactividad
Primero, **aplausos**. El widget `InactivitySignOutListener` que creaste para cerrar sesión tras 10 minutos de inactividad interceptando el teclado y el ratón es una **excelente práctica de seguridad de grado bancario/empresarial**. Está muy bien programado (el *throttle* de 2 segundos evita saturar la memoria). Mantendremos esto intacto.

### B. El Riesgo: `firebase_options.dart` y la API Key expuesta
*   **El problema:** Tu archivo expone el `apiKey` y el `projectId` en texto plano.
*   **La realidad en Web:** En aplicaciones Flutter Web, las llaves de Firebase *siempre* viajan al navegador del cliente, por lo que cualquiera que inspeccione el código puede verlas.
*   **La Solución de Seguridad:** Como no podemos ocultar la llave, tenemos que blindarla. Anotamos en nuestro Roadmap implementar **Firebase App Check (con reCAPTCHA v3/Enterprise)**. Esto garantiza que aunque un hacker copie tu API Key, Firebase rechazará cualquier consulta que no provenga del dominio oficial (`tu-dominio.com`).

---

## 🛠️ Plan de Refactorización para `main.dart` (Cuando tú des la orden):
1. Instalar `go_router` y migrar el ruteo.
2. Quitar el `StreamBuilder` del `MaterialApp`.
3. Limpiar el archivo moviendo la lógica visual a la carpeta `core`.
