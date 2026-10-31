import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../state/carrito_model.dart';
import '../state/cotizacion_model.dart';
import 'repositorios/catalogo_repository.dart';

// Pide el catálogo al repository y lo deja donde lo necesitan las demás pantallas:
// - CotizacionModel: catálogo actual (detalle, decorador, favoritos)
// - CarritoModel: lista de extras para calcular totales
Future<ResultadoCatalogo> cargarCatalogo(BuildContext context) async {
  // Se leen los objetos antes del await para no usar el context después
  final repositorio = context.read<CatalogoRepository>();
  final cotizacion = context.read<CotizacionModel>();
  final carrito = context.read<CarritoModel>();

  final resultado = await repositorio.obtener();
  cotizacion.guardarCatalogo(resultado.catalogo, resultado.actualizadoEn);
  carrito.cargarExtras(resultado.catalogo.extras);
  return resultado;
}
