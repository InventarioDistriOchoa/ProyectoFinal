import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../models/reporte_models.dart';
import '../services/reportes_service.dart';

import '../utils/web_download_stub.dart'
    if (dart.library.html) '../utils/web_download.dart';

class ReportesController extends ChangeNotifier {
  final ReportesService _service = ReportesService();

  bool loading = false;
  String error = '';
  bool isAdmin = false;

  // CRUDOS TIPADOS
  List<StockRow> stockRows = [];
  List<EntradaRow> entradasRows = [];
  List<VentaRow> ventasRows = [];

  // PROCESADOS
  List<StockRow> productosStock = [];
  List<StockRow> alertasStock = [];

  Map<String, int> categoriasCount = {};
  Map<String, int> estadosCount = {'verde': 0, 'amarillo': 0, 'rojo': 0};

  Map<String, int> entradasPorMes = {};
  Map<String, int> ventasPorMes = {};
  Map<String, int> ventasPorProducto = {};

  int totalProductos = 0;
  int totalCategorias = 0;
  int stockTotal = 0;

  Future<void> cargarReportes() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      await _cargarRolLocal();

      final stock = await _service.getStock();
      final entradas = await _service.getEntradas();
      final ventas = await _service.getVentas();

      stockRows = stock;
      entradasRows = entradas;
      ventasRows = ventas;

      _procesarStock(stock);
      _procesarEntradas(entradas);
      _procesarVentas(ventas);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarRolLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = (prefs.getString('rol') ?? '').toLowerCase().trim();
    isAdmin = rol == 'admin' || rol == 'superadmin';
  }

  void _procesarStock(List<StockRow> stock) {
    productosStock = [];
    categoriasCount = {};
    estadosCount = {'verde': 0, 'amarillo': 0, 'rojo': 0};
    alertasStock = [];
    stockTotal = 0;

    for (final x in stock) {
      productosStock.add(x);

      if (x.categoria.isNotEmpty) {
        categoriasCount[x.categoria] = (categoriasCount[x.categoria] ?? 0) + 1;
      }

      final estado = x.estado.toLowerCase().trim();
      if (estadosCount.containsKey(estado)) {
        estadosCount[estado] = (estadosCount[estado] ?? 0) + 1;
      }

      stockTotal += x.disponible;

      // Si quieres solo alertas amarillo/rojo:
      // if (estado == 'amarillo' || estado == 'rojo') alertasStock.add(x);
      alertasStock.add(x);
    }

    totalProductos = productosStock.length;
    totalCategorias = categoriasCount.length;
  }

  void _procesarEntradas(List<EntradaRow> entradas) {
    entradasPorMes = {};
    for (final e in entradas) {
      final fecha = e.fecha;
      if (fecha == null) continue;
      final key = '${_mesCorto(fecha.month)} ${fecha.year}';
      entradasPorMes[key] = (entradasPorMes[key] ?? 0) + e.cantidad;
    }
  }

  void _procesarVentas(List<VentaRow> ventas) {
    ventasPorMes = {};
    ventasPorProducto = {};

    for (final v in ventas) {
      if (v.productoId.isNotEmpty) {
        ventasPorProducto[v.productoId] =
            (ventasPorProducto[v.productoId] ?? 0) + v.cantidad;
      }

      final fecha = v.fecha;
      if (fecha == null) continue;

      final key = '${_mesCorto(fecha.month)} ${fecha.year}';
      ventasPorMes[key] = (ventasPorMes[key] ?? 0) + v.cantidad;
    }
  }

  // GETTERS UI
  ResumenReportes get resumen => ResumenReportes(
        productos: totalProductos,
        categorias: totalCategorias,
        stockTotal: stockTotal,
      );

  List<BarItem> get productosMasVendidos {
    final items = <BarItem>[];

    for (final p in productosStock) {
      final vendidos = ventasPorProducto[p.id] ?? 0;
      items.add(BarItem(label: p.producto, value: vendidos.toDouble()));
    }

    items.sort((a, b) => b.value.compareTo(a.value));
    return items.take(10).toList();
  }

  List<BarItem> get stockActual {
    return productosStock
        .map((p) => BarItem(label: p.producto, value: p.disponible.toDouble()))
        .toList();
  }

  StockEstadoData get stockPorEstado => StockEstadoData(
        verde: estadosCount['verde'] ?? 0,
        amarillo: estadosCount['amarillo'] ?? 0,
        rojo: estadosCount['rojo'] ?? 0,
      );

  List<LineaMesItem> get entradasVsVentas {
    final keys = <String>{
      ...entradasPorMes.keys,
      ...ventasPorMes.keys,
    }.toList();

    keys.sort((a, b) => _mesKeyToDate(a).compareTo(_mesKeyToDate(b)));

    return keys
        .map((k) => LineaMesItem(
              mes: k,
              entradas: (entradasPorMes[k] ?? 0).toDouble(),
              ventas: (ventasPorMes[k] ?? 0).toDouble(),
            ))
        .toList();
  }

  /* =========================================================
     EXPORTAR PDF
  ========================================================= */

  Future<void> exportarPdf(BuildContext context) async {
    try {
      // Si no hay datos, fuerza carga
      if (stockRows.isEmpty && entradasRows.isEmpty && ventasRows.isEmpty) {
        await cargarReportes();
      }

      final now = DateTime.now();
      final df = DateFormat('yyyyMMdd_HHmmss');
      final fileName = 'reporte_inventario_${df.format(now)}.pdf';

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) => [
            _pdfHeader(now),
            pw.SizedBox(height: 12),

            _pdfSectionTitle('Resumen'),
            _pdfResumenTable(),

            pw.SizedBox(height: 14),
            _pdfSectionTitle('Stock'),
            _pdfStockTable(stockRows),

            pw.SizedBox(height: 14),
            _pdfSectionTitle('Entradas'),
            _pdfEntradasTable(entradasRows),

            pw.SizedBox(height: 14),
            _pdfSectionTitle('Ventas'),
            _pdfVentasTable(ventasRows),
          ],
        ),
      );

      final bytes = await doc.save();

      // WEB: si quieres descargar, se hace distinto.
      // Para que no te reviente, aquí solo avisamos.
     if (kIsWeb) {
  downloadBytesWeb(
    Uint8List.fromList(bytes),
    fileName,
    'application/pdf',
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('PDF descargado ✅')),
  );
  return;
}


      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exportando PDF: $e')),
      );
    }
  }

  /* =========================================================
     EXPORTAR EXCEL
  ========================================================= */

  Future<void> exportarExcel(BuildContext context) async {
    try {
      if (stockRows.isEmpty && entradasRows.isEmpty && ventasRows.isEmpty) {
        await cargarReportes();
      }

      final now = DateTime.now();
      final df = DateFormat('yyyyMMdd_HHmmss');
      final fileName = 'reporte_inventario_${df.format(now)}.xlsx';

      final excel = Excel.createExcel();

      // Limpia hoja default si existe
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

     _excelResumen(excel, resumen);
_excelStock(excel, stockRows);
_excelEntradas(excel, entradasRows);
_excelVentas(excel, ventasRows);

      final bytes = excel.encode();
      if (bytes == null) throw Exception('No se pudo generar el Excel.');

     if (kIsWeb) {
  downloadBytesWeb(
    Uint8List.fromList(bytes),
    fileName,
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Excel descargado ✅')),
  );
  return;
}

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel guardado: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exportando Excel: $e')),
      );
    }
  }

  /* =========================================================
     PDF HELPERS
  ========================================================= */

  pw.Widget _pdfHeader(DateTime now) {
    final d = DateFormat('yyyy-MM-dd HH:mm');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Reporte de Inventario', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Generado: ${d.format(now)}', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _pdfSectionTitle(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _pdfResumenTable() {
    final r = resumen;
    return pw.Table(
      border: pw.TableBorder.all(width: 0.4),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        _pdfRow(['Productos', r.productos.toString()], header: true),
        _pdfRow(['Categorías', r.categorias.toString()], header: false),
        _pdfRow(['Stock total', r.stockTotal.toString()], header: false),
      ],
    );
  }

  pw.Widget _pdfStockTable(List<StockRow> rows) {
    final data = rows.take(200).toList(); // evita pdf infinito
    return pw.Table(
      border: pw.TableBorder.all(width: 0.4),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: [
        _pdfRow(['ID', 'Producto', 'Categoría', 'Disp.', 'Estado'], header: true),
        ...data.map((r) => _pdfRow([
              r.id,
              r.producto,
              r.categoria,
              r.disponible.toString(),
              r.estado,
            ])),
      ],
    );
  }

  pw.Widget _pdfEntradasTable(List<EntradaRow> rows) {
    final data = rows.take(200).toList();
    final d = DateFormat('yyyy-MM-dd');
    return pw.Table(
      border: pw.TableBorder.all(width: 0.4),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        _pdfRow(['Fecha', 'Producto ID', 'Cantidad'], header: true),
        ...data.map((r) => _pdfRow([
              r.fecha == null ? '' : d.format(r.fecha!),
              r.productoId,
              r.cantidad.toString(),
            ])),
      ],
    );
  }

  pw.Widget _pdfVentasTable(List<VentaRow> rows) {
    final data = rows.take(200).toList();
    final d = DateFormat('yyyy-MM-dd');
    return pw.Table(
      border: pw.TableBorder.all(width: 0.4),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        _pdfRow(['Fecha', 'Producto ID', 'Cantidad'], header: true),
        ...data.map((r) => _pdfRow([
              r.fecha == null ? '' : d.format(r.fecha!),
              r.productoId,
              r.cantidad.toString(),
            ])),
      ],
    );
  }

  pw.TableRow _pdfRow(List<String> cells, {bool header = false}) {
    return pw.TableRow(
      decoration: header ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: cells.map((c) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            c,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
            maxLines: 2,
            overflow: pw.TextOverflow.clip,
          ),
        );
      }).toList(),
    );
  }

  /* =========================================================
     EXCEL HELPERS
  ========================================================= */

 void _excelResumen(Excel excel, ResumenReportes resumen) {
  final sheet = excel['Resumen'];

  sheet.appendRow([TextCellValue('Reporte'), TextCellValue('Inventario')]);
  sheet.appendRow([TextCellValue('Productos'), IntCellValue(resumen.productos)]);
  sheet.appendRow([TextCellValue('Categorías'), IntCellValue(resumen.categorias)]);
  sheet.appendRow([TextCellValue('Stock total'), IntCellValue(resumen.stockTotal)]);
  sheet.appendRow([TextCellValue(''), TextCellValue('')]);
  sheet.appendRow([
    TextCellValue('Generado'),
    TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
  ]);
}

void _excelStock(Excel excel, List<StockRow> rows) {
  final sheet = excel['Stock'];

  sheet.appendRow([
    TextCellValue('ID'),
    TextCellValue('Producto'),
    TextCellValue('Categoría'),
    TextCellValue('Disponible'),
    TextCellValue('Estado'),
  ]);

  for (final r in rows) {
    sheet.appendRow([
      TextCellValue(r.id),
      TextCellValue(r.producto),
      TextCellValue(r.categoria),
      IntCellValue(r.disponible),
      TextCellValue(r.estado),
    ]);
  }
}

void _excelEntradas(Excel excel, List<EntradaRow> rows) {
  final sheet = excel['Entradas'];

  sheet.appendRow([
    TextCellValue('Fecha'),
    TextCellValue('Producto ID'),
    TextCellValue('Cantidad'),
  ]);

  for (final r in rows) {
    sheet.appendRow([
      TextCellValue(r.fecha == null ? '' : DateFormat('yyyy-MM-dd').format(r.fecha!)),
      TextCellValue(r.productoId),
      IntCellValue(r.cantidad),
    ]);
  }
}

void _excelVentas(Excel excel, List<VentaRow> rows) {
  final sheet = excel['Ventas'];

  sheet.appendRow([
    TextCellValue('Fecha'),
    TextCellValue('Producto ID'),
    TextCellValue('Cantidad'),
  ]);

  for (final r in rows) {
    sheet.appendRow([
      TextCellValue(r.fecha == null ? '' : DateFormat('yyyy-MM-dd').format(r.fecha!)),
      TextCellValue(r.productoId),
      IntCellValue(r.cantidad),
    ]);
  }
}
  /* =========================================================
     HELPERS
  ========================================================= */

  String _mesCorto(int m) {
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return meses[(m - 1).clamp(0, 11)];
  }

  DateTime _mesKeyToDate(String key) {
    final parts = key.split(' ');
    if (parts.length != 2) return DateTime(1970, 1, 1);

    final mesStr = parts[0].toLowerCase().trim();
    final year = int.tryParse(parts[1]) ?? 1970;

    const map = {
      'ene': 1, 'feb': 2, 'mar': 3, 'abr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'ago': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dic': 12,
    };

    return DateTime(year, map[mesStr] ?? 1, 1);
  }
}

/* ============================
   MODELOS PARA CHARTS / UI
============================ */

class BarItem {
  final String label;
  final double value;
  BarItem({required this.label, required this.value});
}

class LineaMesItem {
  final String mes;
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
