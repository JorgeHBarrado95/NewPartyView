import 'dart:io';

import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/webSocketService.dart';
import 'package:party_view/widget/listViewInvitados.dart';
import 'package:provider/provider.dart';

import 'package:party_view/provider/SalaProvider.dart';
import 'package:flutter/material.dart';

class SalaEspera extends StatefulWidget {
  const SalaEspera({super.key});
  @override
  _SalaEsperaState createState() => _SalaEsperaState();
}

class _SalaEsperaState extends State<SalaEspera> {


  @override
  Widget build(BuildContext context) {
    final personaProvider = Provider.of<PersonaProvider>(
      context,
      listen: true,
    );
    final salaProvider = Provider.of<SalaProvider>(
      context,
      listen: true,
    );

    ///Boton de salida
    return Scaffold(
      body: Body(
        esAnfitrion: personaProvider.getPersona!.esAnfitrion,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              WebSocketServicio _webSocketServicio = WebSocketServicio();
              _webSocketServicio.abandonarSala(salaProvider.sala!.id, personaProvider.getPersona!.uid);
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
          SizedBox(height: 10),
          if (personaProvider.getPersona!.esAnfitrion)
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                final salaProvider = Provider.of<SalaProvider>(
                  context,
                  listen: false,
                );
                WebSocketServicio _webSocketServicio = WebSocketServicio();
                _webSocketServicio.video(salaProvider.sala!.id);
                Navigator.pushNamed(
                  context,
                  "/reproduccion",
                );
              },
              child: Icon(Icons.play_arrow),
            ),
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key, required this.esAnfitrion});

  final bool esAnfitrion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          children: [
            MenuArriba(esAnfitrion: esAnfitrion),
            SizedBox(height: 20),
            ListaInvitados(esAnfitrion: esAnfitrion)
          ],
        ),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        margin: EdgeInsets.all(30),
      ),
    );
  }
}

///List View de los invitados.
class ListaInvitados extends StatelessWidget {
  const ListaInvitados({super.key, required this.esAnfitrion});

  final bool esAnfitrion;

  @override
  Widget build(BuildContext context) {
    final _salaProvider = Provider.of<SalaProvider>(context, listen: true);
    final invitados =
        _salaProvider.sala?.invitados ?? []; //Si esta vacío el array, devuelve una lista vacía.

    if (invitados.isEmpty) {
      return Center(child: Text("No hay invitados disponibles"));
    }

    return Expanded(
      child: ListViewInvitados(
        invitados: invitados,
        esAnfitrion: esAnfitrion,
      ),
    );
  }
}

///El [menuArriba] es el menu de la parte superior de la pantalla donde aparece el id, la capacidad y el estado de la sala.
class MenuArriba extends StatefulWidget {
  const MenuArriba({super.key, required this.esAnfitrion});

  final bool esAnfitrion;

  @override
  _MenuArribaState createState() => _MenuArribaState();
}

class _MenuArribaState extends State<MenuArriba> {
  final List<String> _estados = ["Abierto", "Cerrado"];

  @override
  Widget build(BuildContext context) {
    final _salaProvider = Provider.of<SalaProvider>(context, listen: true);
    final sala = _salaProvider.sala;
    final String? estadoActual = sala?.estado;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _salaProvider.sala != null ? "Sala: #${_salaProvider.sala!.id}" : "Cargando sala...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 15),
              Row(
                children: [
                  Text(() {
                    try {
                      return "Capacidad: ${_salaProvider.sala!.capacidad}";
                    } catch (e) {
                      return "Capacidad no disponible";
                    }
                  }(), style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  if (widget.esAnfitrion) //Se pone widget para acceder a la variable de la clase padre
                    ElevatedButton(
                      onPressed: () {
                        _salaProvider.incrementarCapacidad();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                      ),
                      child: Icon(Icons.add, size: 20),
                    ),
                  if (widget.esAnfitrion)
                    ElevatedButton(
                      onPressed: () {
                        _salaProvider.disminuirCapacidad();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                      ),
                      child: Icon(Icons.remove, size: 20),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Estado de la sala:", style: TextStyle(fontSize: 16)),
              SizedBox(width: 15),
              DropdownButton<String>(
                value: estadoActual ?? _estados.first,
                items: _estados.map((String estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: widget.esAnfitrion
                    ? (String? newValue) {
                        if (newValue != null) {
                          _salaProvider.estado(newValue);
                        }
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
