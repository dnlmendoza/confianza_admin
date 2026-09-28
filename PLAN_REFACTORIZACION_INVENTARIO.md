# Plan de Refactorización: Módulo de Inventario

## 1. Análisis Actual
El archivo `vista_inventario.dart` contiene más de 3,000 líneas de código. Actualmente aloja:
- Modelos de datos (`BodegaDistribucion`, `ProductoPedido`, `LotePedido`, `PedidoInventario`).
- Lógica de estado local masiva para el control de pedidos, pestañas de detalles (Artículos, Contabilidad, Lotes).
- Cientos de funciones de construcción de widgets (`_buildInteractiveTaxField`, `_buildDropdownField`, etc.).
- UI compleja de doble panel (lista a la izquierda, detalles a la derecha).

## 2. Objetivos
- **Migrar a Riverpod**: Mover todo el estado local (`_pedidos`, `_selectedPedido`, `_activeDetailTab`, `_selectedLoteIndex`) a un `NotifierProvider`.
- **Extraer Modelos**: Mover las clases de datos a un archivo dedicado `modelos_inventario.dart`.
- **Modularizar la Interfaz**:
  - `inventory_orders_list.dart`: El panel izquierdo con la lista de pedidos.
  - `inventory_detail_panel.dart`: El panel derecho de detalles (que incluye las sub-pestañas).
  - `inventory_tab_articles.dart`: Pestaña "Datos Artículos".
  - `inventory_tab_accounting.dart`: Pestaña "Contabilidad".
  - `inventory_tab_lots.dart`: Pestaña "Datos Lotes".
  - `inventory_form_fields.dart`: Colección de inputs interactivos (`_buildInteractiveTaxField`, etc.).

## 3. Fases de Ejecución

### Fase 1: Fundamentos (Modelos y Estado Global)
- [x] Crear `lib/modulos/inventario/modelos_inventario.dart` y mover los modelos.
- [x] Crear `lib/modulos/inventario/inventario_view_model.dart` con `Riverpod`.
- [x] Limpiar dependencias antiguas (como el viejo `vm_inventario.dart` si no se usa).

### Fase 2: Componentes Reutilizables (Formularios)
- [x] Extraer funciones de construcción de campos (`_buildInteractiveTaxField`, `_buildDetailFormTextField`, `_buildDropdownField`) a un archivo de utilidades o widgets estáticos.

### Fase 3: Desacoplamiento de Pestañas
- [x] Extraer la pestaña de Artículos (`_buildDatosArticulosTab`).
- [x] Extraer la pestaña de Contabilidad (`_buildContabilidadTab`).
- [x] Extraer la pestaña de Lotes (`_buildLotesSection`).

### Fase 4: Integración Final
- [x] Ensamblar `vista_inventario.dart` utilizando los nuevos componentes y el estado de Riverpod.
- [x] Asegurar que el layout siga siendo responsive (`LayoutBuilder` y `BoxConstraints`).
