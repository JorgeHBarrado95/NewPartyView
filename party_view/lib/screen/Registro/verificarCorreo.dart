import 'package:flutter/material.dart';

class VerificarCorreoScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8EE),
      body: Center(
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
                "Verifica tu correo",
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
                    double containerWidth = (maxWidth * 0.7).clamp(320.0, 500.0);
                    double containerHeight = (maxHeight * 0.5).clamp(300.0, 400.0);
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
                              Icon(Icons.email_outlined, size: 80, color: Colors.blue),
                              SizedBox(height: 24),
                              Text(
                                "Te hemos enviado un correo de verificación \nPor favor, revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 32),
                              CircularProgressIndicator(color: Colors.deepPurple),
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
    );
  }
}
