import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plannit_studio/data/api_client.dart';

DioException error(DioExceptionType tipo, {int? codigo}) {
  final opciones = RequestOptions(path: '/db.json');
  return DioException(
    requestOptions: opciones,
    type: tipo,
    response: codigo == null ? null : Response(requestOptions: opciones, statusCode: codigo),
  );
}

void main() {
  test('sin red: se reconoce para mostrar los paquetes guardados', () {
    final e = error(DioExceptionType.connectionError);
    expect(esSinConexion(e), isTrue);
    expect(mensajeDeError(e), 'Sin conexión a internet.');
  });

  test('tiempo agotado tiene su propio mensaje', () {
    final e = error(DioExceptionType.receiveTimeout);
    expect(esSinConexion(e), isFalse);
    expect(mensajeDeError(e), 'El servidor tardó demasiado en responder.');
  });

  test('respuesta con error muestra el código del servidor', () {
    final e = error(DioExceptionType.badResponse, codigo: 404);
    expect(esSinConexion(e), isFalse);
    expect(mensajeDeError(e), 'Error del servidor (404).');
  });
}
