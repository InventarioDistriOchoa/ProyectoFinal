



class PersonaMini {
  final String? nombre;
  final String? correo;

  PersonaMini({this.nombre, this.correo});

  factory PersonaMini.fromJson(Map<String, dynamic> json) => PersonaMini(
        nombre: json['Nombre']?.toString(),
        correo: json['Correo']?.toString(),
      );
}

class HistorialRow {
  final int idAuditoria;
  final String accion;
  final String coleccion;
  final DateTime createdAt;

  final PersonaMini? persona;
  final dynamic datosAnteriores;
  final dynamic datosNuevos;

  HistorialRow({
    required this.idAuditoria,
    required this.accion,
    required this.coleccion,
    required this.createdAt,
    this.persona,
    this.datosAnteriores,
    this.datosNuevos,
  });

  factory HistorialRow.fromJson(Map<String, dynamic> json) {
    final raw = (json['createdAt'] ?? '').toString();

    return HistorialRow(
      idAuditoria: (json['idAuditoria'] ?? 0) as int,
      accion: (json['accion'] ?? '').toString(),
      coleccion: (json['coleccion'] ?? '').toString(),

      // ✅ CLAVE: convertir a hora local
      createdAt: raw.isEmpty ? DateTime.now() : DateTime.parse(raw).toLocal(),

      persona: json['persona'] == null ? null : PersonaMini.fromJson(json['persona']),
      datosAnteriores: json['datosAnteriores'],
      datosNuevos: json['datosNuevos'],
    );
  }
}
