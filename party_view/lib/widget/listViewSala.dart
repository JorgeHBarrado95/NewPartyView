import "package:flutter/material.dart";
import "package:party_view/models/sala.dart";
import "package:party_view/provider/salaProvider.dart";
import "package:party_view/provider/personaProvider.dart";
import "package:party_view/services/webSocketService.dart";
import "package:provider/provider.dart";
import "package:cached_network_image/cached_network_image.dart";

class ListViewSala extends StatelessWidget {
  const ListViewSala({super.key, required this.salas});

  final List<Sala> salas;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: salas.length,
      itemBuilder: (context, index) {
        final sala = salas[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(sala.anfitrion.url),
                  ), // Foto de perfil del anfitrión con caché
                  title: Text("Sala: #${sala.id}"),
                  subtitle: Text(
                    "Capacidad max: ${sala.capacidad}, Estado: ${sala.estado}",
                  ),
                  onTap: () {
                    unirseSala(context, sala);
                  },
                ),
                Text("Anfitrión: ${sala.anfitrion.nombre}"),
              ],
            ),
          ),
        );
      },
    );
  }

  void unirseSala(BuildContext context, Sala sala) async{
    final _salaProvider = Provider.of<SalaProvider>(context, listen: false);
    final _personaProvider = Provider.of<PersonaProvider>(context, listen: false);
    WebSocketServicio _webSocketServicio = WebSocketServicio();

    _webSocketServicio.conexion(context);
    _webSocketServicio.unirseSala(
      id: sala.id,
      persona: _personaProvider.getPersona!.toJson(),
    );
  }




  // void conectarSala(BuildContext context, Sala sala) async {
  //   final _salaProvider = Provider.of<SalaProvider>(context, listen: false);

  //   GestorSalasService _gestorSalasService = GestorSalasService();
  //   try {
  //     final _posibleSala = await _gestorSalasService.comprobarSiExiste(sala.id);
  //     if (_posibleSala is Sala) {
  //       _salaProvider.setSala(_posibleSala);
  //       //Se comprueba q exista la sala todavia
  //       if (_salaProvider.sala!.estado == "Abierto") {
  //         final _personaProvider = Provider.of<PersonaProvider>(
  //           context,
  //           listen: false,
  //         );

  //         // Verifica que la persona NO esté en la lista de bloqueados
  //         if (_salaProvider.sala!.bloqueados
  //             .where(
  //               (persona) =>
  //                   persona.ip == _personaProvider.getPersona?.ip &&
  //                   persona.nombre == _personaProvider.getPersona?.nombre,
  //             )
  //             .isEmpty) {
  //           if (_salaProvider.sala!.invitados.length <
  //               _salaProvider.sala!.capacidad) {
  //             Navigator.pushNamed(
  //               context,
  //               "/salaEspera",
  //               arguments: {"sala": sala, "esAnfitrion": false},
  //             );
  //             if (_personaProvider.getPersona != null) {
  //               _salaProvider.sala!.invitados.add(
  //                 _personaProvider.getPersona!,
  //               ); // Añade el invitado a la sala
  //             } else {
  //               ScaffoldMessenger.of(context)
  //                 ..hideCurrentSnackBar()
  //                 ..showSnackBar(
  //                   CustomSnackbar.error(
  //                     "¡Error!",
  //                     "No se pudo añadir a la sala. Se ha detectado un error interno.",
  //                   ),
  //                 );
  //               return;
  //             }

  //             try {
  //               await _gestorSalasService.actualizarSala(_salaProvider.sala!);
  //               print("Añadido a la sala");
  //             } catch (error) {
  //               print("Error al añadir a la sala: $error");
  //               ScaffoldMessenger.of(context)
  //                 ..hideCurrentSnackBar()
  //                 ..showSnackBar(
  //                   CustomSnackbar.error(
  //                     "Error",
  //                     "Error al meterte en la sala",
  //                   ),
  //                 );
  //             }
  //           } else {
  //             ScaffoldMessenger.of(context)
  //               ..hideCurrentSnackBar()
  //               ..showSnackBar(
  //                 CustomSnackbar.error("¡Error!", "La sala está llena."),
  //               );
  //           }
  //         } else {
  //           ScaffoldMessenger.of(context)
  //             ..hideCurrentSnackBar()
  //             ..showSnackBar(
  //               CustomSnackbar.error(
  //                 "¡Error!",
  //                 "No puedes entrar a la sala, estás bloqueado.",
  //               ),
  //             );
  //         }
  //       } else {
  //         ScaffoldMessenger.of(context)
  //           ..hideCurrentSnackBar()
  //           ..showSnackBar(
  //             CustomSnackbar.error("¡Error!", "La sala está cerrada."),
  //           );
  //       }
  //     }
  //   } catch (error) {
  //     print(error);
  //     ScaffoldMessenger.of(context)
  //       ..hideCurrentSnackBar()
  //       ..showSnackBar(
  //         CustomSnackbar.error(
  //           "¡Error!",
  //           "Algo salió mal al realizar la acción.",
  //         ),
  //       );
  //   }
  // }
}
