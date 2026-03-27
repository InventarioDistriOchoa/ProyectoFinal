class Persona {
  final int? id;
  final String nombre;
  final String correo;
  final String password;
  final String tipoDocumento;
  final String rol;
  final String fotoPerfil;

  Persona({
    this.id,
    required this.nombre,
    required this.correo,
    required this.password,
    required this.tipoDocumento,
    required this.rol,
    required this.fotoPerfil,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      password: json['password'],
      tipoDocumento: json['tipoDocumento'],
      rol: json['rol'],
      fotoPerfil: json['fotoPerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'tipoDocumento': tipoDocumento,
      'rol': rol,
      'fotoPerfil': fotoPerfil,
    };
  }
}
