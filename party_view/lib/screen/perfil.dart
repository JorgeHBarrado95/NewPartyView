import 'package:flutter/material.dart';
import 'package:party_view/widget/cambiarNombre.dart';
import 'package:party_view/widget/fotoPerfil.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8EE),
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
                const SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.deepPurple, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
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
                const SizedBox(height: 24),
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
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.home),
                                          color: Colors.white,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
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
                                ),
                                Positioned(
                                  top: 24,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        "Personalización del perfil",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          letterSpacing: 1.2,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 6,
                                              color: Colors.black26,
                                              offset: Offset(1, 2),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 64),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            fotoPerfil(), //FOTO DE PERFIL
                                            const SizedBox(height: 16),
                                            cambiarNombre(), //CAMBIAR NOMBRE
                                          ],
                                        ),
                                      ),
                                    ],
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
    );
  }
}



