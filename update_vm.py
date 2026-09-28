import sys

def modify_viewmodel():
    with open('lib/modulos/inventario/inventario_view_model.dart', 'r') as f:
        content = f.read()

    old_select = """  void selectPedido(PedidoInventario pedido) {
    state = state.copyWith(
      selectedPedido: pedido,
      activeDetailTab: 0,
      selectedLoteIndex: 0,
    );
  }"""

    new_select = """  Future<void> selectPedido(PedidoInventario pedido) async {
    state = state.copyWith(
      selectedPedido: pedido,
      activeDetailTab: 0,
      selectedLoteIndex: 0,
    );
    
    final lotes = await _servicio.getLotesPorPedido(pedido.id);
    if (state.selectedPedido?.id == pedido.id) {
      final updatedPedido = PedidoInventario(
        id: pedido.id,
        nombre: pedido.nombre,
        descripcion: pedido.descripcion,
        proveedor: pedido.proveedor,
        fecha: pedido.fecha,
        pagadoPor: pedido.pagadoPor,
        referencia: pedido.referencia,
        descuento: pedido.descuento,
        impuesto: pedido.impuesto,
        envio: pedido.envio,
        productos: pedido.productos,
        lotes: lotes,
      );
      state = state.copyWith(selectedPedido: updatedPedido);
    }
  }"""

    content = content.replace(old_select, new_select)

    with open('lib/modulos/inventario/inventario_view_model.dart', 'w') as f:
        f.write(content)

modify_viewmodel()
