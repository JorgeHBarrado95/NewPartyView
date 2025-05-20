class Persona {
  String nombre;
  bool esAnfitrion;
  String uid;
  String fotoUrl= "https://1drv.ms/i/c/f0a46d1dbb249072/IQRnWN3uXx_9QZE1hEEYpUWWAf-gmWac--x2INSSsA7geos?width=1024";

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


