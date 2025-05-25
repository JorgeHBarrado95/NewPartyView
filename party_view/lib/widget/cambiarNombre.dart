import 'package:flutter/material.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:provider/provider.dart';

class cambiarNombre extends StatefulWidget {
  const cambiarNombre({super.key});

  @override
  State<cambiarNombre> createState() => _cambiarNombreState();
}

class _cambiarNombreState extends State<cambiarNombre> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final personaProvider = Provider.of<PersonaProvider>(context, listen: false);
    _controller = TextEditingController(text: personaProvider.getPersona!.nombre);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personaProvider = Provider.of<PersonaProvider>(context, listen: true);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Cambiar nombre:",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 180,
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: personaProvider.getPersona!.nombre,
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.deepPurple.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            final nuevoNombre = _controller.text.trim();
            if (nuevoNombre.isNotEmpty) {
              await Provider.of<PersonaProvider>(context, listen: false).setNombre(nuevoNombre, context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Cambiar",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}