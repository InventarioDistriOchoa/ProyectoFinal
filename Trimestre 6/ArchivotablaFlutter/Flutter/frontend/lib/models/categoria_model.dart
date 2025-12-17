class Categoria {
  final int? id;
  final String nombre;
  final String descripcion;

  Categoria({
    this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
