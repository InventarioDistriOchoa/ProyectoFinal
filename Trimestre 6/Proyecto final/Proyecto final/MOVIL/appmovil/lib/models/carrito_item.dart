class CarritoItem {
  final int productoId;
  final String nombre;
  final double precio;
  final int cantidad;

  CarritoItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;

  Map<String, dynamic> toJson() => {
        'productoId': productoId,
        'nombre': nombre,
        'precio': precio,
        'cantidad': cantidad,
      };

  factory CarritoItem.fromJson(Map<String, dynamic> json) => CarritoItem(
        productoId: int.tryParse(json['productoId'].toString()) ?? 0,
        nombre: (json['nombre'] ?? '').toString(),
        precio: double.tryParse(json['precio'].toString()) ?? 0,
        cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
      );
}
