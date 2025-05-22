
class UsuarioLogin { 
  String? nombre;
  String correo;
  String contrasena;


  UsuarioLogin({required this.correo, required this.contrasena, this.nombre});

  Map<String, dynamic> toJson() {
    return {"email": correo, "password": contrasena};
  }

  factory UsuarioLogin.fromJson(Map<String, dynamic> json) {
    return UsuarioLogin(
      correo: json["email"],
      contrasena: json["password"],
      nombre: json["displayName"],
    );
  }

  void borrarDatos() {
    nombre = null;
    correo = "";
    contrasena = "";
  }

  @override
  String toString() {
    return 'UsuarioLogin(nombre: $nombre, correo: $correo, contrasena: $contrasena)';
  }
}
