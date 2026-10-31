import 'dart:async';

import 'package:dio/dio.dart';
import 'package:plannit_studio/data/repositorios/catalogo_repository.dart';
import 'package:plannit_studio/data/repositorios/solicitudes_repository.dart';
import 'package:plannit_studio/data/servicios/almacenamiento.dart';
import 'package:plannit_studio/data/servicios/auth_service.dart';
import 'package:plannit_studio/models/catalogo.dart';
import 'package:plannit_studio/models/paquete.dart';
import 'package:plannit_studio/models/solicitud.dart';
import 'package:plannit_studio/models/usuario.dart';

// Fakes: implementaciones escritas a mano que cumplen el mismo contrato.
// Se inyectan por constructor en lugar de Firebase o Dio.

Paquete paqueteDePrueba(int id, double precio, {String decorador = 'Deco Studio Luna'}) => Paquete(
      id: id,
      nombre: 'Paquete $id',
      decorador: decorador,
      zona: 'Santa Tecla',
      estilo: 'Glam',
      eventos: const ['Cumpleaños'],
      precio: precio,
      rating: 4.8,
      resenas: 10,
      colores: const ['#9B1B30'],
      incluye: 'Arco',
      etiqueta: '',
      imagen: '',
    );

class FakeAuthService implements AuthService {
  final _cuentas = <String, (Usuario, String)>{};
  final _cambios = StreamController<Usuario?>.broadcast();
  var _siguiente = 1;

  @override
  Stream<Usuario?> cambios() => _cambios.stream;

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String telefono,
    required String password,
    required Rol rol,
    String? decorador,
  }) async {
    if (_cuentas.containsKey(correo)) throw const ErrorCuenta('Ya existe una cuenta con ese correo');
    final usuario = Usuario(
      uid: 'uid${_siguiente++}',
      nombre: nombre,
      correo: correo,
      telefono: telefono,
      rol: rol,
      decorador: decorador,
    );
    _cuentas[correo] = (usuario, password);
    _cambios.add(usuario);
    return usuario;
  }

  @override
  Future<Usuario> iniciarSesion(String correo, String password) async {
    final cuenta = _cuentas[correo];
    if (cuenta == null || cuenta.$2 != password) throw const ErrorCuenta('Correo o contraseña incorrectos');
    _cambios.add(cuenta.$1);
    return cuenta.$1;
  }

  @override
  Future<void> cerrarSesion() async => _cambios.add(null);
}

class FakeSolicitudes implements SolicitudesRepository {
  final List<Solicitud> guardadas = [];
  final _cambios = StreamController<List<Solicitud>>.broadcast();
  bool fallarAlEnviar = false;

  @override
  Future<String> enviar(Solicitud solicitud) async {
    if (fallarAlEnviar) throw StateError('sin conexión');
    final id = 'sol${guardadas.length + 1}';
    guardadas.add(solicitud.conId(id));
    _cambios.add(List.of(guardadas));
    return id;
  }

  @override
  Stream<List<Solicitud>> delCliente(String clienteUid) =>
      _cambios.stream.map((l) => l.where((s) => s.clienteUid == clienteUid).toList());

  @override
  Stream<List<Solicitud>> paraDecorador(String decorador) =>
      _cambios.stream.map((l) => l.where((s) => s.decorador == decorador).toList());

  @override
  Future<void> cambiarEstado(String id, EstadoSolicitud estado) async {
    final i = guardadas.indexWhere((s) => s.id == id);
    guardadas[i] = guardadas[i].conEstado(estado);
    _cambios.add(List.of(guardadas));
  }
}

class FakeCatalogoRemoto implements CatalogoFuenteRemota {
  FakeCatalogoRemoto(this.catalogo);

  Catalogo catalogo;
  bool sinConexion = false;

  @override
  Future<Catalogo> obtener() async {
    if (sinConexion) {
      throw DioException(requestOptions: RequestOptions(path: '/db.json'), type: DioExceptionType.connectionError);
    }
    return catalogo;
  }
}

class AlmacenEnMemoria implements AlmacenSeguro {
  final datos = <String, String>{};

  @override
  Future<void> guardar(String clave, String valor) async => datos[clave] = valor;

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> borrar(String clave) async => datos.remove(clave);
}
