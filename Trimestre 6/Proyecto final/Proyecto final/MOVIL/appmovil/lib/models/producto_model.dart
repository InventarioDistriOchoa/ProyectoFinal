class ProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precioVenta;
  final int stock;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioVenta,
    required this.stock,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioVenta: (json['precioVenta'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
    );
  }
}
