class VentaFacturaRow {
  final String idVenta;
  final DateTime? fecha;
  final double total;
  final String personaId;

  VentaFacturaRow({
    required this.idVenta,
    required this.fecha,
    required this.total,
    required this.personaId,
  });

  factory VentaFacturaRow.fromJson(Map<String, dynamic> j) {
    final rawFecha = j['Fecha'] ?? j['fecha'];
    final f = rawFecha == null ? null : DateTime.tryParse(rawFecha.toString());

    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return VentaFacturaRow(
      idVenta: (j['idVenta'] ?? j['ID_Venta'] ?? j['id'] ?? '').toString(),
      fecha: f,
      total: toDouble(j['Total'] ?? j['total']),
      personaId: (j['Persona_id'] ?? j['personaId'] ?? j['Documento_Empleado'] ?? '').toString(),
    );
  }
}

class UsuarioRow {
  final String idPersona;
  final String nombre;

  UsuarioRow({
    required this.idPersona,
    required this.nombre,
  });

  factory UsuarioRow.fromJson(Map<String, dynamic> j) {
    return UsuarioRow(
      idPersona: (j['idPersona'] ?? j['Documento_Empleado'] ?? j['id'] ?? '').toString(),
      nombre: (j['Nombre'] ?? j['Nombre_Usuario'] ?? j['nombre'] ?? '').toString(),
    );
  }
}
