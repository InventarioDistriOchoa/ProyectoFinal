class Venta {
  final int? id;
  final String cliente;
  final String fecha;
  final double total;
  final String estado; // "pendiente", "pagada", "cancelada"

  Venta({
    this.id,
    required this.cliente,
    required this.fecha,
    required this.total,
    required this.estado,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      cliente: json['cliente'],
      fecha: json['fecha'],
      total: (json['total'] as num).toDouble(),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente,
      'fecha': fecha,
      'total': total,
      'estado': estado,
    };
  }
}
