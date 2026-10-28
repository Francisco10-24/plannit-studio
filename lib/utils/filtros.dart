import '../models/paquete.dart';

enum Orden { recomendados, precioMenor, precioMayor, mejorCalificados }

const Map<Orden, String> nombresOrden = {
  Orden.recomendados: 'Recomendados',
  Orden.precioMenor: 'Precio: menor a mayor',
  Orden.precioMayor: 'Precio: mayor a menor',
  Orden.mejorCalificados: 'Mejor calificados',
};

// "Jardín" -> "jardin": para buscar sin importar tildes ni mayúsculas
String normalizar(String texto) {
  const conTilde = 'áéíóúüñ';
  const sinTilde = 'aeiouun';
  var resultado = texto.toLowerCase().trim();
  for (var i = 0; i < conTilde.length; i++) {
    resultado = resultado.replaceAll(conTilde[i], sinTilde[i]);
  }
  return resultado;
}

// Aplica búsqueda, filtros y orden con where (no modifica la lista original)
List<Paquete> filtrarPaquetes(
  List<Paquete> todos, {
  String texto = '',
  String? estilo,
  String? tipo,
  String? decorador,
  double? precioMin,
  double? precioMax,
  Orden orden = Orden.recomendados,
}) {
  final buscado = normalizar(texto);
  final resultado = todos.where((p) {
    final contenido = normalizar('${p.nombre} ${p.decorador} ${p.zona} ${p.estilo}');
    return (buscado.isEmpty || contenido.contains(buscado)) &&
        (estilo == null || p.estilo == estilo) &&
        (tipo == null || p.eventos.contains(tipo)) &&
        (decorador == null || p.decorador == decorador) &&
        (precioMin == null || p.precio >= precioMin) &&
        (precioMax == null || p.precio <= precioMax);
  }).toList();

  switch (orden) {
    case Orden.recomendados:
      break;
    case Orden.precioMenor:
      resultado.sort((a, b) => a.precio.compareTo(b.precio));
    case Orden.precioMayor:
      resultado.sort((a, b) => b.precio.compareTo(a.precio));
    case Orden.mejorCalificados:
      resultado.sort((a, b) => b.rating.compareTo(a.rating));
  }
  return resultado;
}
