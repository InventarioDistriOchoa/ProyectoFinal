class EntradaModel {
  final int idEntrada;
  final String fecha; // yyyy-mm-dd
  final int cantidad;
  final int productoId;
  final int proveedorId;
  final int? personaId; // a veces viene

  EntradaModel({
    required this.idEntrada,
    required this.fecha,
    required this.cantidad,
    required this.productoId,
    required this.proveedorId,
    this.personaId,
  });

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  static String _toFecha(dynamic fechaRaw) {
    try {
      final dt = DateTime.parse(fechaRaw.toString());
      return dt.toIso8601String().split('T').first;
    } catch (_) {
      return fechaRaw?.toString() ?? '';
    }
  }

  factory EntradaModel.fromJson(Map<String, dynamic> json) {
    return EntradaModel(
      idEntrada: _toInt(json['idEntrada']),
      fecha: _toFecha(json['Fecha']),
      cantidad: _toInt(json['Cantidad']),
      productoId: _toInt(json['Producto_id']),
      proveedorId: _toInt(json['Proveedor_id']),
      personaId: json['Persona_id'] == null ? null : _toInt(json['Persona_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Fecha': fecha,
      'Cantidad': cantidad,
      'Producto_id': productoId,
      'Proveedor_id': proveedorId,
      if (personaId != null) 'Persona_id': personaId,
    };
  }
}
