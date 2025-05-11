class Persona {
  String nombre;
  bool esAnfitrion;
  String uid;
  String? token;

  Persona({
    required this.nombre,
    required this.esAnfitrion,
    required this.uid,
    required this.token,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      nombre: json["nombre"] as String,
      esAnfitrion: json["esAnfitrion"] as bool,
      uid: json["uid"] as String,
      token: json["token"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "esAnfitrion": esAnfitrion,
      "uid": uid,
      "token": token,
    };
  }
}


