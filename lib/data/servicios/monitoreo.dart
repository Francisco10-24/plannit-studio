import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Reglas de nombres de Analytics (clase 29): minúsculas y guion bajo,
// máximo 40 caracteres, sin los prefijos reservados firebase_, google_ ni ga_
bool nombreEventoValido(String nombre) {
  if (!RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(nombre)) return false;
  return !['firebase_', 'google_', 'ga_'].any(nombre.startsWith);
}

// Firebase solo existe cuando la app corre de verdad (no en las pruebas)
bool get _firebaseListo => Firebase.apps.isNotEmpty;

// Eventos de Analytics. Ningún parámetro lleva datos personales.
class Analitica {
  static Future<void> evento(String nombre, [Map<String, Object>? parametros]) async {
    assert(nombreEventoValido(nombre), 'Nombre de evento inválido: $nombre');
    if (!_firebaseListo) return;
    await FirebaseAnalytics.instance.logEvent(name: nombre, parameters: parametros);
  }
}

// Reportes de Crashlytics (no disponible en web)
class Reportes {
  static bool get activo => _firebaseListo && !kIsWeb;

  // Error que no cierra la app, con contexto para entenderlo después
  static Future<void> errorNoFatal(Object error, StackTrace? pila, {required String donde}) async {
    debugPrint('Error en $donde: $error');
    if (!activo) return;
    await FirebaseCrashlytics.instance.setCustomKey('donde', donde);
    await FirebaseCrashlytics.instance.recordError(error, pila, fatal: false);
  }
}
