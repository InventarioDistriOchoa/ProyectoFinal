class RolModel {
  final int idRol;
  final String descripcionRol;

  RolModel({
    required this.idRol,
    required this.descripcionRol,
  });

  factory RolModel.fromJson(Map<String, dynamic> json) {
    return RolModel(
      idRol: (json['idRol'] is int) ? json['idRol'] : int.parse(json['idRol'].toString()),
      descripcionRol: (json['Descripcion_Rol'] ?? json['descripcionRol'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Descripcion_Rol': descripcionRol,
      };

  RolModel copyWith({int? idRol, String? descripcionRol}) {
    return RolModel(
      idRol: idRol ?? this.idRol,
      descripcionRol: descripcionRol ?? this.descripcionRol,
    );
  }
}
