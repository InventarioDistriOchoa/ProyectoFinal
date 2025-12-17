class DetalleVenta {
  int? idDetalleVenta;
  int Cantidad;
  double PrecioUnitario;
  double Subtotal;
  int Venta_id;
  int Producto_id;

  DetalleVenta({
    this.idDetalleVenta,
    required this.Cantidad,
    required this.PrecioUnitario,
    required this.Subtotal,
    required this.Venta_id,
    required this.Producto_id,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      idDetalleVenta: json["idDetalleVenta"],
      Cantidad: json["Cantidad"],
      PrecioUnitario:
          double.tryParse(json["PrecioUnitario"].toString()) ?? 0.0,
      Subtotal: double.tryParse(json["Subtotal"].toString()) ?? 0.0,
      Venta_id: json["Venta_id"],
      Producto_id: json["Producto_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idDetalleVenta": idDetalleVenta,
      "Cantidad": Cantidad,
      "PrecioUnitario": PrecioUnitario,
      "Subtotal": Subtotal,
      "Venta_id": Venta_id,
      "Producto_id": Producto_id,
    };
  }
}
