import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/catalogo.dart';

// Búsqueda hecha en "Cotiza tu deco", con la fecha en que se consultó
class Busqueda {
  const Busqueda({required this.tipo, required this.estilo, required this.fecha});

  final String tipo;
  final String estilo;
  final DateTime fecha;
}

// Datos de la cotización y caché del catálogo para el modo sin conexión
class CotizacionModel extends ChangeNotifier {
  String tipoEvento = 'Cumpleaños';
  String estilo = 'Glam';
  DateTime? fecha;
  int? horaInicio;
  double? espacioM2;
  double? presupuestoMin;
  double? presupuestoMax;
  bool _activa = false;

  Catalogo? _ultimoCatalogo;
  DateTime? _consultadoEn;
  final List<Busqueda> _recientes = [];

  bool get tieneCotizacion => _activa;
  Catalogo? get ultimoCatalogo => _ultimoCatalogo;
  DateTime? get consultadoEn => _consultadoEn;
  UnmodifiableListView<Busqueda> get recientes => UnmodifiableListView(_recientes);

  void guardarCatalogo(Catalogo catalogo, DateTime fecha) {
    _ultimoCatalogo = catalogo;
    _consultadoEn = fecha;
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
    _activa = true;
    _recientes.insert(0, Busqueda(tipo: tipo, estilo: estiloElegido, fecha: DateTime.now()));
    if (_recientes.length > 5) _recientes.removeLast();
    notifyListeners();
  }

  // Quita los filtros de la cotización (el historial se conserva)
  void limpiarCotizacion() {
    _activa = false;
    notifyListeners();
  }
}
