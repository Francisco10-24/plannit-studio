import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/usuario.dart';
import 'package:plannit_studio/state/sesion_model.dart';

import 'fakes.dart';

void main() {
  late FakeAuthService auth;
  late AlmacenEnMemoria almacen;
  late SesionModel sesion;

  setUp(() {
    auth = FakeAuthService();
    almacen = AlmacenEnMemoria();
    sesion = SesionModel(auth: auth, almacen: almacen);
  });

  Future<String?> registrarAndrea() => sesion.registrar(
        nombre: 'Andrea Menjívar',
        correo: 'andrea.m@gmail.com',
        telefono: '7845-2190',
        password: 'Plannit26',
        rol: Rol.cliente,
      );

  test('registrar inicia sesión y guarda el correo en el almacén seguro', () async {
    expect(await registrarAndrea(), isNull);
    expect(sesion.usuario!.nombre, 'Andrea Menjívar');
    expect(await sesion.ultimoCorreo(), 'andrea.m@gmail.com');
  });

  test('no permite dos cuentas con el mismo correo', () async {
    await registrarAndrea();
    await sesion.cerrarSesion();
    expect(await registrarAndrea(), 'Ya existe una cuenta con ese correo');
  });

  test('iniciar sesión con contraseña incorrecta devuelve el mensaje de error', () async {
    await registrarAndrea();
    await sesion.cerrarSesion();
    expect(await sesion.iniciarSesion('andrea.m@gmail.com', 'mala'), 'Correo o contraseña incorrectos');
    expect(sesion.usuario, isNull);
    expect(await sesion.iniciarSesion('andrea.m@gmail.com', 'Plannit26'), isNull);
    expect(sesion.conSesion, isTrue);
  });

  test('una cuenta de decorador guarda su negocio', () async {
    await sesion.registrar(
      nombre: 'Luna',
      correo: 'luna@deco.sv',
      telefono: '2222-3333',
      password: 'Plannit26',
      rol: Rol.decorador,
      decorador: 'Deco Studio Luna',
    );
    expect(sesion.usuario!.esDecorador, isTrue);
    expect(sesion.usuario!.decorador, 'Deco Studio Luna');
  });

  test('favoritos se agregan y se quitan', () {
    sesion.alternarFavorito(3);
    expect(sesion.esFavorito(3), isTrue);
    sesion.alternarFavorito(3);
    expect(sesion.esFavorito(3), isFalse);
  });
}
