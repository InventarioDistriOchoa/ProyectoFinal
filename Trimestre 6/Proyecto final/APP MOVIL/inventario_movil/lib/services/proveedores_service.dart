import '../models/proveedor.dart';
import 'http_client.dart';

class ProveedoresService {
  final HttpClient http = HttpClient();

  Future<List<Proveedor>> getProveedores() async {
    final res = await http.get("/proveedor/proveedor");
    List data = res["body"];
    return data.map((p) => Proveedor.fromJson(p)).toList();
  }

  Future<Proveedor> createProveedor(Proveedor proveedor) async {
    final res = await http.post(
      "/proveedor/proveedor",
      proveedor.toJson(),
    );
    return Proveedor.fromJson(res["body"]);
  }

  Future<void> deleteProveedor(int id) async {
    await http.delete("/proveedor/proveedor/$id");
  }

  Future<void> updateProveedor(Proveedor proveedor) async {
    await http.put(
      "/proveedor/proveedor/${proveedor.idProveedor}",
      proveedor.toJson(),
    );
  }
}
