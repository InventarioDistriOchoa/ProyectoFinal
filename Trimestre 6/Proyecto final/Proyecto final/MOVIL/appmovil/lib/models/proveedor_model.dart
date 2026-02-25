class ProveedorModel {
  final int idProveedor;
  final String nombreEmpresa;
  final String direccion;

  ProveedorModel({
    required this.idProveedor,
    required this.nombreEmpresa,
    required this.direccion,
  });

  factory ProveedorModel.fromJson(Map<String, dynamic> json) {
    return ProveedorModel(
      idProveedor: int.tryParse(json['idProveedor'].toString()) ?? 0,
      nombreEmpresa: (json['Nombre_Empresa'] ?? json['nombreEmpresa'] ?? '').toString(),
      direccion: (json['Direccion'] ?? json['direccion'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'idProveedor': idProveedor,
        'Nombre_Empresa': nombreEmpresa,
        'Direccion': direccion,
      };
}
