class TipoDocumentoRow {
  final String id;
  final String descripcion;

  TipoDocumentoRow({required this.id, required this.descripcion});

  factory TipoDocumentoRow.fromJson(Map<String, dynamic> j) {
    return TipoDocumentoRow(
      id: (j['idTipo_Documento'] ?? j['ID_Tipo_Documento'] ?? j['id'] ?? '').toString(),
      descripcion: (j['Descripcion'] ?? j['descripcion'] ?? '').toString(),
    );
  }
}

class PerfilRow {
  final String idPersona;
  final String nombre;
  final String correo;
  final String numeroDocumento;
  final String tipoDocumentoId;
  final String rolDescripcion;
  final String? fotoPath;

  // editable (para modal)
  String? contrasenaTmp;

  PerfilRow({
    required this.idPersona,
    required this.nombre,
    required this.correo,
    required this.numeroDocumento,
    required this.tipoDocumentoId,
    required this.rolDescripcion,
    required this.fotoPath,
    this.contrasenaTmp,
  });

  factory PerfilRow.fromJson(Map<String, dynamic> j) {
    final rol = j['Rol'];
    final rolDesc = (rol is Map)
        ? (rol['Descripcion_Rol'] ?? rol['descripcion'] ?? 'Empleado').toString()
        : (j['RolDescripcion'] ?? j['rol'] ?? 'Empleado').toString();

    return PerfilRow(
      idPersona: (j['idPersona'] ?? j['ID_Persona'] ?? j['id'] ?? '').toString(),
      nombre: (j['Nombre'] ?? j['nombre'] ?? '').toString(),
      correo: (j['Correo'] ?? j['correo'] ?? '').toString(),
      numeroDocumento: (j['Numero_Documento'] ?? j['Documento'] ?? j['documento'] ?? '').toString(),
      tipoDocumentoId: (j['Tipo_Documento_id'] ?? j['TipoDocumentoId'] ?? j['tipo_documento_id'] ?? '').toString(),
      rolDescripcion: rolDesc,
      fotoPath: (j['Foto'] ?? j['foto'] ?? j['Fotos'] ?? j['fotos'])?.toString(),
    );
  }

  PerfilRow copyWith({
    String? nombre,
    String? correo,
    String? numeroDocumento,
    String? tipoDocumentoId,
    String? rolDescripcion,
    String? fotoPath,
    String? contrasenaTmp,
  }) {
    return PerfilRow(
      idPersona: idPersona,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      tipoDocumentoId: tipoDocumentoId ?? this.tipoDocumentoId,
      rolDescripcion: rolDescripcion ?? this.rolDescripcion,
      fotoPath: fotoPath ?? this.fotoPath,
      contrasenaTmp: contrasenaTmp ?? this.contrasenaTmp,
    );
  }
}
