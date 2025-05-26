import 'package:flutter/material.dart';
import 'package:party_view/models/sala.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/gestorSalasService.dart';
import 'package:party_view/widget/listViewSala.dart';

import 'package:provider/provider.dart';
import 'package:party_view/provider/salaProvider.dart';
import 'package:party_view/services/webSocketService.dart';

class Principal extends StatefulWidget {
  Principal({super.key});

  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  late Future<List<Sala>> _futureSalas;
  List<Sala> _salasFiltradas = [];
  String _busqueda = "";
  final TextEditingController _buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureSalas = GestorSalasService().getSalas();
    _futureSalas.then((salas) {
      setState(() {
        _salasFiltradas = salas;
      });
    });
  }

  void _filtrarSalas(String idABuscar, List<Sala> todasLasSalas) {
    setState(() {
      _busqueda = idABuscar.replaceAll('#', '');
      if (_busqueda.isEmpty) {
        _salasFiltradas = todasLasSalas;
      } else {
        _salasFiltradas = todasLasSalas.where((sala) => sala.id.toString().contains(_busqueda)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/fondodos.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.purpleAccent, Colors.deepPurple, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    "Party View",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black26,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double maxWidth = constraints.maxWidth;
                        double maxHeight = constraints.maxHeight;
                        double containerWidth = (maxWidth * 0.8).clamp(350.0, 900.0);
                        double containerHeight = (maxHeight * 0.8).clamp(400.0, 700.0);
                        return Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            width: containerWidth,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF319EA1), Color(0xFF6DD5ED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField( //BUSCADOR
                                          controller: _buscadorController,
                                          onChanged: (value) async {
                                            final todasLasSalas = await _futureSalas;
                                            _filtrarSalas(value, todasLasSalas);
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                                            hintText: "Buscador de sala",
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.85),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.home),
                                              color: Colors.white,
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.person),
                                              color: Colors.white,
                                              onPressed: () {
                                                Navigator.pushNamed(context, "/perfil");
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: FutureBuilder<List<Sala>>(
                                      future: _futureSalas,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              "Error al cargar las salas",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        } else {
                                          final todasLasSalas = snapshot.data ?? [];
                                          final salasAMostrar = _busqueda.isEmpty ? todasLasSalas : _salasFiltradas;
                                          if (salasAMostrar.isEmpty) {
                                            return Center(
                                              child: Text(
                                                "No hay salas disponibles",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }
                                          //Retorna el widget ListViewSala con las salas filtradas
                                          return ListViewSala(salas: salasAMostrar);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _futureSalas = GestorSalasService().getSalas();
              });
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.refresh, color: Colors.deepPurple),
            heroTag: "btn1",
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              final personaProvider = Provider.of<PersonaProvider>(
                context,
                listen: false,
              );
              final salaProvider = Provider.of<SalaProvider>(
                context,
                listen: false,
              );
              personaProvider.esAnfitrion = true;
              await salaProvider.crearSala(personaProvider.getPersona!);
              final _socket = WebSocketServicio();
              _socket.conexion(context);
              _socket.crearSala(salaProvider.sala!);
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.purpleAccent),
            heroTag: "btn2",
          ),
        ],
      ),
    );
  }
}


