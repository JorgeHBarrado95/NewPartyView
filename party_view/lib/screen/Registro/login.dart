import 'package:flutter/material.dart';
import 'package:party_view/utils/loginValidacion.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController campoEmail = TextEditingController();
  final TextEditingController campoContrasena = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    //PRUEBA
    campoEmail.text = "12@gmail.com";
    campoContrasena.text = "123456";
    
    final LoginValidacion _loginValidacion = LoginValidacion();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8EE),
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
                    "Bienvenido",
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
                        double containerHeight = (maxHeight * 0.7).clamp(400.0, 600.0);
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
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () {
                                      String _correo = campoEmail.text;
                                      String _contrasena = campoContrasena.text;
                                      _loginValidacion.iniciarSeseion(context,_correo, _contrasena);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Iniciar Sesión",
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/registro");
                                    },
                                    child: Text(
                                      "¿No tienes cuenta? Regístrate",
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