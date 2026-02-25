class CategoriaModel {
  final int idCategoria;
  final String nombreCategoria;
  final String? descripcion;

  CategoriaModel({
    required this.idCategoria,
    required this.nombreCategoria,
    this.descripcion,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: int.tryParse(json['idCategoria'].toString()) ?? 0,
      nombreCategoria: (json['Nombre_Categoria'] ?? '').toString(),
      descripcion: json['Descripcion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Nombre_Categoria': nombreCategoria,
      'Descripcion': (descripcion ?? '').trim(),
    };
  }
}
