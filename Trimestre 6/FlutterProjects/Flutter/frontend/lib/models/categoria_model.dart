class Categoria {
  int idCategoria;
  String nombreCategoria;
  String descripcion;

  Categoria({
    required this.idCategoria,
    required this.nombreCategoria,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['idCategoria'],
      nombreCategoria: json['Nombre_Categoria'] ?? json['nombreCategoria'],
      descripcion: json['Descripcion'] ?? json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Nombre_Categoria": nombreCategoria,
      "Descripcion": descripcion,
    };
  }
}
