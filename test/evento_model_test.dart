import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/catalogo.dart';
import 'package:plannit_studio/models/extra.dart';
import 'package:plannit_studio/models/paquete.dart';
import 'package:plannit_studio/state/evento_model.dart';

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

void main() {
  final catalogo = Catalogo(
    paquetes: [paquete(1, 285), paquete(2, 340)],
    extras: const [
      Extra(id: 1, nombre: 'Arco', detalle: '', precio: 95, imagen: ''),
      Extra(id: 2, nombre: 'Letras LED', detalle: '', precio: 60, imagen: ''),
      Extra(id: 3, nombre: 'Centros', detalle: '', precio: 120, imagen: ''),
    ],
    decoradores: const [],
  );

  test('sin paquete elegido el total es 0', () {
    final modelo = EventoModel();
    expect(modelo.total, 0);
  });

  test('total = paquete + extras activos + montaje (calculado, no guardado)', () {
    final modelo = EventoModel()..guardarCatalogo(catalogo, DateTime(2026));
    modelo.elegirPaquete(catalogo.paquetes.first);
    // Por defecto quedan activos el arco (95) y las letras LED (60)
    expect(modelo.subtotalExtras, 155);
    expect(modelo.total, 285 + 155 + EventoModel.costoMontaje);

    modelo.alternarExtra(3); // +120
    expect(modelo.total, 285 + 275 + EventoModel.costoMontaje);

    modelo.alternarExtra(1); // -95
    expect(modelo.subtotalExtras, 180);
  });

  test('un evento solo admite un paquete: elegir otro reemplaza al anterior', () {
    final modelo = EventoModel()..guardarCatalogo(catalogo, DateTime(2026));
    modelo.elegirPaquete(catalogo.paquetes[0]);
    modelo.elegirPaquete(catalogo.paquetes[1]);
    expect(modelo.paqueteElegido!.id, 2);
  });

  test('estado de la solicitud avanza de enviada a en revisión', () {
    final modelo = EventoModel()..elegirPaquete(paquete(1, 285));
    expect(modelo.estado, EstadoSolicitud.ninguna);
    modelo.marcarEnviada(101, 'POST /posts · 201 Created · 300 ms');
    expect(modelo.estado, EstadoSolicitud.enviada);
    modelo.avanzarEstado();
    expect(modelo.estado, EstadoSolicitud.enRevision);
  });

  test('guarda el último catálogo con su fecha para el modo sin conexión', () {
    final fecha = DateTime(2026, 10, 3, 20, 14);
    final modelo = EventoModel()..guardarCatalogo(catalogo, fecha);
    expect(modelo.ultimoCatalogo, isNotNull);
    expect(modelo.consultadoEn, fecha);
  });
}
