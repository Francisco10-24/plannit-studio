import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/usuario.dart';

// Error de cuenta con un mensaje listo para mostrar
class ErrorCuenta implements Exception {
  const ErrorCuenta(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

// Contrato de autenticación (en las pruebas se usa una versión falsa)
abstract class AuthService {
  // Emite el usuario cuando inicia o cierra sesión (null = sin sesión)
  Stream<Usuario?> cambios();

  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String telefono,
    required String password,
    required Rol rol,
    String? decorador,
  });

  Future<Usuario> iniciarSesion(String correo, String password);

  Future<void> cerrarSesion();
}

// Implementación con Firebase Authentication + documento usuarios/{uid} en Firestore
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('usuarios').doc(uid);

  @override
  Stream<Usuario?> cambios() => _auth.authStateChanges().asyncMap((usuario) async {
        if (usuario == null) return null;
        final datos = await _doc(usuario.uid).get();
        if (!datos.exists) return null;
        return Usuario.fromMap(usuario.uid, datos.data()!);
      });

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String telefono,
    required String password,
    required Rol rol,
    String? decorador,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(email: correo, password: password);
      final usuario = Usuario(
        uid: credencial.user!.uid,
        nombre: nombre,
        correo: correo,
        telefono: telefono,
        rol: rol,
        decorador: rol == Rol.decorador ? decorador : null,
      );
      await _doc(usuario.uid).set(usuario.toMap());
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw ErrorCuenta(_mensaje(e.code));
    }
  }

  @override
  Future<Usuario> iniciarSesion(String correo, String password) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(email: correo, password: password);
      final datos = await _doc(credencial.user!.uid).get();
      if (!datos.exists) throw const ErrorCuenta('La cuenta no tiene datos de perfil.');
      return Usuario.fromMap(credencial.user!.uid, datos.data()!);
    } on FirebaseAuthException catch (e) {
      throw ErrorCuenta(_mensaje(e.code));
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();

  // Códigos de Firebase traducidos a mensajes claros
  String _mensaje(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      default:
        return 'No se pudo completar la operación ($codigo).';
    }
  }
}
