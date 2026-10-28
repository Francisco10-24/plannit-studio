import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/state/sesion_model.dart';

Usuario andrea() => const Usuario(
      nombre: 'Andrea Menjívar',
      correo: 'andrea.m@gmail.com',
      telefono: '7845-2190',
      esDecorador: false,
      password: 'Plannit26',
    );

void main() {
  test('registrar inicia sesión con el nuevo usuario', () {
    final sesion = SesionModel();
    expect(sesion.registrar(andrea()), isNull);
    expect(sesion.usuario!.nombre, 'Andrea Menjívar');
  });

  test('no permite dos cuentas con el mismo correo', () {
    final sesion = SesionModel()..registrar(andrea());
    sesion.cerrarSesion();
    expect(sesion.registrar(andrea()), 'Ya existe una cuenta con ese correo');
  });

  test('iniciar sesión valida correo y contraseña', () {
    final sesion = SesionModel()..registrar(andrea());
    sesion.cerrarSesion();
    expect(sesion.iniciarSesion('otro@gmail.com', 'Plannit26'), 'No encontramos una cuenta con ese correo');
    expect(sesion.iniciarSesion('andrea.m@gmail.com', 'mala'), 'Contraseña incorrecta');
    expect(sesion.usuario, isNull);
    expect(sesion.iniciarSesion('ANDREA.M@gmail.com', 'Plannit26'), isNull); // correo sin importar mayúsculas
    expect(sesion.usuario, isNotNull);
  });

  test('existe una cuenta de prueba para la demo', () {
    final sesion = SesionModel();
    expect(sesion.iniciarSesion(SesionModel.correoDemo, SesionModel.passwordDemo), isNull);
  });

  test('favoritos se agregan y se quitan', () {
    final sesion = SesionModel();
    sesion.alternarFavorito(3);
    expect(sesion.esFavorito(3), isTrue);
    expect(sesion.favoritos, {3});
    sesion.alternarFavorito(3);
    expect(sesion.esFavorito(3), isFalse);
  });
}
