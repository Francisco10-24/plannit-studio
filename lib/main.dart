import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'shared/theme.dart';
import 'state/carrito_model.dart';
import 'state/cotizacion_model.dart';
import 'state/navegacion_model.dart';
import 'state/sesion_model.dart';

void main() {
  runApp(
    // Estados globales que comparten todas las pantallas
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CotizacionModel()),
        ChangeNotifierProvider(create: (_) => CarritoModel()),
        ChangeNotifierProvider(create: (_) => SesionModel()),
        ChangeNotifierProvider(create: (_) => NavegacionModel()),
      ],
      child: const PlannitApp(),
    ),
  );
}

class PlannitApp extends StatelessWidget {
  const PlannitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plannit Studio',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Calendario y reloj en español
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeShell(),
    );
  }
}
