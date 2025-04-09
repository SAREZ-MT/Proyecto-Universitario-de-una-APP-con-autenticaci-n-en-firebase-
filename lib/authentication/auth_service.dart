import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//! SERVICIO DE AUTENTICACIÓN
//! Esta clase maneja todas las operaciones relacionadas con Firebase Authentication y Firestore
//! Proporciona métodos para registrar, autenticar y gestionar usuarios

class AuthService {
  //! Instancias de Firebase (patrón Singleton)
  //* Estas instancias son únicas en toda la aplicación
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //! Obtener usuario actualmente autenticado
  //* Puede ser null si no hay sesión activa
  User? get currentUser => _auth.currentUser;

  //! Stream para monitorear cambios en el estado de autenticación
  //* Emite eventos cuando un usuario inicia o cierra sesión
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //! Método para crear un nuevo usuario con email y password
  //! También guarda información adicional en Firestore
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      //! Paso 1: Crear usuario en Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //! Paso 2: Guardar datos adicionales en Firestore
      //* Esto es importante porque Firebase Auth solo guarda email/password
      await _saveUserData(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      //! Manejo de errores específicos de Firebase Auth
      throw _handleAuthException(e);
    } catch (e) {
      //! Manejo de otros errores generales
      throw Exception('Error al registrar: $e');
    }
  }

  //! Método para iniciar sesión con email y password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      //! Llamada a Firebase Auth para autenticar
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      //! Transformar errores de Firebase a mensajes amigables
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  //! Método para cerrar la sesión del usuario
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //! Método para enviar correo de restablecimiento de contraseña
  Future<void> resetPassword(String email) async {
    try {
      //! Firebase enviará un correo con un enlace para reestablecer
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al restablecer contraseña: $e');
    }
  }

  //! MÉTODO PRIVADO: Guarda información adicional del usuario en Firestore
  //! Los datos se almacenan en la colección 'users' con el UID como identificador
  Future<void> _saveUserData({
    required String uid,
    required String name,
    required String email,
  }) async {
    //! Crear documento en Firestore con los datos del usuario
    //* Se usa el UID de Firebase Auth como clave para relacionar ambas cuentas
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  //! Método para obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      //! Consulta a Firestore por el documento del usuario
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  //! MÉTODO PRIVADO: Traduce códigos de error de Firebase a mensajes amigables
  //! Esto mejora la experiencia de usuario al mostrar mensajes comprensibles
  String _handleAuthException(FirebaseAuthException e) {
    //! Mapeo de códigos de error a mensajes en español
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe usuario con este correo electrónico.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta al administrador.';
      default:
        return 'Error de autenticación: ${e.code}';
    }
  }
} 