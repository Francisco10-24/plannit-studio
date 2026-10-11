// Servicio adicional que se puede sumar al paquete (arco, letras LED...)
class Extra {
  const Extra({
    required this.id,
    required this.nombre,
    required this.detalle,
    required this.precio,
    required this.imagen,
  });

  final int id;
  final String nombre;
  final String detalle;
  final double precio;
  final String imagen;

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      detalle: json['detalle'] as String,
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'detalle': detalle,
        'precio': precio,
        'imagen': imagen,
      };
}
