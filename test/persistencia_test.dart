import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/data/fuentes/carrito_local.dart';
import 'package:plannit_studio/data/fuentes/catalogo_local.dart';
import 'package:plannit_studio/data/repositorios/catalogo_repository.dart';
import 'package:plannit_studio/models/catalogo.dart';
import 'package:plannit_studio/state/carrito_model.dart';
import 'package:sembast/sembast_memory.dart';

import 'fakes.dart';

void main() {
  // Cada prueba usa una base Sembast nueva en memoria (no toca el teléfono)
  late Database db;
  var contador = 0;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('prueba${contador++}.db');
  });

  final catalogo = Catalogo(paquetes: [paqueteDePrueba(1, 285)], extras: const [], decoradores: const []);

  test('con internet: trae del servidor y lo guarda en la base local', () async {
    final remota = FakeCatalogoRemoto(catalogo);
    final repo = CatalogoRepository(remota: remota, local: CatalogoLocal(() async => db));

    final resultado = await repo.obtener();
    expect(resultado.desdeCache, isFalse);
    expect(resultado.catalogo.paquetes.single.nombre, 'Paquete 1');
    expect(await CatalogoLocal(() async => db).leer(), isNotNull);
  });

  test('sin internet: usa lo guardado y avisa la fecha de la consulta', () async {
    final remota = FakeCatalogoRemoto(catalogo);
    final repo = CatalogoRepository(remota: remota, local: CatalogoLocal(() async => db));
    final primera = await repo.obtener();

    remota.sinConexion = true;
    final segunda = await repo.obtener();
    expect(segunda.desdeCache, isTrue);
    expect(segunda.actualizadoEn, primera.actualizadoEn);
    expect(segunda.catalogo.paquetes.single.precio, 285);
  });

  test('sin internet y sin nada guardado: el error llega a la pantalla', () async {
    final remota = FakeCatalogoRemoto(catalogo)..sinConexion = true;
    final repo = CatalogoRepository(remota: remota, local: CatalogoLocal(() async => db));
    expect(repo.obtener(), throwsA(anything));
  });

  test('el carrito sobrevive a cerrar y abrir la app', () async {
    final local = CarritoLocal(() async => db);
    final antes = CarritoModel(local: local);
    final evento = antes.agregar(
      nombre: 'Cumple de Andrea',
      tipo: 'Cumpleaños',
      fecha: DateTime(2026, 12, 12),
      hora: 960,
      paquete: paqueteDePrueba(1, 285),
    );
    antes.alternarExtra(evento.id, 4);
    await local.guardarTodo(antes.eventos.toList()); // espera la escritura

    // "Reabrir": un modelo nuevo que lee de la misma base
    final despues = CarritoModel(local: local);
    await despues.cargar();
    expect(despues.cantidad, 1);
    expect(despues.eventos.single.nombre, 'Cumple de Andrea');
    expect(despues.eventos.single.extras, {4});

    // El id siguiente no choca con el evento recuperado
    final nuevo = despues.agregar(
      nombre: 'Otro',
      tipo: 'Bodas',
      fecha: DateTime(2026, 12, 20),
      hora: 960,
      paquete: paqueteDePrueba(2, 340),
    );
    expect(nuevo.id, isNot(evento.id));
  });
}
