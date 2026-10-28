import 'extra.dart';
import 'paquete.dart';

// Decorador local que aparece en "Decoradores cerca de ti"
class Decorador {
  const Decorador({
    required this.id,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.imagen,
    this.descripcion = '',
  });

  final int id;
  final String nombre;
  final String zona;
  final double rating;
  final String imagen;
  final String descripcion;

  factory Decorador.fromJson(Map<String, dynamic> json) {
    return Decorador(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      zona: json['zona'] as String,
      rating: (json['rating'] as num).toDouble(),
      imagen: json['imagen'] as String,
      descripcion: (json['descripcion'] as String?) ?? '',
    );
  }
}

// Todo lo que devuelve el GET del backend en una sola respuesta
class Catalogo {
  const Catalogo({
    required this.paquetes,
    required this.extras,
    required this.decoradores,
  });

  final List<Paquete> paquetes;
  final List<Extra> extras;
  final List<Decorador> decoradores;

  factory Catalogo.fromJson(Map<String, dynamic> json) {
    return Catalogo(
      paquetes: (json['paquetes'] as List)
          .map((p) => Paquete.fromJson(p as Map<String, dynamic>))
          .toList(),
      extras: (json['extras'] as List)
          .map((e) => Extra.fromJson(e as Map<String, dynamic>))
          .toList(),
      decoradores: (json['decoradores'] as List)
          .map((d) => Decorador.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
