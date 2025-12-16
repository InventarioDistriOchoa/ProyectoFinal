class Producto {
  int? id;
  String nombre;
  String descripcion;
  double precio;
  String imagenUrl;
  int stock;

  Producto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      imagenUrl: json['imagenUrl'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'stock': stock,
    };
  }
}
