# Análisis de Arquitectura y Seguridad: Módulo `inventario`

**Módulos analizados:** `lib/modulos/inventario/` (`vista_inventario.dart`, `vm_inventario.dart`)
**Estado Actual:** OPERACIÓN RESCATE (Código fuente de conexión perdido).

---

## 1. El Veredicto del Arquitecto (Operación Rescate)
*   **No hay pánico:** Perder código no comiteado es una pesadilla común, pero respira profundo. Revertir o descompilar la página web en producción a código Dart es prácticamente imposible (Flutter compila a JavaScript/WebAssembly minificado). 
*   **La Buena Noticia:** Tenemos el 90% del trabajo difícil guardado: la Interfaz Gráfica (el archivo de 3,000 líneas). Solo perdiste "los cables" que conectaban el botón con la base de datos.
*   **El Plan de Acción:** En lugar de lamentarnos, esto es una bendición disfrazada. Vamos a reconstruir esos cables desde cero, pero esta vez con la arquitectura perfecta de "0 tiempos de carga" que diseñamos hoy. Quedará mejor, más rápido y más seguro que la versión de producción que perdiste.

## 2. El Veredicto del Backend Web (Reescribiendo la Historia)
*   Como dije antes, el módulo local es un cascarón vacío. Ahora sé por qué.
*   Tomaré el mando absoluto de esto. Reconstruiré el `servicio_inventario.dart` paso a paso:
    1. Crearé la función para listar productos (con paginación).
    2. Crearé la función para agregar y editar.
    3. Reconstruiré la lógica de los `lotes` que se perdió.

## 3. El Veredicto del DBA Firebase (Recordatorio de Arquitectura)
Ya que el Backend va a reconstruir la conexión desde cero, es el momento perfecto para inyectar mis reglas:
1.  **Desnormalización:** Al crear un producto, guardaremos el ID y el Nombre de la Categoría.
2.  **Caché de Lotes:** El Backend guardará el *Stock Total* y el *Precio Principal* directamente en el documento del `Inventario` padre.

## 4. El Veredicto del Frontend Web (Alerta Roja de Mantenibilidad)
*   **El Elefante en la Habitación:** Tu archivo `vista_inventario.dart` tiene **3,079 líneas**. 
*   **La Refactorización:** Como prometí, mantendré la fidelidad visual. Pero antes de que el Backend conecte sus nuevos cables, voy a desintegrar este monolito en múltiples archivos: `tabla_inventario.dart`, `modal_crear_producto.dart`, etc. Si tratamos de conectar Firebase en un archivo de 3,000 líneas, cometeremos errores.

## 5. El Veredicto de Catálogo & Usuarios
*   Asumo que el módulo de **Catálogos** sufrió el mismo destino trágico (interfaz local sin conexión). Trabajaré junto al Backend para reconstruir los cables de Catálogos primero, porque Inventario depende de ellos para llenar sus listas desplegables.

## 6. El Veredicto de DevSecOps (Seguridad UI)
*   Al reconstruir los cables, envolveremos los botones de "Crear Artículo" y "Editar" con validadores de roles. Si un usuario tiene rol "Cajero", esos botones desaparecerán mágicamente de la pantalla.
