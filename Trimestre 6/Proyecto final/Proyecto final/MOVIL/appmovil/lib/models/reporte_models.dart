class BarItem {
  final String label;
  final double value;
  BarItem({required this.label, required this.value});
}

class LineaMesItem {
  final String mes; // ej: "ene 2025"
  final double entradas;
  final double ventas;

  LineaMesItem({
    required this.mes,
    required this.entradas,
    required this.ventas,
  });
}

class StockEstadoData {
  final int verde;
  final int amarillo;
  final int rojo;

  StockEstadoData({
    required this.verde,
    required this.amarillo,
    required this.rojo,
  });

  bool get isEmpty => verde == 0 && amarillo == 0 && rojo == 0;
}

class ResumenReportes {
  final int productos;
  final int categorias;
  final int stockTotal;

  ResumenReportes({
    required this.productos,
    required this.categorias,
    required this.stockTotal,
  });
}

class StockRow {
  final String id; // 👈 mejor String (a veces viene "PROD001")
  final String producto;
  final String categoria;
  final int disponible;
  final String estado; // verde | amarillo | rojo

  StockRow({
    required this.id,
    required this.producto,
    required this.categoria,
    required this.disponible,
    required this.estado,
  });

  factory StockRow.fromJson(Map<String, dynamic> j) {
    return StockRow(
      id: (j['id'] ?? j['ID_Producto'] ?? '').toString(),
      producto: (j['producto'] ?? j['Nombre_Producto'] ?? '').toString(),
      categoria: (j['categoria'] ?? j['Nombre_Categoria'] ?? '').toString(),
      disponible: _toInt(j['disponible'] ?? j['Stock'] ?? j['Stock_Minimo']),
      estado: (j['estado'] ?? '').toString().toLowerCase().trim(),
    );
  }
}

class EntradaRow {
  final DateTime? fecha;
  final String productoId; // 👈 String por si es "PROD001"
  final int cantidad;

  EntradaRow({
    required this.fecha,
    required this.productoId,
    required this.cantidad,
  });

  factory EntradaRow.fromJson(Map<String, dynamic> j) {
    final rawFecha = (j['Fecha'] ?? j['fecha']);
    final f = rawFecha == null ? null : DateTime.tryParse(rawFecha.toString());

    return EntradaRow(
      fecha: f,
      productoId: (j['Producto_id'] ?? j['productoId'] ?? j['ID_Producto'] ?? '').toString(),
      cantidad: _toInt(j['Cantidad'] ?? j['cantidad']),
    );
  }
}

class VentaRow {
  final DateTime? fecha;
  final String productoId; // 👈 String por si es "PROD001"
  final int cantidad;

  VentaRow({
    required this.fecha,
    required this.productoId,
    required this.cantidad,
  });

  factory VentaRow.fromJson(Map<String, dynamic> j) {
    final rawFecha = (j['Fecha'] ?? j['fecha']);
    final f = rawFecha == null ? null : DateTime.tryParse(rawFecha.toString());

    return VentaRow(
      fecha: f,
      productoId: (j['Producto_id'] ?? j['productoId'] ?? j['ID_Producto'] ?? '').toString(),
      cantidad: _toInt(j['Cantidad'] ?? j['cantidad']),
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse(v.toString()) ?? 0;
}
