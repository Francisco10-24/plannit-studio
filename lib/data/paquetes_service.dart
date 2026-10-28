import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/catalogo.dart';
import 'api_client.dart';

// Resultado del POST con lo necesario para mostrarlo en pantalla
class ResultadoSolicitud {
  const ResultadoSolicitud({required this.codigo, required this.numero});

  final int codigo;
  final int numero;
}

class PaquetesService {
  PaquetesService(this._dio);

  final Dio _dio;

  // JSONPlaceholder siempre responde id 101, así que el número visible
  // de cada solicitud se genera aquí para que no se repita
  int _ultimoNumero = 20480;

  // GET: paquetes, extras y decoradores
  Future<Catalogo> obtenerCatalogo() async {
    final respuesta = await _dio.get(kUrlCatalogo);
    final datos = respuesta.data is String
        ? jsonDecode(respuesta.data as String) as Map<String, dynamic>
        : respuesta.data as Map<String, dynamic>;
    return Catalogo.fromJson(datos);
  }

  // POST: envía la solicitud al decorador. Éxito = 201 Created
  Future<ResultadoSolicitud> enviarSolicitud(Map<String, dynamic> datos) async {
    final respuesta = await _dio.post(kUrlSolicitudes, data: datos);
    return ResultadoSolicitud(codigo: respuesta.statusCode ?? 0, numero: ++_ultimoNumero);
  }
}

// Instancia compartida que usan las pantallas
final paquetesService = PaquetesService(dio);
