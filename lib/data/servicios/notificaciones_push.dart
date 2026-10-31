import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';

// Manejador de segundo plano: función de nivel superior.
// Sin @pragma('vm:entry-point') el compilador la elimina en release.
@pragma('vm:entry-point')
Future<void> manejarMensajeEnSegundoPlano(RemoteMessage mensaje) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Push en segundo plano: ${mensaje.notification?.title}');
}

// FCM (clase 29). App cerrada o en segundo plano: el sistema muestra la notificación.
// App abierta: llega a onMessage y aquí se decide mostrar un diálogo.
class NotificacionesPush {
  static Future<void> iniciar(GlobalKey<NavigatorState> navigatorKey) async {
    if (kIsWeb) return; // en web requiere configuración extra (service worker)

    final mensajeria = FirebaseMessaging.instance;
    await mensajeria.requestPermission(provisional: true);

    // En firebase_messaging 17, getToken() está deprecado: se reemplaza por
    // register() + onRegistered, que entrega el identificador de esta instalación
    mensajeria.onRegistered.listen((id) {
      // Se muestra solo el inicio: sirve para la campaña de prueba desde la consola
      debugPrint('FCM registrado: ${id.length > 12 ? id.substring(0, 12) : id}...');
    });
    await mensajeria.register();

    FirebaseMessaging.onMessage.listen((mensaje) {
      // navigatorKey da un context desde fuera del árbol de widgets
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(mensaje.notification?.title ?? 'Plannit Studio'),
          content: Text(mensaje.notification?.body ?? ''),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
          ],
        ),
      );
    });
  }
}
