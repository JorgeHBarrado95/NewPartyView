import "dart:io";

import "package:flutter/material.dart";
import "package:party_view/models/sala.dart";
import "package:party_view/provider/SalaProvider.dart";
import "package:party_view/provider/personaProvider.dart";
import "package:party_view/services/gestorSalasService.dart";
import "package:party_view/services/webSocketService.dart";
import "package:party_view/widget/listViewSala.dart";
import "package:provider/provider.dart";

class Principal extends StatefulWidget {
  Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  late Future<List<Sala>> _futureSalas;

  @override
  void initState() {
    super.initState();
    _futureSalas = GestorSalasService().getSalas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              // Encabezado
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Party View",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Explora y únete a salas disponibles",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Sala>>(
                  future: _futureSalas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No hay salas disponibles",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error al cargar las salas",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    } else {
                      return ListViewSala(salas: snapshot.data!);
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _futureSalas = GestorSalasService().getSalas();
                    });
                  },
                  backgroundColor: Colors.white, // Botón blanco
                  child: Icon(Icons.refresh, color: Colors.deepPurple), // Ícono púrpura
                  heroTag: "refresh",
                ),
                SizedBox(height: 16),

                //CREAR SALAS
                FloatingActionButton(
                  onPressed: () {
                    // Navigator.pushNamed(
                    //   context,
                    //   "/salaEspera",
                    //   arguments: {"sala": null, "esAnfitrion": true},
                    // );
                    //Sala nueva

                    final personaProvider = Provider.of<PersonaProvider>(
                    context,
                    listen: false,
                    );

                    final salaProrvide = Provider.of<SalaProvider>(
                    context,
                    listen: false,
                    );
                                        personaProvider.esAnfitrion = true;
                    salaProrvide.crearSala(personaProvider.getPersona!);
                    
                    final _socket= WebSocketServicio();
                    
                    _socket.conexion(personaProvider.getPersona!.token!);


                      // Crear sala
                    _socket.crearSala(salaProrvide.sala!);



                  },
                  backgroundColor: Colors.white, // Botón blanco
                  child: Icon(Icons.add, color: Colors.purpleAccent), // Ícono púrpura claro
                  heroTag: "add",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}