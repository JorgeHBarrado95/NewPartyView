import 'package:flutter/material.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:provider/provider.dart';

class fotoPerfil extends StatelessWidget {
  const fotoPerfil({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(
            Provider.of<PersonaProvider>(context, listen: true).getPersona!.fotoUrl 
          ),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: () async {
            final imagenes = [
              "https://1drv.ms/i/c/f0a46d1dbb249072/IQRnWN3uXx_9QZE1hEEYpUWWAf-gmWac--x2INSSsA7geos?width=1024",
              "https://1drv.ms/i/c/f0a46d1dbb249072/IQQHS8fWilNWQ47P18YcglaEAfmftJ25XC5-qrF-GXQ2F98?width=1024",
              "https://1drv.ms/i/c/f0a46d1dbb249072/IQTkFcUcDx12SYqz178XAvr7AQap0z-COiTDhqdclfbLfFQ?width=1024",
              "https://1drv.ms/i/c/f0a46d1dbb249072/IQRA-ky4gjbPSLv9Mdf8_1yQAUpVS3RcIxp0QGJDQMvAnQ0?width=1024",
            ];
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Elige tu imagen de perfil"),
                  content: SizedBox(
                    width: 350,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: imagenes.map((url) => GestureDetector(
                        onTap: () {
                          final personaProvider = Provider.of<PersonaProvider>(context, listen: false);
                          personaProvider.setFotoUrl(url);
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(url),
                        ),
                      )).toList(),
                    ),
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Cambiar imagen",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}