class UsuarioModel {
  final int idPersona;
  final String nombre;
  final String correo;
  final String numeroDocumento;
  final int tipoDocumentoId;
  final int rolId;
  final String? foto; // "/uploads/..."

  UsuarioModel({
    required this.idPersona,
    required this.nombre,
    required this.correo,
    required this.numeroDocumento,
    required this.tipoDocumentoId,
    required this.rolId,
    this.foto,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final tipoRaw = json['Tipo_Documento_id'];
    final rolRaw1 = json['Rol_id'];
    final rolRaw2 = json['Rol']; // a veces viene como objeto

    int tipoId;
    if (tipoRaw is Map) {
      tipoId = int.tryParse(tipoRaw['idTipo_Documento'].toString()) ?? 0;
    } else {
      tipoId = int.tryParse(tipoRaw.toString()) ?? 0;
    }

    int rolId;
    if (rolRaw2 is Map) {
      rolId = int.tryParse(rolRaw2['idRol'].toString()) ?? 0;
    } else {
      rolId = int.tryParse((rolRaw1 ?? rolRaw2).toString()) ?? 0;
    }

    return UsuarioModel(
      idPersona: int.tryParse(json['idPersona'].toString()) ?? 0,
      nombre: (json['Nombre'] ?? '').toString(),
      correo: (json['Correo'] ?? '').toString(),
      numeroDocumento: (json['Numero_Documento'] ?? '').toString(),
      tipoDocumentoId: tipoId,
      rolId: rolId,
      foto: json['Foto']?.toString(),
    );
  }

  Map<String, dynamic> toCreateJson({
    required String contrasena,
  }) {
    return {
      'Nombre': nombre,
      'Correo': correo,
      'Contrasena': contrasena,
      'Numero_Documento': numeroDocumento,
      'Tipo_Documento_id': tipoDocumentoId,
      'Rol_id': rolId,
    };
  }

  Map<String, dynamic> toUpdateJson({String? contrasena}) {
    return {
      'Nombre': nombre,
      'Correo': correo,
      'Numero_Documento': numeroDocumento,
      'Tipo_Documento_id': tipoDocumentoId,
      'Rol_id': rolId,
      if (contrasena != null && contrasena.isNotEmpty) 'Contrasena': contrasena,
    };
  }
}
