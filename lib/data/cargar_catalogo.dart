import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/catalogo.dart';
import '../state/carrito_model.dart';
import '../state/cotizacion_model.dart';
import 'paquetes_service.dart';

// Hace el GET y guarda el resultado donde lo necesitan las demás pantallas:
// - CotizacionModel: caché con fecha para el modo sin conexión
// - CarritoModel: lista de extras para calcular totales
Future<Catalogo> cargarCatalogo(BuildContext context) async {
  // Se leen los modelos antes del await para no usar el context después
  final cotizacion = context.read<CotizacionModel>();
  final carrito = context.read<CarritoModel>();

  final catalogo = await paquetesService.obtenerCatalogo();
  cotizacion.guardarCatalogo(catalogo, DateTime.now());
  carrito.cargarExtras(catalogo.extras);
  return catalogo;
}
