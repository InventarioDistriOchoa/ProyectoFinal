class VentaModel {
  final int idVenta;
  final String fecha; // yyyy-mm-dd
  final double total;
  final int personaId;

  VentaModel({
    required this.idVenta,
    required this.fecha,
    required this.total,
    required this.personaId,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    final fechaRaw = (json['Fecha'] ?? json['fecha'] ?? '').toString();
    final fecha = fechaRaw.contains('T') ? fechaRaw.split('T').first : fechaRaw;

    return VentaModel(
      idVenta: int.tryParse((json['idVenta'] ?? json['id']).toString()) ?? 0,
      fecha: fecha,
      total: double.tryParse((json['Total'] ?? json['total'] ?? 0).toString()) ?? 0,
      personaId: int.tryParse((json['Persona_id'] ?? json['personaId'] ?? 0).toString()) ?? 0,
    );
  }
}
