import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  //SON LOS SNACKBAR QUE SE USAN EN TODA LA APLICACION
  static SnackBar aprobacion(String title, String message) {
    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.success,
      ),
    );
  }

  static SnackBar error(String title, String message) {
    final _player = AudioPlayer();
    _player.play(AssetSource("sounds/error.mp3"));

    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.failure,
      ),
    );
  }

  static SnackBar info(String title, String message, {Widget? leading, Color? background}) {
    final _player = AudioPlayer();
    _player.play(AssetSource("sounds/pop.mp3"));
    
    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: background ?? Colors.transparent,
      content: Row(
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: 12),
          ],
          Expanded(
            child: AwesomeSnackbarContent(
              title: title,
              message: message,
              contentType: ContentType.warning,
            ),
          ),
        ],
      ),
    );
  }
}
