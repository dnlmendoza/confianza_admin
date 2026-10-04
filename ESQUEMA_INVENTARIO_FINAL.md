# 📊 Análisis Exhaustivo de Arquitectura en Firebase
**Proyecto:** "La Confianza"
**Rol:** DBA Master (Database Administrator)
**Fecha de Inspección Visual:** Octubre 2026
**Fuentes Analizadas:** Consola web en vivo de Firebase (Screenshots proporcionados).

> **Aviso Crítico:** Este documento reemplaza cualquier esquema anterior inferido desde el código fuente antiguo. El código actual en Flutter (Admin Web) está **desactualizado** y debe ser refactorizado para conectar con esta nueva estructura de producción.

---

## 🏗️ 1. Colección Raíz: `Inventario`
*(Estructura validada y estabilizada)*
- **Document ID (Raíz):** Código de Barras (Ej: `742111`).
- **Campos:** `nombre`, `descripcion`, `proveedor`, `categoria`, `estado`, `imagen`, `cantidad_minima`, `pesado` (bool), `menor_mayor` (bool), `fecha`.
- **Subcolección `lote/{id_lote}`:** `cantidad`, `costo_unitario`, `precio_venta`, `unidades`, `cantidad_mayor`, `costo_mayor`, `venta_mayor`, `unidades_mayor`, `fecha_ingreso`, `fecha_vencimiento`.

---

## 🛠️ 2. Colección Raíz: `Catalogos` (Nuevo Paradigma)
**ATENCIÓN BACKEND:** Las antiguas colecciones raíz (`Categorias`, `Proveedores`, `Unidades`) han sido eliminadas. 
Todo el sistema de catálogos ahora vive dentro de **un único documento maestro** con arrays embebidos.

- **Document ID (Único):** `Catalogos/configuracion`

### 📄 Campos (Arrays de Objetos):
1. **Array `categorias`**:
   - `id` (String)
   - `nombre` (String)
   
2. **Array `proveedores`**:
   - `id` (String)
   - `nombre` (String)
   
3. **Array `unidades`**:
   - `id` (String)
   - `nombre` (String)
   - `abreviado` (String) - *Ej: "Uni", "Dias", "Lbs", "Mts"*
   - `menor_mayor` (Boolean) - *Ej: false*

*Nota del DBA:* Esto optimiza radicalmente las lecturas. Al leer el documento `configuracion`, el frontend descarga TODOS los catálogos en una sola petición.

---

## 👥 3. Colección Raíz: `Usuarios`
La estructura del usuario se ha enriquecido.

- **Document ID:** UID de Firebase Auth.
- **Campos Base:**
  - `Nombres` (String)
  - `Apellidos` (String)
  - `Correo` (String) - *Email de registro*
  - `Idcorreo` (String) - *Email corporativo alternativo o principal*
  - `FotoUrl` (String) - *URL de Firebase Storage*
  - `Telefono` (String) - *Nuevo campo detectado*
  - `IdDispositivo` (String) - *Para notificaciones push/sesión única*
  - `Estado` (String) - *"Activo"*
  - `Rol` (String) - *ID de referencia al rol*
  - `Fecha` (String)
  - `fecha_actualizacion` (String)
  - `fecha_aprobacion` (String)
- **Campo Embebido de Autorización:**
  - `permisos` (Map/Object) - Ahora los permisos específicos viven directamente en el documento del usuario (Ej: `Cierre - Crear Egresos: true`, `Inventario - Ver datos: true`).

---

## 🏷️ 4. Colección Raíz: `Codigos` (Nueva Colección)
Nueva colección raíz detectada. Parece funcionar como un registro maestro o pre-registro de códigos de barras (quizás una base de datos externa de productos conocidos o códigos de balanza).

- **Document ID:** Código de Barras (Ej: `7500042744366`)
- **Campos:**
  - `Creado` (String) - *Ej: "10-08-2026"*
  - `nombre` (String) - *Ej: "Pan, Galleta Girasol"*
  - `precio` (String) - *Ej: "0.00"*
  - `codigo` (Boolean) - *Ej: false*

---

## 📈 Conclusión y Próximos Pasos para Backend
La estructura de base de datos en la nube ha evolucionado hacia un modelo mucho más **NoSQL-puro y eficiente** (especialmente la consolidación de `Catalogos` en un solo documento).

**Tareas inminentes para el Arquitecto/Backend:**
1. Destruir el actual `servicio_catalogos.dart` y reprogramarlo para que escuche el documento único `Catalogos/configuracion` y maneje los datos localmente.
2. Actualizar `modelos_usuarios.dart` para parsear los nuevos campos (`Telefono`, `IdDispositivo`) y el mapa embebido de `permisos`.
3. Revisar el flujo de la nueva colección `Codigos` si la Web Admin necesita interactuar con ella.
