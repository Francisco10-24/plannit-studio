import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/catalogo.dart';
import 'api_client.dart';

// Resultado del POST con lo necesario para mostrarlo en pantalla
class ResultadoSolicitud {
  const ResultadoSolicitud({required this.codigo, required this.numero, required this.info});

  final int codigo;
  final int numero;
  final String info;
}

class PaquetesService {
  PaquetesService(this._dio);

  final Dio _dio;

  // GET: paquetes, extras y decoradores
  Future<Catalogo> obtenerCatalogo() async {
    final respuesta = await _dio.get(kUrlCatalogo);
    final datos = respuesta.data is String
        ? jsonDecode(respuesta.data as String) as Map<String, dynamic>
        : respuesta.data as Map<String, dynamic>;
    final info =
        'GET /plannit-studio-api/db.json · ${respuesta.statusCode} OK · ${respuesta.extra['ms']} ms';
    return Catalogo.fromJson(datos, infoHttp: info);
  }

  // POST: envía la solicitud al decorador. Éxito = 201 Created
  Future<ResultadoSolicitud> enviarSolicitud(Map<String, dynamic> datos) async {
    final respuesta = await _dio.post(kUrlSolicitudes, data: datos);
    final codigo = respuesta.statusCode ?? 0;
    final numero = (respuesta.data is Map ? respuesta.data['id'] : null) as int? ?? 0;
    final info = 'POST /solicitudes · $codigo Created · #SOL-${20380 + numero}';
    return ResultadoSolicitud(codigo: codigo, numero: 20380 + numero, info: info);
  }
}

// Instancia compartida que usan las pantallas
final paquetesService = PaquetesService(dio);
