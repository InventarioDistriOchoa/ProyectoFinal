// lib/models/user_model.dart

class UserModel {
  final int idPersona;
  final String nombre;
  final String correo;
  final int rolId;
  final String rolNombre;  // 👈 nuevo campo
  final String token;

  UserModel({
    required this.idPersona,
    required this.nombre,
    required this.correo,
    required this.rolId,
    required this.rolNombre, // 👈 nuevo
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final body = json['body'] ?? {};

    return UserModel(
      idPersona: body['idPersona'] is int
          ? body['idPersona']
          : int.tryParse(body['idPersona'].toString()) ?? 0,

      nombre: body['Nombre'] ?? '',

      correo: body['Correo'] ?? '',

      rolId: body['Rol_id'] is int
          ? body['Rol_id']
          : int.tryParse(body['Rol_id'].toString()) ?? 0,

      /// 👇 Aquí intentamos leer el rol como texto.
      /// Backend puede enviarlo como: "Rol", "rol", "nombreRol", "rolName"
      rolNombre: body['Rol']?.toString() ??
          body['rol']?.toString() ??
          body['nombreRol']?.toString() ??
          body['rolName']?.toString() ??
          '',

      token: json['token'] ?? '',
    );
  }
}
