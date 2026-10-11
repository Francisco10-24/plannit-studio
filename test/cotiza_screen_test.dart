import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/screens/cotiza_screen.dart';
import 'package:plannit_studio/state/evento_model.dart';
import 'package:plannit_studio/widgets/campo_texto.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('cada error cruzado aparece debajo de su propio campo', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => EventoModel(),
        child: const MaterialApp(home: CotizaScreen()),
      ),
    );

    await tester.enterText(find.widgetWithText(CampoTexto, 'TAMAÑO DEL ESPACIO (M²)'), '18');
    await tester.tap(find.byType(Switch));
    await tester.enterText(find.widgetWithText(CampoTexto, 'PRESUPUESTO MÍNIMO'), '450');
    await tester.enterText(find.widgetWithText(CampoTexto, 'PRESUPUESTO MÁXIMO'), '300');
    await tester.tap(find.text('Ver paquetes'));
    await tester.pumpAndSettle();

    CampoTexto campoDe(String error) => tester.widget<CampoTexto>(
          find.ancestor(of: find.text(error), matching: find.byType(CampoTexto)),
        );

    expect(campoDe('El arco XL necesita mínimo 30 m²').etiqueta, 'Tamaño del espacio (m²)');
    expect(campoDe('El máximo no puede ser menor que el mínimo').etiqueta, 'Presupuesto máximo');
    expect(campoDe('Selecciona la fecha del evento').etiqueta, 'Fecha del evento');
  });
}
