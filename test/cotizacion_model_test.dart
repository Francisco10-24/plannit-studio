import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/catalogo.dart';
import 'package:plannit_studio/state/cotizacion_model.dart';

void main() {
  const catalogo = Catalogo(paquetes: [], extras: [], decoradores: []);

  test('sin cotización no hay filtros activos', () {
    final modelo = CotizacionModel();
    expect(modelo.tieneCotizacion, isFalse);
  });

  test('guardar la cotización la deja disponible y crea una búsqueda reciente', () {
    final modelo = CotizacionModel()
      ..guardarEvento(
        tipo: 'Bodas',
        estiloElegido: 'Boho',
        fechaEvento: DateTime(2026, 12, 12),
        inicio: 960,
        espacio: 40,
        minimo: 150,
        maximo: 450,
      );
    expect(modelo.tieneCotizacion, isTrue);
    expect(modelo.tipoEvento, 'Bodas');
    expect(modelo.recientes.single.estilo, 'Boho');

    modelo.limpiarCotizacion();
    expect(modelo.tieneCotizacion, isFalse);
    expect(modelo.recientes.length, 1); // el historial se conserva
  });

  test('guarda el último catálogo con su fecha para el modo sin conexión', () {
    final fecha = DateTime(2026, 10, 3, 20, 14);
    final modelo = CotizacionModel()..guardarCatalogo(catalogo, fecha);
    expect(modelo.ultimoCatalogo, isNotNull);
    expect(modelo.consultadoEn, fecha);
  });
}
