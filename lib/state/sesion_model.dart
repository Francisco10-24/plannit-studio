import 'package:flutter/foundation.dart';

class Usuario {
  const Usuario({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.esDecorador,
    required this.password,
  });

  final String nombre;
  final String correo;
  final String telefono;
  final bool esDecorador;
  final String password;
}

// Cuenta del usuario y sus favoritos (sin backend: vive mientras la app está abierta)
class SesionModel extends ChangeNotifier {
  // Cuenta de prueba para la demo
  static const correoDemo = 'andrea@plannit.sv';
  static const passwordDemo = 'Plannit26';

  final List<Usuario> _cuentas = [
    const Usuario(
      nombre: 'Andrea Menjívar',
      correo: correoDemo,
      telefono: '7845-2190',
      esDecorador: false,
      password: passwordDemo,
    ),
  ];
  final Set<int> _favoritos = {};
  Usuario? _usuario;

  Usuario? get usuario => _usuario;
  bool get conSesion => _usuario != null;
  Set<int> get favoritos => Set.unmodifiable(_favoritos);
  bool esFavorito(int paqueteId) => _favoritos.contains(paqueteId);

  Usuario? _buscar(String correo) {
    final clave = correo.trim().toLowerCase();
    for (final cuenta in _cuentas) {
      if (cuenta.correo.toLowerCase() == clave) return cuenta;
    }
    return null;
  }

  // Devuelve un mensaje de error o null si se creó la cuenta
  String? registrar(Usuario nuevo) {
    if (_buscar(nuevo.correo) != null) return 'Ya existe una cuenta con ese correo';
    _cuentas.add(nuevo);
    _usuario = nuevo;
    notifyListeners();
    return null;
  }

  // Devuelve un mensaje de error o null si inició sesión
  String? iniciarSesion(String correo, String password) {
    final cuenta = _buscar(correo);
    if (cuenta == null) return 'No encontramos una cuenta con ese correo';
    if (cuenta.password != password) return 'Contraseña incorrecta';
    _usuario = cuenta;
    notifyListeners();
    return null;
  }

  void cerrarSesion() {
    _usuario = null;
    notifyListeners();
  }

  void alternarFavorito(int paqueteId) {
    if (!_favoritos.remove(paqueteId)) _favoritos.add(paqueteId);
    notifyListeners();
  }
}
