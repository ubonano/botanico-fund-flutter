import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio que obtiene el rol del usuario desde la colección `users` en Firestore.
///
/// Cada documento en `users` tiene como ID el UID del usuario autenticado
/// y contiene un campo `role` con valores posibles: `admin` o `investor`.
class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el rol del usuario con el [uid] dado.
  ///
  /// Retorna el valor del campo `role` del documento `users/{uid}`,
  /// o `null` si el documento no existe o no tiene el campo.
  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['role'] as String?;
    }

    return null;
  }
}
