import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/catalogo.dart';
import '../api_client.dart';
import '../fuentes/catalogo_local.dart';

// Contrato de la fuente remota: el repository no sabe si es Dio, http o un fake
abstract class CatalogoFuenteRemota {
  Future<Catalogo> obtener();
}

// Implementación real: GET por HTTPS con Dio
class DioCatalogoRemoto implements CatalogoFuenteRemota {
  DioCatalogoRemoto(this._dio);

  final Dio _dio;

  @override
  Future<Catalogo> obtener() async {
    final respuesta = await _dio.get(kUrlCatalogo);
    final datos = respuesta.data is String
        ? jsonDecode(respuesta.data as String) as Map<String, dynamic>
        : respuesta.data as Map<String, dynamic>;
    return Catalogo.fromJson(datos);
  }
}

class ResultadoCatalogo {
  const ResultadoCatalogo({required this.catalogo, required this.actualizadoEn, required this.desdeCache});

  final Catalogo catalogo;
  final DateTime actualizadoEn;

  // true cuando no hubo internet y se usó lo guardado en el teléfono
  final bool desdeCache;
}

// Repository con dos fuentes (clases 22 y 26): primero la remota;
// si no hay conexión, la local (Sembast) con la fecha de la última consulta.
class CatalogoRepository {
  CatalogoRepository({required this.remota, required this.local});

  final CatalogoFuenteRemota remota;
  final CatalogoLocal local;

  Future<ResultadoCatalogo> obtener() async {
    try {
      final catalogo = await remota.obtener();
      final ahora = DateTime.now();
      try {
        await local.guardar(catalogo, ahora);
      } catch (e) {
        // Si falla guardar en el teléfono, la app sigue con los datos del servidor
        debugPrint('No se pudo guardar el catálogo local: $e');
      }
      return ResultadoCatalogo(catalogo: catalogo, actualizadoEn: ahora, desdeCache: false);
    } on DioException catch (e) {
      if (!esSinConexion(e)) rethrow;
      final guardado = await local.leer();
      if (guardado == null) rethrow; // nunca se descargó: no hay nada que mostrar
      return ResultadoCatalogo(catalogo: guardado.$1, actualizadoEn: guardado.$2, desdeCache: true);
    }
  }
}
