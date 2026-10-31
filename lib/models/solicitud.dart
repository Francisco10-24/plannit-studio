import 'package:cloud_firestore/cloud_firestore.dart';

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
    Set<int>? extras,
  }) : extras = extras ?? {};

  final int id;
  final String nombre;
  final String tipo;
  final DateTime fecha;
  final int hora; // minutos desde medianoche
  Paquete paquete;

  // Ids de los extras encendidos para este evento
  final Set<int> extras;

  // Para guardar el carrito en la base local (Sembast)
  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'paquete': paquete.toJson(),
        'extras': extras.toList(),
      };

  factory EventoCarrito.fromMap(Map<String, Object?> map) => EventoCarrito(
        id: map['id'] as int,
        nombre: map['nombre'] as String,
        tipo: map['tipo'] as String,
        fecha: DateTime.parse(map['fecha'] as String),
        hora: map['hora'] as int,
        paquete: Paquete.fromJson(Map<String, dynamic>.from(map['paquete'] as Map)),
        extras: (map['extras'] as List).cast<int>().toSet(),
      );
}

// Solicitud enviada al decorador (documento en Firestore)
class Solicitud {
  const Solicitud({
    required this.id,
    required this.clienteUid,
    required this.clienteNombre,
    required this.decorador,
    required this.evento,
    required this.tipo,
    required this.fecha,
    required this.hora,
    required this.paquete,
    required this.extras,
    required this.total,
    required this.estado,
    required this.enviadaEn,
  });

  final String id;
  final String clienteUid;
  final String clienteNombre;
  final String decorador;
  final String evento;
  final String tipo;
  final DateTime fecha;
  final int hora;
  final Paquete paquete;
  final List<String> extras; // nombres de los extras elegidos
  final double total;
  final EstadoSolicitud estado;
  final DateTime enviadaEn;

  // Número corto y legible a partir del id del documento
  String get numero => id.length <= 6 ? id.toUpperCase() : id.substring(0, 6).toUpperCase();

  Map<String, dynamic> toMap() => {
        'clienteUid': clienteUid,
        'clienteNombre': clienteNombre,
        'decorador': decorador,
        'evento': evento,
        'tipo': tipo,
        'fecha': Timestamp.fromDate(fecha),
        'hora': hora,
        'paquete': paquete.toJson(),
        'extras': extras,
        'total': total,
        'estado': estado.name,
        'enviadaEn': Timestamp.fromDate(enviadaEn),
      };

  factory Solicitud.fromMap(String id, Map<String, dynamic> map) => Solicitud(
        id: id,
        clienteUid: map['clienteUid'] as String,
        clienteNombre: map['clienteNombre'] as String,
        decorador: map['decorador'] as String,
        evento: map['evento'] as String,
        tipo: map['tipo'] as String,
        fecha: (map['fecha'] as Timestamp).toDate(),
        hora: map['hora'] as int,
        paquete: Paquete.fromJson(Map<String, dynamic>.from(map['paquete'] as Map)),
        extras: List<String>.from(map['extras'] as List),
        total: (map['total'] as num).toDouble(),
        estado: EstadoSolicitud.values.byName(map['estado'] as String),
        enviadaEn: (map['enviadaEn'] as Timestamp).toDate(),
      );

  Solicitud conEstado(EstadoSolicitud nuevo) => _copiar(id: id, estado: nuevo);

  Solicitud conId(String nuevoId) => _copiar(id: nuevoId, estado: estado);

  Solicitud _copiar({required String id, required EstadoSolicitud estado}) => Solicitud(
        id: id,
        clienteUid: clienteUid,
        clienteNombre: clienteNombre,
        decorador: decorador,
        evento: evento,
        tipo: tipo,
        fecha: fecha,
        hora: hora,
        paquete: paquete,
        extras: extras,
        total: total,
        estado: estado,
        enviadaEn: enviadaEn,
      );
}

// Aviso que aparece en la campana de notificaciones
class Notificacion {
  Notificacion({required this.titulo, required this.mensaje, required this.fecha});

  final String titulo;
  final String mensaje;
  final DateTime fecha;
  bool leida = false;
}
