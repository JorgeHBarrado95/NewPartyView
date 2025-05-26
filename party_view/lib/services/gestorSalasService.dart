import "dart:convert";
import "package:http/http.dart" as http;
import "package:party_view/models/persona.dart";
import "package:party_view/models/sala.dart";

/// Servicio que gestiona las operaciones relacionadas con las salas en la base de datos.
class GestorSalasService {
  /// URL base de la base de datos de Firebase.
  final String url =
      "https://partyview-8ba30-default-rtdb.europe-west1.firebasedatabase.app/Salas";

  /// Comprueba si una sala con el ID especificado existe en la base de datos.
  ///
  /// [id] El ID de la sala a comprobar.
  /// Retorna el ID si no existe, o un objeto [Sala] si existe.
  Future<dynamic> comprobarSiExiste(String id) async {
    final url2 = Uri.parse("${this.url}/${id}.json");
    final response = await http.get(url2);

    if (response.body == "null") {
      // Si la respuesta es null, no existe la sala.
      return 0;
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Sala.fromJson(id, data); // Convierte el JSON en un objeto Sala.
    }
  }

  /// Obtiene todas las salas almacenadas en la base de datos.
  ///
  /// Retorna una lista de objetos [Sala].
  /// Lanza una excepción si ocurre un error durante la operación.
  Future<List<Sala>> getSalas() async {
    final url = Uri.parse("${this.url}.json");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Fallo al obtener salas: ${response.body}");
    }

    if (response.body == "null" || response.body.isEmpty) {
      return []; // Devuelve una lista vacía si no hay salas.
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<Sala> salas = [];

    data.forEach((key, value) {
      salas.add(Sala.fromJson(key, value));
    });

    return salas;
  }

  /// Elimina una sala de la base de datos.
  ///
  /// [id] El ID de la sala que se desea eliminar.
  /// Lanza una excepción si ocurre un error durante la operación.
  Future<void> removeSalas(String id) async {
    final url = Uri.parse("${this.url}/${id}.json");
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception("Fallo al eliminar sala: ${response.body}");
    }
  }

  /// Obtiene la lista de invitados de una sala específica, esto solo se usa para el anfitrion,
  /// porq solo se necesita actualizar la lista de invitados.
  ///
  /// [id] El ID de la sala cuyos invitados se desean obtener.
  /// Retorna una lista de objetos [Persona].
  /// Lanza una excepción si ocurre un error durante la operación.
Future<List<Persona>> obtenerInvitados(String id) async {
  final url = Uri.parse("${this.url}/${id}/invitados.json");
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Fallo al obtener invitados: ${response.body}");
  }
  if (response.body == "null" || response.body.isEmpty) {
    return [];
  }

  final data = jsonDecode(response.body);
  final List<Persona> invitados = [];

  if (data is List) {
    for (var item in data) {
      if (item != null) {
        invitados.add(Persona.fromJson(item as Map<String, dynamic>));
      }
    }
  } else if (data is Map) {
    for (var item in data.values) {
      if (item != null) {
        invitados.add(Persona.fromJson(item as Map<String, dynamic>));
      }
    }
  }

  return invitados;
}

  Future<dynamic> obtenerSala(String id) async {
    final url2 = Uri.parse("${this.url}/${id}.json");
    final response = await http.get(url2);

    final Map<String, dynamic> data = jsonDecode(response.body);

    return Sala.fromJson(id, data); 
  }

}








