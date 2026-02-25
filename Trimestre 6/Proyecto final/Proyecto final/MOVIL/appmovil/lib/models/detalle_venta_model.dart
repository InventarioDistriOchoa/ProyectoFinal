class DetalleVentaModel {
  final int idDetalleVenta;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleVentaModel({
    required this.idDetalleVenta,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVentaModel.fromJson(Map<String, dynamic> json) {
    return DetalleVentaModel(
      idDetalleVenta: int.tryParse((json['idDetalleVenta'] ?? json['id']).toString()) ?? 0,
      ventaId: int.tryParse((json['Venta_id'] ?? json['ventaId']).toString()) ?? 0,
      productoId: int.tryParse((json['Producto_id'] ?? json['productoId']).toString()) ?? 0,
      cantidad: int.tryParse((json['Cantidad'] ?? json['cantidad']).toString()) ?? 0,
      precioUnitario: double.tryParse((json['PrecioUnitario'] ?? json['precioUnitario'] ?? 0).toString()) ?? 0,
      subtotal: double.tryParse((json['Subtotal'] ?? json['subtotal'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'Cantidad': cantidad,
        'PrecioUnitario': precioUnitario,
        'Subtotal': subtotal,
        'Venta_id': ventaId,
        'Producto_id': productoId,
      };
}
