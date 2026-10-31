import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/fuentes/carrito_local.dart';
import '../models/extra.dart';
import '../models/paquete.dart';
import '../models/solicitud.dart';

// Carrito con varios eventos (requisito 3 de la ficha):
// cada evento tiene un solo paquete, y los extras se eligen por evento.
class CarritoModel extends ChangeNotifier {
  // local es opcional: en las pruebas el carrito vive solo en memoria
  CarritoModel({this.local});

  static const double costoMontaje = 25.0;

  final CarritoLocal? local;
  final List<EventoCarrito> _eventos = [];
  List<Extra> _extrasCatalogo = [];
  int _siguienteId = 1;

  UnmodifiableListView<EventoCarrito> get eventos => UnmodifiableListView(_eventos);
  UnmodifiableListView<Extra> get extrasCatalogo => UnmodifiableListView(_extrasCatalogo);
  int get cantidad => _eventos.length;

  // ---- Totales: siempre calculados con where + fold, nunca guardados ----

  double subtotalExtras(EventoCarrito evento) => _extrasCatalogo
      .where((extra) => evento.extras.contains(extra.id))
      .fold(0.0, (suma, extra) => suma + extra.precio);

  double totalEvento(EventoCarrito evento) {
    final total = evento.paquete.precio + subtotalExtras(evento) + costoMontaje;
    // Estado imposible: solo se revisa en modo debug (clase 28)
    assert(total >= 0, 'El total de un evento no puede ser negativo');
    return total;
  }

  double get total => _eventos.fold(0.0, (suma, evento) => suma + totalEvento(evento));

  // ---- Persistencia local (Sembast) ----

  // Se llama una vez al abrir la app: recupera el carrito guardado
  Future<void> cargar() async {
    final fuente = local;
    if (fuente == null) return;
    final guardados = await fuente.leerTodo();
    _eventos
      ..clear()
      ..addAll(guardados);
    if (guardados.isNotEmpty) {
      _siguienteId = guardados.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    }
    notifyListeners();
  }

  // Avisa a la pantalla y guarda en el teléfono sin hacerla esperar
  void _cambio() {
    notifyListeners();
    final fuente = local;
    if (fuente != null) unawaited(fuente.guardarTodo(List.of(_eventos)));
  }

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
    assert(paquete.precio >= 0, 'Un paquete no puede tener precio negativo');
    final evento = EventoCarrito(
      id: _siguienteId++,
      nombre: nombre,
      tipo: tipo,
      fecha: fecha,
      hora: hora,
      paquete: paquete,
    );
    _eventos.add(evento);
    _cambio();
    return evento;
  }

  // Un evento solo admite un paquete: cambiarlo reemplaza el anterior
  void reemplazarPaquete(int eventoId, Paquete paquete) {
    _eventos.firstWhere((e) => e.id == eventoId).paquete = paquete;
    _cambio();
  }

  void quitar(int eventoId) {
    _eventos.removeWhere((e) => e.id == eventoId);
    _cambio();
  }

  // Vuelve a poner un evento quitado (botón "Deshacer")
  void restaurar(EventoCarrito evento) {
    _eventos.add(evento);
    _cambio();
  }

  void alternarExtra(int eventoId, int extraId) {
    final evento = _eventos.firstWhere((e) => e.id == eventoId);
    if (!evento.extras.remove(extraId)) evento.extras.add(extraId);
    _cambio();
  }

  // Nombres de los extras encendidos de un evento (para la solicitud)
  List<String> nombresExtras(EventoCarrito evento) => _extrasCatalogo
      .where((extra) => evento.extras.contains(extra.id))
      .map((extra) => extra.nombre)
      .toList();
}
