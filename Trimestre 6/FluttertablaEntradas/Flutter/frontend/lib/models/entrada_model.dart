class Entrada {
  final int? idEntrada;
  final String fecha;
  final String descripcion;
  final int cantidad;
  final int productoId;

  Entrada({
    this.idEntrada,
    required this.fecha,
    required this.descripcion,
    required this.cantidad,
    required this.productoId,
  });

  factory Entrada.fromJson(Map<String, dynamic> json) {
    return Entrada(
      idEntrada: json['idEntrada'],
      fecha: json['fecha'],
      descripcion: json['descripcion'],
      cantidad: json['cantidad'],
      productoId: json['producto_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'producto_id': productoId,
    };
  }
}
