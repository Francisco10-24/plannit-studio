import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';

import 'data/api_client.dart';
import 'data/fuentes/base_local.dart';
import 'data/fuentes/carrito_local.dart';
import 'data/fuentes/catalogo_local.dart';
import 'data/repositorios/catalogo_repository.dart';
import 'data/repositorios/solicitudes_repository.dart';
import 'data/servicios/almacenamiento.dart';
import 'data/servicios/auth_service.dart';
import 'data/servicios/notificaciones_push.dart';
import 'firebase_options.dart';
import 'screens/home_shell.dart';
import 'shared/theme.dart';
import 'state/carrito_model.dart';
import 'state/cotizacion_model.dart';
import 'state/navegacion_model.dart';
import 'state/sesion_model.dart';
import 'state/solicitudes_model.dart';

// Permite abrir diálogos desde fuera del árbol de widgets (notificaciones push)
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics (clase 29): errores del framework y errores asíncronos sin capturar
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, pila) {
      FirebaseCrashlytics.instance.recordError(error, pila, fatal: true);
      return true;
    };
    FirebaseMessaging.onBackgroundMessage(manejarMensajeEnSegundoPlano);
  }

  // Fuentes de datos locales (clases 25 y 26)
  final preferencias = await Preferencias.cargar();
  Future<Database> abrirBase() => BaseLocal.instancia.db;

  // Repositories: la implementación se decide aquí y se inyecta por constructor
  final catalogo = CatalogoRepository(
    remota: DioCatalogoRemoto(dio),
    local: CatalogoLocal(abrirBase),
  );
  final SolicitudesRepository solicitudesRepo = FirestoreSolicitudes(FirebaseFirestore.instance);
  // Alternativa sin Firebase (mismo contrato): HttpSolicitudes(dio)

  final carrito = CarritoModel(local: CarritoLocal(abrirBase));
  await carrito.cargar();

  final sesion = SesionModel(
    auth: FirebaseAuthService(FirebaseAuth.instance, FirebaseFirestore.instance),
    preferencias: preferencias,
    almacen: const AlmacenSeguroDispositivo(),
  );
  final solicitudes = SolicitudesModel(solicitudesRepo);
  // Cuando cambia la sesión, se escuchan las solicitudes de ese usuario
  sesion.addListener(() => solicitudes.escucharUsuario(sesion.usuario));

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: catalogo),
        Provider.value(value: preferencias),
        ChangeNotifierProvider(create: (_) => CotizacionModel()),
        ChangeNotifierProvider.value(value: carrito),
        ChangeNotifierProvider.value(value: sesion),
        ChangeNotifierProvider.value(value: solicitudes),
        ChangeNotifierProvider(create: (_) => NavegacionModel()),
      ],
      child: const PlannitApp(),
    ),
  );

  // Notificaciones push: se registran después de dibujar la app
  unawaited(NotificacionesPush.iniciar(navigatorKey));
}

class PlannitApp extends StatelessWidget {
  const PlannitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plannit Studio',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: buildAppTheme(),
      // Calendario y reloj en español
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeShell(),
    );
  }
}
