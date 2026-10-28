import 'paquete.dart';

enum EstadoSolicitud { enviada, enRevision, aprobada }

// Un evento dentro del carrito. Cada evento tiene UN solo paquete.
class EventoCarrito {
  EventoCarrito({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.fecha,
    required this.hora,
    required this.paquete,
  });

  final int id;
  final String nombre;
  final String tipo;
  final DateTime fecha;
  final int hora; // minutos desde medianoche
  Paquete paquete;

  // Ids de los extras encendidos para este evento
  final Set<int> extras = {};
}

// Solicitud ya enviada al decorador (respuesta 201 del POST)
class Solicitud {
  Solicitud({
    required this.numero,
    required this.evento,
    required this.total,
    required this.enviadaEn,
  });

  final int numero;
  final EventoCarrito evento;
  final double total;
  final DateTime enviadaEn;
  EstadoSolicitud estado = EstadoSolicitud.enviada;
}

// Aviso que aparece en la campana de notificaciones
class Notificacion {
  Notificacion({required this.titulo, required this.mensaje, required this.fecha});

  final String titulo;
  final String mensaje;
  final DateTime fecha;
  bool leida = false;
}
