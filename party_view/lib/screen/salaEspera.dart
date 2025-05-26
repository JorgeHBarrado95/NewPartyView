import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/webSocketService.dart';
import 'package:party_view/widget/listViewInvitados.dart';
import 'package:provider/provider.dart';
import 'package:party_view/provider/salaProvider.dart';
import 'package:flutter/material.dart';

/// Pantalla de sala de espera donde los usuarios pueden ver información de la sala,
/// la lista de invitados y, si son anfitriones, modificar la capacidad y el estado de la sala.
class SalaEspera extends StatefulWidget {
  const SalaEspera({super.key});
  @override
  _SalaEsperaState createState() => _SalaEsperaState();
}

class _SalaEsperaState extends State<SalaEspera> {
  @override
  Widget build(BuildContext context) {
    // Obtiene los providers necesarios para la sala y la persona actual.
    final personaProvider = Provider.of<PersonaProvider>(context, listen: true);
    final salaProvider = Provider.of<SalaProvider>(context, listen: true);
    final bool esAnfitrion = personaProvider.getPersona!.esAnfitrion;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8EE),
      body: Stack(
        children: [
          // Fondo de la pantalla
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
                const SizedBox(height: 32),
                // Título con efecto de gradiente
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.deepPurple, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    "Sala de Espera",
                    style: TextStyle(
                      fontSize: 40,
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
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calcula el tamaño del contenedor principal de la sala
                        double maxWidth = constraints.maxWidth;
                        double maxHeight = constraints.maxHeight;
                        double containerWidth = (maxWidth * 0.95).clamp(500.0, 900.0); 
                        double containerHeight = (maxHeight * 0.8).clamp(400.0, 700.0);
                        return Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            width: containerWidth,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF319EA1), Color(0xFF6DD5ED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Información de la sala (ID, capacidad, estado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 157, 124, 212).withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: salaProvider.sala != null
                                          ? Column(
                                              children: [
                                                // Muestra el ID de la sala
                                                Text(
                                                  "Sala: #${salaProvider.sala!.id}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                // Capacidad de la sala y botones para modificarla si es anfitrión
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Capacidad: ${salaProvider.sala!.capacidad}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    if (esAnfitrion)
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          salaProvider.incrementarCapacidad();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: const CircleBorder(),
                                                          padding: const EdgeInsets.all(10),
                                                          backgroundColor: Colors.white,
                                                          foregroundColor: Colors.deepPurple,
                                                        ),
                                                        child: const Icon(Icons.add, size: 20),
                                                      ),
                                                    if (esAnfitrion)
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          salaProvider.disminuirCapacidad();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: const CircleBorder(),
                                                          padding: const EdgeInsets.all(10),
                                                          backgroundColor: Colors.white,
                                                          foregroundColor: Colors.deepPurple,
                                                        ),
                                                        child: const Icon(Icons.remove, size: 20),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Estado de la sala (Abierto/Cerrado) y dropdown para anfitrión
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Estado: ",
                                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                                    ),
                                                    salaProvider.sala != null && esAnfitrion
                                                        ? DropdownButton<String>(
                                                            dropdownColor: Colors.white,
                                                            value: salaProvider.sala!.estado,
                                                            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                                                            items: ["Abierto", "Cerrado"].map((String estado) {
                                                              return DropdownMenuItem<String>(
                                                                value: estado,
                                                                child: Text(estado, style: const TextStyle(color: Colors.deepPurple)),
                                                              );
                                                            }).toList(),
                                                            onChanged: (String? newValue) {
                                                              if (newValue != null) {
                                                                salaProvider.estado(newValue);
                                                              }
                                                            },
                                                          )
                                                        : Text(
                                                            salaProvider.sala!.estado,
                                                            style: const TextStyle(color: Colors.white, fontSize: 16),
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              "Cargando sala...",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Lista de invitados a la sala
                                    SizedBox(
                                      height: 220,
                                      child: ListaInvitados(esAnfitrion: esAnfitrion),
                                    ),
                                  ],
                                ),
                              ),
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
      // Botones flotantes: salir de la sala y, si es anfitrión, iniciar reproducción
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: Colors.white,
            onPressed: () {
              // Acción para abandonar la sala
              personaProvider.esAnfitrion=false;
              WebSocketServicio _webSocketServicio = WebSocketServicio();
              _webSocketServicio.abandonarSala(salaProvider.sala!.id, personaProvider.getPersona!.uid);
              Navigator.pop(context);

            },
            child: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          if (esAnfitrion)
            FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: Colors.white,
              onPressed: () {
                // Acción para iniciar la reproducción (solo anfitrión)
                final salaProvider = Provider.of<SalaProvider>(context, listen: false);
                WebSocketServicio _webSocketServicio = WebSocketServicio();
                _webSocketServicio.video(salaProvider.sala!.id);
                Navigator.pushNamed(context, "/reproduccion");
              },
              child: const Icon(Icons.play_arrow, color: Colors.purpleAccent),
            ),
        ],
      ),
    );
  }
}

/// Widget que muestra la lista de invitados de la sala.
/// Si la lista está vacía, muestra un mensaje indicándolo.
/// Si el usuario es anfitrión, puede tener opciones adicionales en la lista.
class ListaInvitados extends StatelessWidget {
  const ListaInvitados({super.key, required this.esAnfitrion});
  final bool esAnfitrion;
  @override
  Widget build(BuildContext context) {
    final _salaProvider = Provider.of<SalaProvider>(context, listen: true);
    final invitados = _salaProvider.sala?.invitados ?? [];
    if (invitados.isEmpty) {
      return Center(child: Text("No hay invitados disponibles"));
    }
    return ListViewInvitados(
      invitados: invitados,
      esAnfitrion: esAnfitrion,
    );
  }
}
