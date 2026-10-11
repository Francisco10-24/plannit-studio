import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/utils/validadores.dart';

void main() {
  group('Validación de formularios (Crea tu cuenta)', () {
    test('nombre obligatorio y de al menos 3 caracteres', () {
      expect(validarNombre(''), isNotNull);
      expect(validarNombre('An'), isNotNull);
      expect(validarNombre('Andrea Menjívar'), isNull);
    });

    test('correo con formato válido', () {
      expect(validarCorreo('andrea.menjivar@gmail'), isNotNull);
      expect(validarCorreo('andrea.menjivar@gmail.com'), isNull);
    });

    test('teléfono de 8 dígitos', () {
      expect(validarTelefono('7845-21'), 'El teléfono debe tener 8 dígitos');
      expect(validarTelefono('7845-2190'), isNull);
    });

    test('contraseña: 8 caracteres, 1 número y 1 mayúscula', () {
      expect(validarPassword('Plannitt'), isNotNull); // sin número
      expect(validarPassword('plannit26'), isNotNull); // sin mayúscula
      expect(validarPassword('Plan26'), isNotNull); // muy corta
      expect(validarPassword('Plannit26'), isNull);
      final reglas = reglasPassword('Plannitt');
      expect(reglas.largo, isTrue);
      expect(reglas.numero, isFalse);
      expect(reglas.mayuscula, isTrue);
    });
  });

  group('Validación cruzada (Cotiza tu deco)', () {
    const cuatroPm = 16 * 60;
    const tresPm = 15 * 60;
    const dosPm = 14 * 60;

    test('el montaje debe terminar al menos 2 h antes del evento', () {
      expect(validarMontaje(tresPm, cuatroPm),
          'El montaje debe terminar al menos 2 h antes del evento');
      expect(validarMontaje(dosPm, cuatroPm), isNull);
      expect(validarMontaje(null, cuatroPm), isNotNull);
    });

    test('el arco XL necesita mínimo 30 m²', () {
      expect(validarEspacio('18', true), 'El arco XL necesita mínimo 30 m²');
      expect(validarEspacio('18', false), isNull);
      expect(validarEspacio('35', true), isNull);
      expect(validarEspacio('abc', false), isNotNull); // nunca "?? 0"
    });

    test('el presupuesto máximo no puede ser menor que el mínimo', () {
      expect(validarPresupuestoMax('300', '450'),
          'El máximo no puede ser menor que el mínimo');
      expect(validarPresupuestoMax('450', '300'), isNull);
      expect(validarPresupuestoMax('', '300'), isNotNull);
      expect(validarPresupuestoMin('abc'), isNotNull);
    });

    test('la fecha no puede estar en el pasado', () {
      final hoy = DateTime(2026, 10, 11);
      expect(validarFecha(DateTime(2026, 10, 1), hoy), isNotNull);
      expect(validarFecha(DateTime(2026, 12, 12), hoy), isNull);
      expect(validarFecha(null, hoy), isNotNull);
    });
  });
}
