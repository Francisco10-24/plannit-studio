import 'package:flutter/foundation.dart';

// Pestaña activa de la barra inferior. Permite que cualquier pantalla
// cambie de pestaña (por ejemplo "Ver carrito" desde el detalle de un paquete).
class NavegacionModel extends ChangeNotifier {
  static const int inicio = 0;
  static const int explorar = 1;
  static const int carrito = 2;
  static const int perfil = 3;

  int _pestana = inicio;

  int get pestana => _pestana;

  void ir(int pestana) {
    _pestana = pestana;
    notifyListeners();
  }
}
