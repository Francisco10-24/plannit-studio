import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'shared/theme.dart';
import 'state/evento_model.dart';

void main() {
  runApp(
    // Estado global compartido por todas las pantallas
    ChangeNotifierProvider(
      create: (_) => EventoModel(),
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
