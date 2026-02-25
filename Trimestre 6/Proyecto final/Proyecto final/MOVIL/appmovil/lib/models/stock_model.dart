class StockModel {
  final int id;
  final String producto;
  final String estado; // "verde" | "amarillo" | "rojo"
  final String? categoria;
  final int disponible;
  final int entradas;
  final int salidas;
  final int devolucionesProveedor;
  final int devolucionesCliente;

  StockModel({
    required this.id,
    required this.producto,
    required this.estado,
    required this.categoria,
    required this.disponible,
    required this.entradas,
    required this.salidas,
    required this.devolucionesProveedor,
    required this.devolucionesCliente,
  });

  int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      producto: (json['producto'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      categoria: json['categoria']?.toString(),
      disponible: (json['disponible'] is num)
          ? (json['disponible'] as num).toInt()
          : int.tryParse(json['disponible']?.toString() ?? '') ?? 0,
      entradas: (json['entradas'] is num)
          ? (json['entradas'] as num).toInt()
          : int.tryParse(json['entradas']?.toString() ?? '') ?? 0,
      salidas: (json['salidas'] is num)
          ? (json['salidas'] as num).toInt()
          : int.tryParse(json['salidas']?.toString() ?? '') ?? 0,
      devolucionesProveedor: (json['devolucionesProveedor'] is num)
          ? (json['devolucionesProveedor'] as num).toInt()
          : int.tryParse(json['devolucionesProveedor']?.toString() ?? '') ?? 0,
      devolucionesCliente: (json['devolucionesCliente'] is num)
          ? (json['devolucionesCliente'] as num).toInt()
          : int.tryParse(json['devolucionesCliente']?.toString() ?? '') ?? 0,
    );
  }
}
