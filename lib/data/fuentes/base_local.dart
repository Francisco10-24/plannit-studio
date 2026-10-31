import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

// Base de datos local NoSQL (Sembast). Patrón singleton de la clase 26:
// constructor privado + una sola instancia + la base se abre una sola vez.
class BaseLocal {
  BaseLocal._();

  static final BaseLocal instancia = BaseLocal._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('plannit.db');
    } else {
      final carpeta = await getApplicationDocumentsDirectory();
      _db = await databaseFactoryIo.openDatabase(p.join(carpeta.path, 'plannit.db'));
    }
    return _db!;
  }
}
