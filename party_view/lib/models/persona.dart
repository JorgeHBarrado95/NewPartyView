class Persona {
  String nombre;
  bool esAnfitrion;
  String uid;

  Persona({
    required this.nombre,
    required this.esAnfitrion,
    required this.uid,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      nombre: json["nombre"] as String,
      esAnfitrion: json["esAnfitrion"] as bool? ?? false,
      uid: json["uid"] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "esAnfitrion": esAnfitrion,
      "uid": uid,
    };
  }
}


