import 'dart:convert';

import 'package:sembast/sembast.dart';

import '../../models/catalogo.dart';

// Fuente local del catálogo: guarda la última respuesta del servidor con su fecha
class CatalogoLocal {
  CatalogoLocal(this._abrir);

  // Función que entrega la base abierta (en las pruebas se usa una base en memoria)
  final Future<Database> Function() _abrir;

  final _store = stringMapStoreFactory.store('catalogo');

  Future<void> guardar(Catalogo catalogo, DateTime fecha) async {
    final db = await _abrir();
    await _store.record('ultimo').put(db, {
      'fecha': fecha.toIso8601String(),
      'datos': jsonEncode(catalogo.toJson()),
    });
  }

  // null cuando todavía no hay nada guardado
  Future<(Catalogo, DateTime)?> leer() async {
    final db = await _abrir();
    final registro = await _store.record('ultimo').get(db);
    if (registro == null) return null;
    final catalogo = Catalogo.fromJson(jsonDecode(registro['datos'] as String) as Map<String, dynamic>);
    return (catalogo, DateTime.parse(registro['fecha'] as String));
  }
}
