import "package:party_view/models/persona.dart";

class Sala {
  late String id;
  late String estado;
  late num capacidad;
  late bool video;
  late Persona anfitrion;
  late List<Persona> invitados;
  late List<Persona> bloqueados;

  Sala({
    required this.id,
    required this.capacidad,
    required this.video,
    required this.estado,
    required this.anfitrion,
    required this.invitados,
    required this.bloqueados,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "capacidad": capacidad,
      "video": video,
      "estado": estado,
      "anfitrion": anfitrion.toJson(),
      "invitados": invitados.map((invitado) => invitado.toJson()).toList(),
      "bloqueados": bloqueados.map((invitado) => invitado.toJson()).toList(),
    };
  }

factory Sala.fromJson(String id, Map<String, dynamic> json) {
  List<Persona> transformarPersonas(dynamic data) {
    if (data == null || data == false) return [];
    if (data is List) {
      return data
          .where((item) => item != null)
          .map((item) => Persona.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map) {
      // Si es un mapa de uids a booleanos (caso de bloqueados), ignora y devuelve []
      if (data.values.every((v) => v is bool)) {
        return [];
      }
      // Si es un mapa de personas, parsea normalmente
      return data.values
          .where((item) => item != null)
          .map((item) => Persona.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Valores por defecto si faltan campos
  final capacidad = json["capacidad"] ?? 0;
  final video = json["video"] is bool ? json["video"] : json["video"] == "true";
  final estado = json["estado"] ?? "Desconocido";
  final anfitrion = json["anfitrion"] != null
      ? Persona.fromJson(json["anfitrion"] as Map<String, dynamic>)
      : Persona(
          nombre: "Sin anfitrión",
          esAnfitrion: true,
          uid: "",
          url: "",
        );
  final invitados = transformarPersonas(json["invitados"]);
  final bloqueados = transformarPersonas(json["bloqueados"]);

  return Sala(
    id: id,
    capacidad: capacidad,
    video: video,
    estado: estado,
    anfitrion: anfitrion,
    invitados: invitados,
    bloqueados: bloqueados,
  );
}

  @override
  String toString() {
    String invitadosStr =
        invitados.isEmpty
            ? "No hay invitados"
            : invitados.map((invitado) => invitado.nombre).join(", ");

    return 'Sala{id: $id, estado: $estado, capacidad: $capacidad, video: $video, anfitrion: ${anfitrion.nombre}, invitados: [$invitadosStr]}';
  }
}
