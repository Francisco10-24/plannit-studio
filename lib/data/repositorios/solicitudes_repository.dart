import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../../models/solicitud.dart';
import '../api_client.dart';

// Contrato: las pantallas y el estado solo conocen esta interfaz.
// La implementación se elige en main.dart y se inyecta por constructor.
abstract class SolicitudesRepository {
  // Devuelve el id de la solicitud creada
  Future<String> enviar(Solicitud solicitud);

  // Solicitudes que hizo un cliente (se actualizan en tiempo real)
  Stream<List<Solicitud>> delCliente(String clienteUid);

  // Solicitudes que le llegaron a un decorador
  Stream<List<Solicitud>> paraDecorador(String decorador);

  Future<void> cambiarEstado(String id, EstadoSolicitud estado);
}

// Implementación con Cloud Firestore (la que usa la app)
class FirestoreSolicitudes implements SolicitudesRepository {
  FirestoreSolicitudes(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _coleccion => _db.collection('solicitudes');

  @override
  Future<String> enviar(Solicitud solicitud) async {
    final documento = await _coleccion.add(solicitud.toMap());
    return documento.id;
  }

  @override
  Stream<List<Solicitud>> delCliente(String clienteUid) =>
      _escuchar(_coleccion.where('clienteUid', isEqualTo: clienteUid));

  @override
  Stream<List<Solicitud>> paraDecorador(String decorador) =>
      _escuchar(_coleccion.where('decorador', isEqualTo: decorador));

  // snapshots(): Firestore avisa cada vez que algo cambia en la consulta
  Stream<List<Solicitud>> _escuchar(Query<Map<String, dynamic>> consulta) {
    return consulta.snapshots().map((resultado) {
      final lista = resultado.docs.map((d) => Solicitud.fromMap(d.id, d.data())).toList();
      // Más recientes primero (se ordena aquí para no requerir un índice compuesto)
      lista.sort((a, b) => b.enviadaEn.compareTo(a.enviadaEn));
      return lista;
    });
  }

  @override
  Future<void> cambiarEstado(String id, EstadoSolicitud estado) =>
      _coleccion.doc(id).update({'estado': estado.name});
}

// Implementación alternativa: POST con Dio a JSONPlaceholder (clase 21).
// Cumple el mismo contrato, así que se puede cambiar sin tocar las pantallas.
// No guarda en un servidor: la lista vive en memoria mientras la app está abierta.
class HttpSolicitudes implements SolicitudesRepository {
  HttpSolicitudes(this._dio);

  final Dio _dio;
  final List<Solicitud> _enMemoria = [];
  final _cambios = StreamController<List<Solicitud>>.broadcast();

  @override
  Future<String> enviar(Solicitud solicitud) async {
    final respuesta = await _dio.post(kUrlSolicitudes, data: {
      'decorador': solicitud.decorador,
      'paquete': solicitud.paquete.nombre,
      'total': solicitud.total,
    });
    // No basta con que "no truene": se revisa el 201 Created
    if (respuesta.statusCode != 201) {
      throw StateError('Respuesta inesperada del servidor (${respuesta.statusCode})');
    }
    final id = 'http${DateTime.now().millisecondsSinceEpoch}';
    _enMemoria.insert(0, solicitud.conId(id));
    _cambios.add(List.of(_enMemoria));
    return id;
  }

  @override
  Stream<List<Solicitud>> delCliente(String clienteUid) => _filtrar((s) => s.clienteUid == clienteUid);

  @override
  Stream<List<Solicitud>> paraDecorador(String decorador) => _filtrar((s) => s.decorador == decorador);

  Stream<List<Solicitud>> _filtrar(bool Function(Solicitud) condicion) async* {
    yield _enMemoria.where(condicion).toList();
    yield* _cambios.stream.map((lista) => lista.where(condicion).toList());
  }

  @override
  Future<void> cambiarEstado(String id, EstadoSolicitud estado) async {
    final i = _enMemoria.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _enMemoria[i] = _enMemoria[i].conEstado(estado);
    _cambios.add(List.of(_enMemoria));
  }
}
