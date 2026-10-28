import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/extra.dart';
import '../models/paquete.dart';
import '../models/solicitud.dart';
import '../utils/formato.dart';

// Carrito con varios eventos (requisito 3 de la ficha):
// cada evento tiene un solo paquete, y los extras se eligen por evento.
class CarritoModel extends ChangeNotifier {
  static const double costoMontaje = 25.0;

  final List<EventoCarrito> _eventos = [];
  final List<Solicitud> _solicitudes = [];
  final List<Notificacion> _notificaciones = [];
  List<Extra> _extrasCatalogo = [];
  int _siguienteId = 1;

  UnmodifiableListView<EventoCarrito> get eventos => UnmodifiableListView(_eventos);
  UnmodifiableListView<Extra> get extrasCatalogo => UnmodifiableListView(_extrasCatalogo);
  UnmodifiableListView<Solicitud> get solicitudes => UnmodifiableListView(_solicitudes);
  UnmodifiableListView<Notificacion> get notificaciones => UnmodifiableListView(_notificaciones);

  int get cantidad => _eventos.length;
  int get noLeidas => _notificaciones.where((n) => !n.leida).length;

  // ---- Totales: siempre calculados con where + fold, nunca guardados ----

  double subtotalExtras(EventoCarrito evento) => _extrasCatalogo
      .where((extra) => evento.extras.contains(extra.id))
      .fold(0.0, (suma, extra) => suma + extra.precio);

  double totalEvento(EventoCarrito evento) =>
      evento.paquete.precio + subtotalExtras(evento) + costoMontaje;

  double get total => _eventos.fold(0.0, (suma, evento) => suma + totalEvento(evento));

  // ---- Acciones del carrito ----

  void cargarExtras(List<Extra> extras) {
    _extrasCatalogo = extras;
    notifyListeners();
  }

  // Busca si ya hay un evento ese mismo día (para no duplicar reservas)
  EventoCarrito? eventoEnFecha(DateTime fecha) {
    for (final evento in _eventos) {
      if (evento.fecha.year == fecha.year &&
          evento.fecha.month == fecha.month &&
          evento.fecha.day == fecha.day) {
        return evento;
      }
    }
    return null;
  }

  EventoCarrito agregar({
    required String nombre,
    required String tipo,
    required DateTime fecha,
    required int hora,
    required Paquete paquete,
  }) {
    final evento = EventoCarrito(
      id: _siguienteId++,
      nombre: nombre,
      tipo: tipo,
      fecha: fecha,
      hora: hora,
      paquete: paquete,
    );
    _eventos.add(evento);
    notifyListeners();
    return evento;
  }

  // Un evento solo admite un paquete: cambiarlo reemplaza el anterior
  void reemplazarPaquete(int eventoId, Paquete paquete) {
    _eventos.firstWhere((e) => e.id == eventoId).paquete = paquete;
    notifyListeners();
  }

  void quitar(int eventoId) {
    _eventos.removeWhere((e) => e.id == eventoId);
    notifyListeners();
  }

  // Vuelve a poner un evento quitado (botón "Deshacer")
  void restaurar(EventoCarrito evento) {
    _eventos.add(evento);
    notifyListeners();
  }

  void alternarExtra(int eventoId, int extraId) {
    final evento = _eventos.firstWhere((e) => e.id == eventoId);
    if (!evento.extras.remove(extraId)) evento.extras.add(extraId);
    notifyListeners();
  }

  // ---- Solicitudes ----

  // Datos que se envían en el POST de cada evento
  Map<String, dynamic> solicitudJson(EventoCarrito evento, String cliente) => {
        'cliente': cliente,
        'evento': evento.nombre,
        'tipoEvento': evento.tipo,
        'fecha': evento.fecha.toIso8601String(),
        'hora': formatoHora(evento.hora),
        'paqueteId': evento.paquete.id,
        'paquete': evento.paquete.nombre,
        'decorador': evento.paquete.decorador,
        'extras': _extrasCatalogo
            .where((extra) => evento.extras.contains(extra.id))
            .map((extra) => extra.toJson())
            .toList(),
        'total': totalEvento(evento),
      };

  // El POST respondió 201: el evento sale del carrito y pasa a "Mis solicitudes"
  void registrarEnviado(EventoCarrito evento, int numero) {
    _solicitudes.insert(
      0,
      Solicitud(
        numero: numero,
        evento: evento,
        total: totalEvento(evento),
        enviadaEn: DateTime.now(),
      ),
    );
    _eventos.removeWhere((e) => e.id == evento.id);
    _avisar('Solicitud enviada', '${evento.paquete.decorador} recibió tu solicitud #SOL-$numero.');
    notifyListeners();
  }

  // Simula la respuesta del decorador: enviada -> en revisión -> aprobada
  void avanzarSolicitud(int numero) {
    final solicitud = _solicitudes.firstWhere((s) => s.numero == numero);
    final decorador = solicitud.evento.paquete.decorador;
    switch (solicitud.estado) {
      case EstadoSolicitud.enviada:
        solicitud.estado = EstadoSolicitud.enRevision;
        _avisar('En revisión', '$decorador está revisando tu solicitud #SOL-$numero.');
      case EstadoSolicitud.enRevision:
        solicitud.estado = EstadoSolicitud.aprobada;
        _avisar('Solicitud aprobada', '$decorador aprobó "${solicitud.evento.nombre}".');
      case EstadoSolicitud.aprobada:
        return; // ya no avanza más
    }
    notifyListeners();
  }

  void marcarLeidas() {
    for (final n in _notificaciones) {
      n.leida = true;
    }
    notifyListeners();
  }

  void _avisar(String titulo, String mensaje) {
    _notificaciones.insert(0, Notificacion(titulo: titulo, mensaje: mensaje, fecha: DateTime.now()));
  }
}
