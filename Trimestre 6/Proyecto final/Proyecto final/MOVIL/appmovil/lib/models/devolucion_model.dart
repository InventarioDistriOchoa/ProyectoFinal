class DevolucionModel {
  final int idDevolucion;
  final String fecha; // yyyy-mm-dd
  final String motivo;
  final int cantidad;
  final int productoId;
  final int tipoDevolucionId;
  final int personaId;

  DevolucionModel({
    required this.idDevolucion,
    required this.fecha,
    required this.motivo,
    required this.cantidad,
    required this.productoId,
    required this.tipoDevolucionId,
    required this.personaId,
  });

  factory DevolucionModel.fromJson(Map<String, dynamic> json) {
    return DevolucionModel(
      idDevolucion: (json['idDevolucion'] ?? 0) as int,
      fecha: (json['Fecha'] ?? '').toString(),
      motivo: (json['Motivo'] ?? '').toString(),
      cantidad: (json['Cantidad'] ?? 0) as int,
      productoId: (json['Producto_id'] ?? 0) as int,
      tipoDevolucionId: (json['TipoDevolucion_id'] ?? 0) as int,
      personaId: (json['Persona_id'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJsonCreate() {
    return {
      'Fecha': fecha,
      'Motivo': motivo,
      'Cantidad': cantidad,
      'Producto_id': productoId,
      'Persona_id': personaId,
      'TipoDevolucion_id': tipoDevolucionId,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'Fecha': fecha,
      'Motivo': motivo,
      'Cantidad': cantidad,
    };
  }
}
