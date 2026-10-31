import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/solicitud.dart';
import 'package:plannit_studio/models/usuario.dart';
import 'package:plannit_studio/state/carrito_model.dart';
import 'package:plannit_studio/state/solicitudes_model.dart';

import 'fakes.dart';

const cliente = Usuario(
  uid: 'cliente1',
  nombre: 'Andrea',
  correo: 'andrea@prueba.sv',
  telefono: '7845-2190',
  rol: Rol.cliente,
);

const decorador = Usuario(
  uid: 'deco1',
  nombre: 'Luna',
  correo: 'luna@prueba.sv',
  telefono: '2222-3333',
  rol: Rol.decorador,
  decorador: 'Deco Studio Luna',
);

void main() {
  late FakeSolicitudes repo;
  late SolicitudesModel solicitudes;
  late CarritoModel carrito;

  setUp(() {
    repo = FakeSolicitudes();
    solicitudes = SolicitudesModel(repo);
    carrito = CarritoModel();
  });

  test('enviar el carrito crea una solicitud por evento y vacía el carrito', () async {
    carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: DateTime(2026, 12, 12), hora: 960, paquete: paqueteDePrueba(1, 285));
    carrito.agregar(nombre: 'B', tipo: 'Bodas', fecha: DateTime(2026, 12, 13), hora: 960, paquete: paqueteDePrueba(2, 340));

    final enviadas = await solicitudes.enviarCarrito(carrito, cliente);

    expect(enviadas, 2);
    expect(carrito.cantidad, 0);
    expect(repo.guardadas.map((s) => s.total), [310, 365]);
    expect(repo.guardadas.first.estado, EstadoSolicitud.enviada);
    expect(solicitudes.noLeidas, 2);
  });

  test('si falla el envío, los eventos se quedan en el carrito', () async {
    repo.fallarAlEnviar = true;
    carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: DateTime(2026, 12, 12), hora: 960, paquete: paqueteDePrueba(1, 285));
    await expectLater(solicitudes.enviarCarrito(carrito, cliente), throwsA(anything));
    expect(carrito.cantidad, 1);
  });

  test('el decorador ve la solicitud y al aprobarla el cliente recibe el aviso', () async {
    // Cliente y decorador escuchan el mismo repositorio, como en Firestore
    final panel = SolicitudesModel(repo)..escucharUsuario(decorador);
    solicitudes.escucharUsuario(cliente);

    carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: DateTime(2026, 12, 12), hora: 960, paquete: paqueteDePrueba(1, 285));
    await solicitudes.enviarCarrito(carrito, cliente);
    await pumpEventQueue();
    expect(panel.recibidas.single.evento, 'A');
    expect(panel.pendientes, 1);

    solicitudes.marcarLeidas();
    await panel.cambiarEstado(panel.recibidas.single, EstadoSolicitud.enRevision);
    await pumpEventQueue();
    await panel.cambiarEstado(panel.recibidas.single, EstadoSolicitud.aprobada);
    await pumpEventQueue();

    expect(solicitudes.mias.single.estado, EstadoSolicitud.aprobada);
    expect(solicitudes.notificaciones.map((n) => n.titulo).take(2), ['Solicitud aprobada', 'En revisión']);
    expect(solicitudes.noLeidas, 2);
    expect(panel.pendientes, 0);
  });
}
