import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/models/paquete.dart';
import 'package:plannit_studio/utils/filtros.dart';

Paquete p(int id, String nombre, String estilo, List<String> eventos, double precio, double rating,
        {String decorador = 'Deco Studio Luna'}) =>
    Paquete(
      id: id,
      nombre: nombre,
      decorador: decorador,
      zona: 'Santa Tecla',
      estilo: estilo,
      eventos: eventos,
      precio: precio,
      rating: rating,
      resenas: 10,
      colores: const [],
      incluye: '',
      etiqueta: '',
      imagen: '',
    );

void main() {
  final todos = [
    p(1, 'Glam Rosa y Dorado', 'Glam', ['Cumpleaños', 'Quince años'], 285, 4.8),
    p(2, 'Jardín Boho Pampa', 'Boho', ['Bodas'], 340, 4.9, decorador: 'Pampa Deco'),
    p(3, 'Fiesta Confeti', 'Temática', ['Infantil'], 160, 4.5),
  ];

  List<int> ids(List<Paquete> l) => l.map((x) => x.id).toList();

  test('sin filtros devuelve todo en el orden original', () {
    expect(ids(filtrarPaquetes(todos)), [1, 2, 3]);
  });

  test('busca por texto sin importar tildes ni mayúsculas', () {
    expect(ids(filtrarPaquetes(todos, texto: 'jardin')), [2]);
    expect(ids(filtrarPaquetes(todos, texto: 'PAMPA deco')), [2]);
  });

  test('filtra por estilo, tipo de evento y rango de precio', () {
    expect(ids(filtrarPaquetes(todos, estilo: 'Glam')), [1]);
    expect(ids(filtrarPaquetes(todos, tipo: 'Bodas')), [2]);
    expect(ids(filtrarPaquetes(todos, precioMin: 150, precioMax: 300)), [1, 3]);
    expect(ids(filtrarPaquetes(todos, decorador: 'Pampa Deco')), [2]);
  });

  test('ordena por precio y por calificación', () {
    expect(ids(filtrarPaquetes(todos, orden: Orden.precioMenor)), [3, 1, 2]);
    expect(ids(filtrarPaquetes(todos, orden: Orden.precioMayor)), [2, 1, 3]);
    expect(ids(filtrarPaquetes(todos, orden: Orden.mejorCalificados)), [2, 1, 3]);
  });
}
