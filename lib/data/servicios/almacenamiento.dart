import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences (clase 25): pares clave-valor NO cifrados.
// Solo datos no sensibles: preferencias de interfaz y banderas.
class Preferencias {
  Preferencias(this._prefs);

  final SharedPreferences _prefs;

  // Toda la API es asíncrona: se carga una vez al iniciar la app
  static Future<Preferencias> cargar() async => Preferencias(await SharedPreferences.getInstance());

  static const _categoria = 'ultima_categoria';
  static const _favoritos = 'favoritos';
  static const _bienvenida = 'bienvenida_vista';

  String? get ultimaCategoria => _prefs.getString(_categoria);
  Future<void> guardarCategoria(String categoria) => _prefs.setString(_categoria, categoria);

  // Solo admite tipos primitivos: los ids se guardan como List<String>
  Set<int> get favoritos => (_prefs.getStringList(_favoritos) ?? const []).map(int.parse).toSet();
  Future<void> guardarFavoritos(Set<int> ids) =>
      _prefs.setStringList(_favoritos, ids.map((id) => '$id').toList());

  bool get bienvenidaVista => _prefs.getBool(_bienvenida) ?? false;
  Future<void> marcarBienvenidaVista() => _prefs.setBool(_bienvenida, true);
}

// flutter_secure_storage (clase 25): almacenamiento CIFRADO
// (Keystore en Android, Keychain en iOS). Para datos de la cuenta.
abstract class AlmacenSeguro {
  Future<void> guardar(String clave, String valor);

  // String? : puede que todavía no haya nada guardado
  Future<String?> leer(String clave);

  Future<void> borrar(String clave);
}

class AlmacenSeguroDispositivo implements AlmacenSeguro {
  const AlmacenSeguroDispositivo();

  static const _almacen = FlutterSecureStorage();

  @override
  Future<void> guardar(String clave, String valor) => _almacen.write(key: clave, value: valor);

  @override
  Future<String?> leer(String clave) => _almacen.read(key: clave);

  @override
  Future<void> borrar(String clave) => _almacen.delete(key: clave);
}
