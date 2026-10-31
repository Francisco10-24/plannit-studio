import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/servicios/almacenamiento.dart';
import '../data/servicios/auth_service.dart';
import '../models/usuario.dart';

// Cuenta del usuario (Firebase Auth) y sus favoritos (SharedPreferences)
class SesionModel extends ChangeNotifier {
  SesionModel({required this.auth, this.preferencias, this.almacen}) {
    _favoritos.addAll(preferencias?.favoritos ?? const {});
    // Firebase recuerda la sesión: al reabrir la app el usuario sigue dentro
    _suscripcion = auth.cambios().listen((usuario) {
      _usuario = usuario;
      _revisada = true;
      notifyListeners();
    });
  }

  static const _claveCorreo = 'ultimo_correo';

  final AuthService auth;
  final Preferencias? preferencias;
  final AlmacenSeguro? almacen;
  late final StreamSubscription<Usuario?> _suscripcion;

  final Set<int> _favoritos = {};
  Usuario? _usuario;
  bool _revisada = false;

  Usuario? get usuario => _usuario;
  bool get conSesion => _usuario != null;

  // false mientras Firebase todavía no responde si hay sesión guardada
  bool get sesionRevisada => _revisada;

  Set<int> get favoritos => Set.unmodifiable(_favoritos);
  bool esFavorito(int paqueteId) => _favoritos.contains(paqueteId);

  // Devuelve un mensaje de error o null si se creó la cuenta
  Future<String?> registrar({
    required String nombre,
    required String correo,
    required String telefono,
    required String password,
    required Rol rol,
    String? decorador,
  }) async {
    try {
      _usuario = await auth.registrar(
        nombre: nombre,
        correo: correo.trim(),
        telefono: telefono,
        password: password,
        rol: rol,
        decorador: decorador,
      );
      await almacen?.guardar(_claveCorreo, correo.trim());
      notifyListeners();
      return null;
    } on ErrorCuenta catch (e) {
      return e.mensaje;
    }
  }

  // Devuelve un mensaje de error o null si inició sesión
  Future<String?> iniciarSesion(String correo, String password) async {
    try {
      _usuario = await auth.iniciarSesion(correo.trim(), password);
      await almacen?.guardar(_claveCorreo, correo.trim());
      notifyListeners();
      return null;
    } on ErrorCuenta catch (e) {
      return e.mensaje;
    }
  }

  // Correo del último inicio de sesión (guardado cifrado), para rellenar el login
  Future<String?> ultimoCorreo() async => almacen?.leer(_claveCorreo);

  Future<void> cerrarSesion() async {
    await auth.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  void alternarFavorito(int paqueteId) {
    if (!_favoritos.remove(paqueteId)) _favoritos.add(paqueteId);
    notifyListeners();
    final prefs = preferencias;
    if (prefs != null) unawaited(prefs.guardarFavoritos(_favoritos));
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
