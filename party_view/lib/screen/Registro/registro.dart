import 'package:flutter/material.dart';
import 'package:party_view/utils/registroValidacion.dart';

class RegistroScreen extends StatelessWidget {
  final TextEditingController campoNombre = TextEditingController();
  final TextEditingController campoEmail = TextEditingController();
  final TextEditingController campoContrasena = TextEditingController();
  final TextEditingController campoConfirmarContrasena = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //PRUEBA
    campoNombre.text = "Sergio";
    campoEmail.text = "jorgehbarrado@gmail.com";
    campoContrasena.text = "123456";
    campoConfirmarContrasena.text = "123456";

    Registrovalidacion _registroValidacion = Registrovalidacion();
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/fondouno.jpg',
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
                    "Crear Cuenta",
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
                SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double maxWidth = constraints.maxWidth;
                        double maxHeight = constraints.maxHeight;
                        double containerWidth = (maxWidth * 0.8).clamp(350.0, 500.0);
                        double containerHeight = (maxHeight * 0.8).clamp(450.0, 700.0);
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
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextField(
                                      controller: campoNombre,
                                      decoration: InputDecoration(
                                        labelText: "Nombre de usuario",
                                        labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w600, fontSize: 20),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.85),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: campoEmail,
                                      decoration: InputDecoration(
                                        labelText: "Correo electrónico",
                                        labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w600, fontSize: 20),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.85),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: campoContrasena,
                                      decoration: InputDecoration(
                                        labelText: "Contraseña",
                                        labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w600, fontSize: 20),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.85),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                                      ),
                                      obscureText: true,
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: campoConfirmarContrasena,
                                      decoration: InputDecoration(
                                        labelText: "Confirmar contraseña",
                                        labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w600, fontSize: 20),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.85),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(Icons.lock_outline, color: Colors.deepPurple),
                                      ),
                                      obscureText: true,
                                    ),
                                    SizedBox(height: 30),
                                    ElevatedButton(
                                      onPressed: () {
                                        String nombre = campoNombre.text;
                                        String email = campoEmail.text;
                                        String contrasena = campoContrasena.text;
                                        String confirmarContrasena = campoConfirmarContrasena.text;
                                        _registroValidacion.registro(context, nombre, email, contrasena, confirmarContrasena);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        "Registrarse",
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, "/login");
                                      },
                                      child: Text(
                                        "¿Ya tienes cuenta? Inicia sesión",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.deepPurple,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
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
    );
  }
}