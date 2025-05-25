import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:party_view/widget/seleccionarPantalla.dart';
import 'package:party_view/services/webSocketService.dart';
import 'package:party_view/provider/SalaProvider.dart';
import 'package:provider/provider.dart';

/// Pantalla para la reproducción del anfitrión.
/// Permite compartir la pantalla y transmitirla a los invitados usando WebRTC.
class ReproduccionAnfitrion extends StatefulWidget {
  @override
  _ReproduccionAnfitrion createState() => _ReproduccionAnfitrion();
}

class _ReproduccionAnfitrion extends State<ReproduccionAnfitrion> {
  /// [_localStream] es el flujo de datos captados al compartir la pantalla.
  MediaStream? _localStream;

  /// [_localRenderer] es el renderizador de video que se utiliza para mostrar el flujo de datos en la pantalla.
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  /// [_enLlamada] indica si se está compartiendo pantalla actualmente.
  bool _enLlamada = false;

  /// [fuenteSeleccionada] es la fuente de la pantalla seleccionada (solo en escritorio).
  DesktopCapturerSource? fuenteSeleccionada;

  @override
  void initState() {
    super.initState();
    iniciarRender();
  }

  /// Se llama cuando el widget se elimina del árbol de widgets.
  /// Libera recursos y detiene la transmisión si está activa.
  @override
  void deactivate() {
    super.deactivate();
    if (_enLlamada) {
      _stop();
    }
    _localRenderer.dispose();
  }

  /// Inicializa el renderizador de video local.
  Future<void> iniciarRender() async {
    await _localRenderer.initialize();
    print('[ANFITRION] Renderer inicializado');
  }

  /// Permite seleccionar la fuente de pantalla a compartir.
  /// En escritorio muestra un diálogo, en Android solicita permisos y comienza la transmisión.
  Future<void> seleccionarFuentePantalla(BuildContext context) async {
    if (WebRTC.platformIsDesktop) {
      // Linux y Windows
      final source = await showDialog<DesktopCapturerSource>(
        context: context,
        builder: (context) => SeleccionarPantalla(),
      );
      if (source != null) {
        await _hacerLlamada(source); // Inicia la llamada con la fuente seleccionada
      }
    } else {
      if (WebRTC.platformIsAndroid) {
        // Android
        try {
          await solicitarPermisosSegundoPlano();
          await Future.delayed(Duration(milliseconds: 1000)); // Asegurar que el servicio esté activo
          await _hacerLlamada(null);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al iniciar la proyección: $e',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> solicitarPermisosSegundoPlano([bool isRetry = false]) async {
    try {
      var hasPermissions = await FlutterBackground.hasPermissions;
      if (!isRetry) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: 'Compartiendo pantalla',
          notificationText: 'Party View está compartiendo la pantalla.',
          notificationImportance: AndroidNotificationImportance.high,
          notificationIcon: AndroidResource(name: 'background_icon', defType: 'mipmap'),
        );
        hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
      }
      if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.enableBackgroundExecution();
      }
    } catch (e) {
      if (!isRetry) {
        return await Future<void>.delayed(const Duration(seconds: 1), () => solicitarPermisosSegundoPlano(true));
      }
      print('No se pudo iniciar la proyección de pantalla: $e');
    }
  }

  ///[_hacerLlamada] Esta función se encarga de hacer la llamada
  Future<void> _hacerLlamada(DesktopCapturerSource? source) async {
    setState(() {
      fuenteSeleccionada = source;
    });

    try {
      // Esperar a q se inicien los permisos de segundo plano en Android
      if (WebRTC.platformIsAndroid) {
        await Future.delayed(Duration(milliseconds: 300));
      }

      //Se pide acceso a la captura de pantalla
      var stream = await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': fuenteSeleccionada == null //Si es null, es Android
            ? true //Si es true, es desktop, por lo tando se elige la ventana q el usuario seleccionó
            : {
                'deviceId': {'exact': fuenteSeleccionada!.id},
                'mandatory': {'frameRate': 30.0}
              }
      });

      //COMPROBACIONES DE VIDEO TRACKS
      print('[ANFITRION] Captura iniciada. Video tracks: ${stream.getVideoTracks().length}');
      if (stream.getVideoTracks().isNotEmpty) {
        final t = stream.getVideoTracks()[0];
        print('[ANFITRION] video track id: ${t.id}, enabled: ${t.enabled}, muted: ${t.muted}');
      }

      //Cuando el usuario cierra la ventana
      stream.getVideoTracks()[0].onEnded = () {
        print('Captura de pantalla finalizada por el usuario.');
        _colgar();
      };
      
      //Guardamos el stream local capturado
      _localStream = stream;

      // Espera a que el renderer esté inicializado
      if (_localRenderer.textureId != null) {
        print('[ANFITRION] Renderer local ya inicializado');
      }
      await iniciarRender();

      // Asignamos el stream local al renderer local para ir viendo lo q se muestra
      _localRenderer.srcObject = _localStream;
      print('[ANFITRION] Renderer local asignado.');

      //Avisamos al WebSocket que se ha iniciado la captura de pantalla
      final salaProvider = Provider.of<SalaProvider>(context, listen: false);
      final sala = salaProvider.sala;
      if (sala != null) {
        final anfitrionUid = sala.anfitrion.uid;
        final invitadosUids = sala.invitados.map((inv) => inv.uid).toList();
        await WebSocketServicio().empezarTransmision(sala.id, anfitrionUid, invitadosUids, _localStream!);
      }

    } catch (e) {
      print('Error al iniciar captura de pantalla: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al compartir pantalla. Verifica los permisos o intenta de nuevo.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 4),
          ),
        );
      }

      return;
    }

    if (!mounted) return;

    setState(() {
      _enLlamada = true;
    });
  }

  ///[_stop] Detiene la cap de pantalla
  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
      // Limpiamos el renderer local
      await WebSocketServicio().closeAllPeerConnections();

    } catch (e) {
      print(e.toString());
    }
  }
  ///[_colgar] es la función que se encarga de colgar la llamada
  Future<void> _colgar() async {

    await _stop();
    setState(() {
      _enLlamada = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
              child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white10,
            child: Stack(children: <Widget>[
              if (_enLlamada)
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.black54),
                  child: RTCVideoView(_localRenderer),
                )
            ]),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Si el boolean _enLlamada es true, se ejecuta la función _colgar(), si no, se ejecuta la función seleccionarFuentePantalla(context)
          _enLlamada ? _colgar() : seleccionarFuentePantalla(context);
        },
        tooltip: _enLlamada ? 'Hangup' : 'Call',
        child: Icon(_enLlamada ? Icons.call_end : Icons.phone),
      ),
    );
  }
}