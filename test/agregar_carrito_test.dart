import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/paquete.dart';
import 'package:plannit_studio/screens/detalle_paquete_screen.dart';
import 'package:plannit_studio/state/carrito_model.dart';
import 'package:plannit_studio/state/cotizacion_model.dart';
import 'package:plannit_studio/state/navegacion_model.dart';
import 'package:plannit_studio/state/sesion_model.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

Paquete paquete(int id, String nombre) => Paquete(
      id: id,
      nombre: nombre,
      decorador: 'Deco Studio Luna',
      zona: 'Santa Tecla',
      estilo: 'Glam',
      eventos: const ['Cumpleaños'],
      precio: 285,
      rating: 4.8,
      resenas: 10,
      colores: const ['#9B1B30'],
      incluye: 'Arco',
      etiqueta: '',
      imagen: '',
    );

void main() {
  late CarritoModel carrito;
  late CotizacionModel cotizacion;

  Future<void> abrir(WidgetTester tester, Paquete p) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cotizacion),
          ChangeNotifierProvider.value(value: carrito),
          ChangeNotifierProvider(create: (_) => SesionModel(auth: FakeAuthService())),
          ChangeNotifierProvider(create: (_) => NavegacionModel()),
        ],
        child: MaterialApp(home: DetallePaqueteScreen(paquete: p)),
      ),
    );
  }

  setUp(() {
    carrito = CarritoModel();
    cotizacion = CotizacionModel();
  });

  testWidgets('sin fecha no deja agregar: muestra el error del formulario', (tester) async {
    await abrir(tester, paquete(1, 'Glam Rosa'));
    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Agregar ·'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona la fecha del evento'), findsOneWidget);
    expect(carrito.cantidad, 0);
  });

  testWidgets('con los datos de la cotización agrega el evento al carrito', (tester) async {
    cotizacion.guardarEvento(
      tipo: 'Cumpleaños',
      estiloElegido: 'Glam',
      fechaEvento: DateTime.now().add(const Duration(days: 30)),
      inicio: 960,
      espacio: 40,
      minimo: 100,
      maximo: 500,
    );
    await abrir(tester, paquete(1, 'Glam Rosa'));
    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Agregar ·'));
    await tester.pumpAndSettle();

    expect(carrito.cantidad, 1);
    expect(carrito.eventos.single.paquete.nombre, 'Glam Rosa');
    expect(find.text('Agregado a tu carrito'), findsOneWidget);
  });

  testWidgets('el mismo día no se duplica: pregunta y reemplaza el paquete', (tester) async {
    final fecha = DateTime.now().add(const Duration(days: 30));
    cotizacion.guardarEvento(
      tipo: 'Cumpleaños',
      estiloElegido: 'Glam',
      fechaEvento: fecha,
      inicio: 960,
      espacio: 40,
      minimo: 100,
      maximo: 500,
    );
    carrito.agregar(nombre: 'Cumple', tipo: 'Cumpleaños', fecha: fecha, hora: 960, paquete: paquete(1, 'Glam Rosa'));

    await abrir(tester, paquete(2, 'Fiesta Confeti'));
    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Agregar ·'));
    await tester.pumpAndSettle();

    expect(find.text('Ya tienes un evento ese día'), findsOneWidget);
    await tester.tap(find.text('Reemplazar'));
    await tester.pumpAndSettle();

    expect(carrito.cantidad, 1);
    expect(carrito.eventos.single.paquete.nombre, 'Fiesta Confeti');
  });
}
