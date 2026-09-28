# Plan Maestro de Refactorización (Fase 2)
**Proyecto:** Confianza Web Admin
**Fecha de elaboración:** 27 de Septiembre de 2026
**Autor:** Arquitecto de Software

---

## 🏛️ 1. Reglas de Oro (Inquebrantables)
Antes de tocar una sola línea de código, el equipo se rige bajo los siguientes mandamientos:
1. **Validación primero:** "Ante la duda, se pausa y se pregunta". Ningún módulo avanza sin el visto bueno del líder.
2. **Fidelidad Visual:** El Frontend tiene prohibido alterar el diseño final. Todo debe verse y sentirse exactamente igual a producción (colores, sombras, modales).
3. **Retrocompatibilidad (Escudo POS):** La base de datos es sagrada. No se cambiarán nombres de campos a `camelCase` ni se alterarán los tipos de datos actuales. Todo se diseñará para que el POS móvil siga funcionando sin inmutarse.
4. **Manejo de Fechas:** Se respeta la directriz de guardar fechas como Texto (`String`) y no como `Timestamp` nativo de Firebase, protegiendo al equipo móvil.
5. **Diseño Responsivo Total:** Se mantendrá fiel el diseño gráfico original, pero todos los componentes (tablas, tarjetas, menús) deben ser dinámicos. Los datos deben acomodarse a monitores ultra-wide de 34" y a pantallas pequeñas/laptops sin superponerse ni cortarse.

---

## 🛠️ 2. Plan de Acción por Módulo (Ejecución Secuencial)

### Módulo 0: El Núcleo (`main.dart`)
*   **Problema Actual:** Presencia de `StreamBuilder` en la raíz (causante de recargas masivas) y navegación antigua.
*   **Plan de Acción:**
    *   Instalar e inicializar **Riverpod** (Gestor de estado) para garantizar una memoria eficiente y "0 loadings".
    *   Instalar **GoRouter** para manejar las URLs del sitio web como un administrador profesional.
    *   Limpiar el `main.dart` para que sea solo el lanzador de la app.

### Módulo 1: Sesión (Login)
*   **Problema Actual:** Lógica acoplada.
*   **Plan de Acción:**
    *   Adaptar el backend para un **Login Manual Estricto** usando los 3 campos acordados: `Nombre`, `Apellido` y `Contraseña`.
    *   Conectar el formulario existente de la UI con el nuevo método del servicio.

### Módulo 2: Usuarios (Web Admin exclusivo)
*   **Problema Actual:** Creación de usuarios vulnerable desde cualquier dispositivo móvil.
*   **Plan de Acción:**
    *   **Restricción de Creación:** Centralizar la creación de cajeros y administradores única y exclusivamente en esta página web, sellado con `firestore.rules`.
    *   **Monitor de Presencia:** Implementar la lectura de dispositivos móviles activos ("quién está usando la app POS en este momento").

### Módulo 3: Catálogos
*   **Problema Actual:** Código de interfaz de 30KB y fallo de sincronización NoSQL al renombrar.
*   **Plan de Acción:**
    *   **Diseño:** Dividir el archivo visual en pequeños componentes sin alterar cómo se ve.
    *   **Lógica (Batch Update):** Programar un mecanismo que, cuando se renombra una "Categoría" o "Proveedor", recorra la base de datos para actualizar el texto en todos los artículos de Inventario que dependían de ella, evitando que queden huérfanos.

### Módulo 4: Inventario (Operación Rescate)
*   **Problema Actual:** Un archivo monolítico de 3,000 líneas desconectado de la base de datos tras la pérdida del código.
*   **Plan de Acción:**
    *   **Cirugía Visual:** Descuartizar los modales, tablas y filtros en al menos 5 archivos separados y ordenados en la carpeta `lib/modulos/inventario/widgets/`.
    *   **Conexión Paginada:** Reconstruir los "cables" para descargar los productos de 50 en 50, usando el modelo de datos auditado (respetando los `String` y `Double` exactos de producción).
    *   **Desnormalización:** Asegurar que los cálculos matemáticos pesados de los Lotes (Stock total, Precio primario) se guarden en el documento padre para lecturas instantáneas.

### Módulo 5: Generador de Códigos
*   **Problema Actual:** Código revuelto entre generador PDF, UI y fechas.
*   **Plan de Acción:**
    *   Aislar la generación de Canvas/PDF en un servicio dedicado (`servicio_pdf.dart`).
    *   Aplicar el `DateHelper` (que ya fue programado) para la manipulación limpia de strings.

---

## 🔒 3. Despliegue Final (DevSecOps)
Una vez que todos los módulos estén refactorizados y aprobados por el líder, el paso final será la implementación de las reglas de seguridad en Firestore:
*   Subir el archivo `firestore.rules` al servidor.
*   Bloquear todas las colecciones para que solo el rol `esAdministrador()` pueda borrar, editar o crear.

---
*Este documento actuará como nuestra biblia durante las próximas sesiones. Nada se agrega o se modifica sin revisión previa.*
