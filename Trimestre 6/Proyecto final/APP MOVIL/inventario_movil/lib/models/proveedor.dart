class Proveedor {
  final int idProveedor;
  String nombreEmpresa;
  String direccion;

  Proveedor({required this.idProveedor, required this.nombreEmpresa, required this.direccion});

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      idProveedor: json['idProveedor'],
      nombreEmpresa: json['Nombre_Empresa'],
      direccion: json['Direccion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'Nombre_Empresa': nombreEmpresa,
        'Direccion': direccion,
      };
}
