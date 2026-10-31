import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/repositorios/solicitudes_repository.dart';
import '../data/servicios/monitoreo.dart';
import '../models/solicitud.dart';
import '../models/usuario.dart';
import 'carrito_model.dart';

// Solicitudes enviadas (cliente) y recibidas (decorador), en tiempo real
class SolicitudesModel extends ChangeNotifier {
  // El repository llega por constructor: Firestore en la app, un fake en las pruebas
  SolicitudesModel(this._repositorio);

  final SolicitudesRepository _repositorio;

  StreamSubscription<List<Solicitud>>? _misSolicitudes;
  StreamSubscription<List<Solicitud>>? _recibidas;
  String? _uidActual;

  List<Solicitud> _mias = [];
  List<Solicitud> _paraMi = [];
  final List<Notificacion> _notificaciones = [];

  // Último estado conocido de cada solicitud, para detectar cambios
  final Map<String, EstadoSolicitud> _estadosConocidos = {};

  UnmodifiableListView<Solicitud> get mias => UnmodifiableListView(_mias);
  UnmodifiableListView<Solicitud> get recibidas => UnmodifiableListView(_paraMi);
  UnmodifiableListView<Notificacion> get notificaciones => UnmodifiableListView(_notificaciones);
  int get noLeidas => _notificaciones.where((n) => !n.leida).length;
  int get pendientes => _paraMi.where((s) => s.estado != EstadoSolicitud.aprobada).length;

  // Se llama cada vez que cambia la sesión
  void escucharUsuario(Usuario? usuario) {
    if (usuario?.uid == _uidActual) return;
    _uidActual = usuario?.uid;
    _misSolicitudes?.cancel();
    _recibidas?.cancel();
    _mias = [];
    _paraMi = [];
    _notificaciones.clear();
    _estadosConocidos.clear();

    if (usuario != null) {
      _misSolicitudes = _repositorio.delCliente(usuario.uid).listen(_alRecibirMias);
      if (usuario.esDecorador && usuario.decorador != null) {
        _recibidas = _repositorio.paraDecorador(usuario.decorador!).listen((lista) {
          _paraMi = lista;
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }

  void _alRecibirMias(List<Solicitud> lista) {
    for (final s in lista) {
      final antes = _estadosConocidos[s.id];
      if (antes != null && antes != s.estado) {
        if (s.estado == EstadoSolicitud.enRevision) {
          _avisar('En revisión', '${s.decorador} está revisando "${s.evento}".');
        } else if (s.estado == EstadoSolicitud.aprobada) {
          _avisar('Solicitud aprobada', '${s.decorador} aprobó "${s.evento}".');
        }
      }
      _estadosConocidos[s.id] = s.estado;
    }
    _mias = lista;
    notifyListeners();
  }

  // Envía cada evento del carrito como una solicitud. Devuelve cuántas se enviaron.
  // Si falla una, las demás se quedan en el carrito para reintentar.
  Future<int> enviarCarrito(CarritoModel carrito, Usuario cliente) async {
    var enviadas = 0;
    for (final evento in List.of(carrito.eventos)) {
      final solicitud = Solicitud(
        id: '',
        clienteUid: cliente.uid,
        clienteNombre: cliente.nombre,
        decorador: evento.paquete.decorador,
        evento: evento.nombre,
        tipo: evento.tipo,
        fecha: evento.fecha,
        hora: evento.hora,
        paquete: evento.paquete,
        extras: carrito.nombresExtras(evento),
        total: carrito.totalEvento(evento),
        estado: EstadoSolicitud.enviada,
        enviadaEn: DateTime.now(),
      );
      final id = await _repositorio.enviar(solicitud);
      _estadosConocidos[id] = EstadoSolicitud.enviada;
      _avisar('Solicitud enviada', '${evento.paquete.decorador} recibió "${evento.nombre}".');
      carrito.quitar(evento.id);
      enviadas++;
    }
    await Analitica.evento('enviar_solicitud', {'cantidad': enviadas});
    notifyListeners();
    return enviadas;
  }

  // Lo usa el decorador desde su panel
  Future<void> cambiarEstado(Solicitud solicitud, EstadoSolicitud nuevo) =>
      _repositorio.cambiarEstado(solicitud.id, nuevo);

  void marcarLeidas() {
    for (final n in _notificaciones) {
      n.leida = true;
    }
    notifyListeners();
  }

  void _avisar(String titulo, String mensaje) {
    _notificaciones.insert(0, Notificacion(titulo: titulo, mensaje: mensaje, fecha: DateTime.now()));
  }

  @override
  void dispose() {
    // Se cancelan las suscripciones para no dejar streams abiertos
    _misSolicitudes?.cancel();
    _recibidas?.cancel();
    super.dispose();
  }
}
