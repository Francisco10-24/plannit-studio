import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/data/servicios/monitoreo.dart';

void main() {
  test('nombres de eventos de Analytics que usa la app son válidos', () {
    for (final nombre in ['ver_paquete', 'agregar_al_carrito', 'enviar_solicitud', 'cambiar_estado_solicitud']) {
      expect(nombreEventoValido(nombre), isTrue, reason: nombre);
    }
  });

  test('rechaza mayúsculas, espacios, prefijos reservados y más de 40 caracteres', () {
    expect(nombreEventoValido('AgregarCarrito'), isFalse);
    expect(nombreEventoValido('agregar carrito'), isFalse);
    expect(nombreEventoValido('firebase_compra'), isFalse);
    expect(nombreEventoValido('ga_compra'), isFalse);
    expect(nombreEventoValido('a' * 41), isFalse);
  });
}
