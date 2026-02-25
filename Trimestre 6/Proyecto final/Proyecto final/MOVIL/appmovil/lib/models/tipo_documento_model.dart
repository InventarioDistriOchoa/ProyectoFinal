class TipoDocumentoModel {
  final int idTipoDocumento;
  final String descripcion;

  TipoDocumentoModel({
    required this.idTipoDocumento,
    required this.descripcion,
  });

  factory TipoDocumentoModel.fromJson(Map<String, dynamic> json) {
    return TipoDocumentoModel(
      idTipoDocumento: int.parse((json['idTipo_Documento'] ?? json['idTipoDocumento']).toString()),
      descripcion: (json['Descripcion'] ?? json['descripcion'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'idTipo_Documento': idTipoDocumento,
        'Descripcion': descripcion,
      };
}
