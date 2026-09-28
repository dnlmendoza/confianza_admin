# Reporte de Auditoría: DBA Firebase

**Mapeo actual de colecciones raíz detectadas:**
- `Usuarios`
- `Roles`
- `Categorias`
- `Inventario`
- `Proveedores`
- `Unidades`
- `Codigos`

**Subcolecciones detectadas:**
- `Inventario/{id}/lote`

---

## Observaciones Críticas y Preguntas para el Usuario

Como tu DBA, mi objetivo es que Firebase sea económico y ridículamente rápido (cero tiempos de carga). Basado en la arquitectura descubierta, responde a los siguientes puntos para definir la estrategia:

### 1. El problema de la subcolección `lote` (Impacto en Móvil POS)
Las subcolecciones son ineficientes para el manejo offline (vital para el POS) y duplican los costos de lectura.
*   **Pregunta:** ¿Los lotes contienen datos extensos, o solo información básica (ej. fecha de caducidad, cantidad)? Si es básico, ¿estás de acuerdo en aplanar esto y convertir `lote` en un Array de objetos dentro del documento padre en `Inventario`?

### 2. Relaciones (Mentalidad SQL en entorno NoSQL)
Tener `Categorias`, `Proveedores` y `Unidades` separados es un patrón de bases de datos relacionales. En Firebase, si haces *joins* manuales (leer inventario y luego ir a leer la categoría por cada artículo), vas a quebrar la cuota de lecturas gratuitas y la app será lenta.
*   **Pregunta:** En los documentos de la colección `Inventario`, ¿guardas solo el `ID` de la categoría/proveedor, o estás guardando el nombre completo directamente (Desnormalización)? 

### 3. DevSecOps (Seguridad)
*   **Pregunta:** En tu consola web de Firebase -> Firestore -> Reglas, ¿las reglas están abiertas ("Modo Prueba": `allow read, write: if true;`) o ya tienes reglas estrictas basadas en roles?

---
*Por favor, responde a estas 3 preguntas en el chat para emitir el veredicto arquitectónico final de la base de datos.*
