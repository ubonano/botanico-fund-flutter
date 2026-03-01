import 'package:firebase_auth/firebase_auth.dart';

/// Servicio que encapsula la autenticación con Firebase Auth.
///
/// Provee métodos para iniciar sesión con email/contraseña,
/// cerrar sesión y escuchar cambios en el estado de autenticación.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream que emite el usuario actual cada vez que cambia el estado de auth.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Retorna el usuario actualmente autenticado, o null si no hay sesión.
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con email y contraseña.
  ///
  /// Lanza [FirebaseAuthException] si las credenciales son inválidas.
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
