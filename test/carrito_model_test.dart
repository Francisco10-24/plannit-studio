import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/extra.dart';
import 'package:plannit_studio/models/paquete.dart';
import 'package:plannit_studio/models/solicitud.dart';
import 'package:plannit_studio/state/carrito_model.dart';

Paquete paquete(int id, double precio) => Paquete(
      id: id,
      nombre: 'Paquete $id',
      decorador: 'Deco Studio Luna',
      zona: 'Santa Tecla',
      estilo: 'Glam',
      eventos: const ['Cumpleaños'],
      precio: precio,
      rating: 4.8,
      resenas: 10,
      colores: const ['#9B1B30'],
      incluye: 'Arco',
      etiqueta: '',
      imagen: '',
    );

const extras = [
  Extra(id: 1, nombre: 'Arco', detalle: '', precio: 95, imagen: ''),
  Extra(id: 2, nombre: 'Letras LED', detalle: '', precio: 60, imagen: ''),
];

final sabado = DateTime(2026, 12, 12);
final domingo = DateTime(2026, 12, 13);

CarritoModel carritoConExtras() => CarritoModel()..cargarExtras(extras);

void main() {
  test('el carrito empieza vacío y con total 0', () {
    final carrito = carritoConExtras();
    expect(carrito.cantidad, 0);
    expect(carrito.total, 0);
  });

  test('agregar crea un evento con su paquete', () {
    final carrito = carritoConExtras();
    carrito.agregar(nombre: 'Cumple de Andrea', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    expect(carrito.cantidad, 1);
    expect(carrito.eventos.first.paquete.id, 1);
    expect(carrito.eventos.first.nombre, 'Cumple de Andrea');
  });

  test('el total suma todos los eventos con fold: paquete + extras + montaje', () {
    final carrito = carritoConExtras();
    final a = carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    carrito.agregar(nombre: 'B', tipo: 'Bodas', fecha: domingo, hora: 960, paquete: paquete(2, 340));
    carrito.alternarExtra(a.id, 1); // +95 solo al evento A

    expect(carrito.totalEvento(a), 285 + 95 + CarritoModel.costoMontaje);
    expect(carrito.total, (285 + 95 + 25) + (340 + 25));
  });

  test('los extras son independientes por evento', () {
    final carrito = carritoConExtras();
    final a = carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 100));
    final b = carrito.agregar(nombre: 'B', tipo: 'Bodas', fecha: domingo, hora: 960, paquete: paquete(2, 100));
    carrito.alternarExtra(a.id, 2);
    expect(carrito.subtotalExtras(a), 60);
    expect(carrito.subtotalExtras(b), 0);
    carrito.alternarExtra(a.id, 2); // apagar
    expect(carrito.subtotalExtras(a), 0);
  });

  test('detecta otro evento el mismo día (un evento = un paquete)', () {
    final carrito = carritoConExtras();
    carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    expect(carrito.eventoEnFecha(DateTime(2026, 12, 12, 20, 30)), isNotNull);
    expect(carrito.eventoEnFecha(domingo), isNull);
  });

  test('reemplazar el paquete deja un solo paquete en el evento', () {
    final carrito = carritoConExtras();
    final a = carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    carrito.reemplazarPaquete(a.id, paquete(2, 340));
    expect(carrito.cantidad, 1);
    expect(carrito.eventos.single.paquete.id, 2);
  });

  test('quitar elimina el evento del carrito', () {
    final carrito = carritoConExtras();
    final a = carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    carrito.quitar(a.id);
    expect(carrito.cantidad, 0);
  });

  test('al enviar, el evento pasa a Mis solicitudes y llega una notificación', () {
    final carrito = carritoConExtras();
    final a = carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    carrito.registrarEnviado(a, 20481);

    expect(carrito.cantidad, 0);
    expect(carrito.solicitudes.single.numero, 20481);
    expect(carrito.solicitudes.single.estado, EstadoSolicitud.enviada);
    expect(carrito.solicitudes.single.total, 285 + 25);
    expect(carrito.noLeidas, 1);
  });

  test('la solicitud avanza: enviada, en revisión, aprobada', () {
    final carrito = carritoConExtras();
    final a = carrito.agregar(nombre: 'A', tipo: 'Cumpleaños', fecha: sabado, hora: 960, paquete: paquete(1, 285));
    carrito.registrarEnviado(a, 1);
    carrito.avanzarSolicitud(1);
    expect(carrito.solicitudes.single.estado, EstadoSolicitud.enRevision);
    carrito.avanzarSolicitud(1);
    expect(carrito.solicitudes.single.estado, EstadoSolicitud.aprobada);
    carrito.avanzarSolicitud(1); // ya no avanza más
    expect(carrito.solicitudes.single.estado, EstadoSolicitud.aprobada);
    expect(carrito.notificaciones.length, 3);
    carrito.marcarLeidas();
    expect(carrito.noLeidas, 0);
  });
}
