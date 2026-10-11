// Paquete de decoración que ofrece un decorador
class Paquete {
  const Paquete({
    required this.id,
    required this.nombre,
    required this.decorador,
    required this.zona,
    required this.estilo,
    required this.eventos,
    required this.precio,
    required this.rating,
    required this.resenas,
    required this.colores,
    required this.incluye,
    required this.etiqueta,
    required this.imagen,
  });

  final int id;
  final String nombre;
  final String decorador;
  final String zona;
  final String estilo;
  final List<String> eventos;
  final double precio;
  final double rating;
  final int resenas;
  final List<String> colores;
  final String incluye;
  final String etiqueta;
  final String imagen;

  // Construye un Paquete desde el Map que devuelve el JSON
  factory Paquete.fromJson(Map<String, dynamic> json) {
    return Paquete(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      decorador: json['decorador'] as String,
      zona: json['zona'] as String,
      estilo: json['estilo'] as String,
      eventos: List<String>.from(json['eventos'] as List),
      precio: (json['precio'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      resenas: json['resenas'] as int,
      colores: List<String>.from(json['colores'] as List),
      incluye: json['incluye'] as String,
      etiqueta: (json['etiqueta'] as String?) ?? '',
      imagen: json['imagen'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'decorador': decorador,
        'zona': zona,
        'estilo': estilo,
        'eventos': eventos,
        'precio': precio,
        'rating': rating,
        'resenas': resenas,
        'colores': colores,
        'incluye': incluye,
        'etiqueta': etiqueta,
        'imagen': imagen,
      };
}
