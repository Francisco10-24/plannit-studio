import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/catalogo.dart';
import '../models/extra.dart';
import '../models/paquete.dart';

enum EstadoSolicitud { ninguna, enviada, enRevision, aprobada }

// Búsqueda hecha en "Cotiza tu deco", con la fecha en que se consultó
class Busqueda {
  const Busqueda({required this.tipo, required this.estilo, required this.fecha});

  final String tipo;
  final String estilo;
  final DateTime fecha;
}

// Estado compartido del evento que el cliente está armando
class EventoModel extends ChangeNotifier {
  static const double costoMontaje = 25.0;

  // ---- Datos del evento (vienen de Cotiza tu deco) ----
  String tipoEvento = 'Cumpleaños';
  String estilo = 'Glam';
  DateTime? fecha;
  int? horaInicio;
  double? espacioM2;
  double? presupuestoMin;
  double? presupuestoMax;

  // ---- Paquete y extras ----
  Paquete? _paquete;
  List<Extra> _extras = [];
  final Set<int> _extrasActivos = {};
  bool _extrasIniciados = false;

  // ---- Solicitud ----
  EstadoSolicitud _estado = EstadoSolicitud.ninguna;
  int? numeroSolicitud;
  String infoPost = '';

  // ---- Cuenta ----
  String? usuario;

  // ---- Caché para modo sin conexión ----
  Catalogo? _ultimoCatalogo;
  DateTime? _consultadoEn;
  final List<Busqueda> _recientes = [];

  Paquete? get paqueteElegido => _paquete;
  UnmodifiableListView<Extra> get extras => UnmodifiableListView(_extras);
  bool extraActivo(int id) => _extrasActivos.contains(id);
  EstadoSolicitud get estado => _estado;
  Catalogo? get ultimoCatalogo => _ultimoCatalogo;
  DateTime? get consultadoEn => _consultadoEn;
  UnmodifiableListView<Busqueda> get recientes => UnmodifiableListView(_recientes);

  // Suma de los extras encendidos (where + fold)
  double get subtotalExtras => _extras
      .where((e) => _extrasActivos.contains(e.id))
      .fold(0.0, (suma, e) => suma + e.precio);

  // El total nunca se guarda: siempre se calcula
  double get total =>
      _paquete == null ? 0 : _paquete!.precio + subtotalExtras + costoMontaje;

  void guardarCatalogo(Catalogo catalogo, DateTime fecha) {
    _ultimoCatalogo = catalogo;
    _consultadoEn = fecha;
    _extras = catalogo.extras;
    if (!_extrasIniciados) {
      // Arco y letras LED vienen sugeridos, como en el diseño
      _extrasActivos.addAll(_extras.take(2).map((e) => e.id));
      _extrasIniciados = true;
    }
    notifyListeners();
  }

  // Un evento = un solo paquete. Elegir otro reemplaza el anterior.
  void elegirPaquete(Paquete paquete) {
    if (_paquete?.id != paquete.id) {
      _estado = EstadoSolicitud.ninguna;
      numeroSolicitud = null;
      infoPost = '';
    }
    _paquete = paquete;
    notifyListeners();
  }

  void alternarExtra(int id) {
    if (!_extrasActivos.remove(id)) _extrasActivos.add(id);
    notifyListeners();
  }

  void guardarEvento({
    required String tipo,
    required String estiloElegido,
    required DateTime fechaEvento,
    required int inicio,
    required double espacio,
    required double minimo,
    required double maximo,
  }) {
    tipoEvento = tipo;
    estilo = estiloElegido;
    fecha = fechaEvento;
    horaInicio = inicio;
    espacioM2 = espacio;
    presupuestoMin = minimo;
    presupuestoMax = maximo;
    _recientes.insert(0, Busqueda(tipo: tipo, estilo: estiloElegido, fecha: DateTime.now()));
    if (_recientes.length > 5) _recientes.removeLast();
    notifyListeners();
  }

  void registrarUsuario(String nombre) {
    usuario = nombre;
    notifyListeners();
  }

  void cerrarSesion() {
    usuario = null;
    notifyListeners();
  }

  void marcarEnviada(int numero, String info) {
    numeroSolicitud = numero;
    infoPost = info;
    _estado = EstadoSolicitud.enviada;
    notifyListeners();
  }

  // Simula que el decorador abre la solicitud
  void avanzarEstado() {
    if (_estado == EstadoSolicitud.enviada) {
      _estado = EstadoSolicitud.enRevision;
      notifyListeners();
    }
  }

  // Datos que se envían en el POST
  Map<String, dynamic> solicitudJson() => {
        'cliente': usuario,
        'paqueteId': _paquete?.id,
        'paquete': _paquete?.nombre,
        'extras': _extras
            .where((e) => _extrasActivos.contains(e.id))
            .map((e) => e.toJson())
            .toList(),
        'tipoEvento': tipoEvento,
        'fecha': fecha?.toIso8601String(),
        'total': total,
      };
}
