# Análisis de Arquitectura y Seguridad: Módulo `catalogos`

**Módulos analizados:** `lib/modulos/catalogos/` (`vista_catalogos.dart`, `servicio_catalogos.dart`, `vm_catalogos.dart`)
**Estado Actual:** Sobrevivió a la catástrofe (Conexión intacta).

---

## 1. El Veredicto del Backend Web (¡Buenas Noticias!)
*   **Falsa Alarma:** Pensamos que este módulo también había perdido sus "cables" en el formateo, pero revisé el archivo `servicio_catalogos.dart` y **está 100% conectado a Firebase**. 
*   **Código Elegante:** Has usado una función genérica (`_streamColeccion`) para manejar Categorías, Proveedores y Unidades sin repetir código. Es un trabajo muy limpio. El módulo funciona perfectamente.

## 2. El Veredicto de Catálogos & Usuarios (El Peligro de Renombrar)
He detectado un fallo lógico crítico en tu función `renameCategoria` y `renameProveedor`.
*   **El Problema:** Actualmente, si cambias el nombre de la categoría "Zapatos" a "Calzado", el código solo actualiza el nombre en la colección `Categorias`. 
*   Pero, debido a que en Firebase guardamos el texto "Zapatos" directamente dentro de cada artículo en la colección `Inventario` (para que cargue más rápido), todos los artículos viejos se quedarán huérfanos diciendo que pertenecen a "Zapatos".
*   **La Solución:** Trabajaré con el Backend para que, cuando el administrador presione "Renombrar", el código busque en el `Inventario` todos los artículos que tenían el nombre viejo y los actualice al nombre nuevo usando un *Batch Update* (Actualización en Lote). 

## 3. El Veredicto del DBA Firebase
*   Concuerdo con el equipo de Catálogos. Esa es la desventaja de "desnormalizar" datos en NoSQL (guardar el texto en lugar de solo el ID). 
*   Como acordaste no usar *Cloud Functions* para ahorrar dinero, la solución de hacer el *Batch Update* directamente desde la web es la correcta y la más económica.

## 4. El Veredicto del Frontend Web
*   Tu archivo `vista_catalogos.dart` pesa 30 KB (unas 800 líneas). Comparado con el monstruo del Inventario, esto es un paseo en el parque. 
*   Aún así, aplicaré mi regla de oro: mantendré tu diseño 100% intacto, pero lo dividiré en pequeños componentes (Ej. `PestañaCategorias`, `PestañaProveedores`) para que el código quede impecable.

## 5. El Veredicto de DevSecOps (Seguridad)
*   De la misma forma que en Inventario, este módulo tiene mucho poder destructivo. Borrar una Categoría o Proveedor debe estar reservado.
*   Envolveremos las acciones de "Borrar" y "Editar" para que solo aparezcan si el usuario tiene el permiso de Administrador activo (`isApproved() && esAdministrador()`).

## 6. El Veredicto de QA Web
*   **Checklist de Pruebas a programar:** 
    1. Crear un producto en Inventario con categoría "A". Renombrar la categoría a "B" en Catálogos. Verificar que el producto en Inventario ahora diga "B".
    2. Probar la eliminación de un proveedor y advertir si tiene productos asignados.
