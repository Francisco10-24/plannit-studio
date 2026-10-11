import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// GET: db.json del repo público, servido por la CDN jsDelivr (HTTPS)
const String kUrlCatalogo =
    'https://cdn.jsdelivr.net/gh/Francisco10-24/plannit-studio-api@main/db.json';

// POST: JSONPlaceholder responde 201 Created (no guarda datos)
const String kUrlSolicitudes = 'https://jsonplaceholder.typicode.com/posts';

// Una sola instancia de Dio para toda la app
final Dio dio = crearDio();

Dio crearDio() {
  final cliente = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  // Interceptor: registra cada petición y mide cuánto tardó
  cliente.interceptors.add(
    InterceptorsWrapper(
      onRequest: (opciones, handler) {
        opciones.extra['inicio'] = DateTime.now();
        debugPrint('→ ${opciones.method} ${opciones.uri}');
        handler.next(opciones);
      },
      onResponse: (respuesta, handler) {
        final inicio = respuesta.requestOptions.extra['inicio'] as DateTime;
        final ms = DateTime.now().difference(inicio).inMilliseconds;
        respuesta.extra['ms'] = ms;
        debugPrint('← ${respuesta.statusCode} ${respuesta.requestOptions.uri} ($ms ms)');
        handler.next(respuesta);
      },
      onError: (error, handler) {
        debugPrint('✕ ${error.type.name} ${error.requestOptions.uri}');
        handler.next(error);
      },
    ),
  );
  return cliente;
}

// true cuando el problema es la red (modo avión, sin wifi)
bool esSinConexion(Object error) =>
    error is DioException &&
    (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown);

// Mensaje distinto para cada tipo de DioException
String mensajeDeError(Object error) {
  if (error is! DioException) return 'Ocurrió un error inesperado.';
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'El servidor tardó demasiado en responder.';
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return 'Sin conexión a internet.';
    case DioExceptionType.badResponse:
      return 'Error del servidor (${error.response?.statusCode}).';
    default:
      return 'No se pudo completar la solicitud.';
  }
}
