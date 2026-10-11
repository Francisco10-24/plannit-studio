import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/catalogo.dart';
import 'package:plannit_studio/models/paquete.dart';

void main() {
  final json = {
    'id': 1,
    'nombre': 'Glam Rosa y Dorado',
    'decorador': 'Deco Studio Luna',
    'zona': 'Santa Tecla',
    'estilo': 'Glam',
    'eventos': ['Cumpleaños', 'Quince años'],
    'precio': 285, // entero en el JSON, debe llegar como double
    'rating': 4.8,
    'resenas': 126,
    'colores': ['#F2B8C6', '#D4A64A'],
    'incluye': 'Arco de globos + mesa principal',
    'etiqueta': 'Favorito de clientes',
    'imagen': 'https://images.unsplash.com/x',
  };

  test('Paquete.fromJson convierte el Map en objeto Dart', () {
    final p = Paquete.fromJson(json);
    expect(p.nombre, 'Glam Rosa y Dorado');
    expect(p.precio, 285.0);
    expect(p.eventos, contains('Quince años'));
    expect(p.colores.length, 2);
  });

  test('toJson hace el camino inverso', () {
    expect(Paquete.fromJson(json).toJson()['nombre'], 'Glam Rosa y Dorado');
  });

  test('Catalogo.fromJson lee paquetes, extras y decoradores', () {
    final c = Catalogo.fromJson({
      'paquetes': [json],
      'extras': [
        {'id': 1, 'nombre': 'Arco', 'detalle': 'x', 'precio': 95, 'imagen': ''}
      ],
      'decoradores': [
        {'id': 1, 'nombre': 'Luna', 'zona': 'Santa Tecla', 'rating': 4.9, 'imagen': ''}
      ],
    });
    expect(c.paquetes.single.id, 1);
    expect(c.extras.single.precio, 95.0);
    expect(c.decoradores.single.nombre, 'Luna');
  });
}
