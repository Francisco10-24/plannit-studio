enum Rol { cliente, decorador }

// Datos de la cuenta (documento usuarios/{uid} en Firestore)
class Usuario {
  const Usuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.rol,
    this.decorador,
  });

  final String uid;
  final String nombre;
  final String correo;
  final String telefono;
  final Rol rol;

  // Si es decorador: nombre del negocio al que llegan sus solicitudes
  final String? decorador;

  bool get esDecorador => rol == Rol.decorador;

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'rol': rol.name,
        'decorador': decorador,
      };

  factory Usuario.fromMap(String uid, Map<String, dynamic> map) => Usuario(
        uid: uid,
        nombre: map['nombre'] as String,
        correo: map['correo'] as String,
        telefono: (map['telefono'] as String?) ?? '',
        rol: Rol.values.byName((map['rol'] as String?) ?? 'cliente'),
        decorador: map['decorador'] as String?,
      );
}
