class TipoDevolucionModel {
  final int idTipoDevolucion;
  final String nombreTipo;

  TipoDevolucionModel({
    required this.idTipoDevolucion,
    required this.nombreTipo,
  });

  factory TipoDevolucionModel.fromJson(Map<String, dynamic> json) {
    return TipoDevolucionModel(
      idTipoDevolucion: (json['idTipoDevolucion'] ?? 0) as int,
      nombreTipo: (json['NombreTipo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJsonCreate() => {'NombreTipo': nombreTipo};
  Map<String, dynamic> toJsonUpdate() => {'NombreTipo': nombreTipo};
}
