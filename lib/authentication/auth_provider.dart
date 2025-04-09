import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

//! PROVEEDOR DE AUTENTICACIÓN
//! Esta clase gestiona el estado de autenticación y notifica a los widgets cuando cambia
//! Implementa ChangeNotifier para la gestión de estado reactivo

class AuthProvider extends ChangeNotifier {
  //! Instancia del servicio de autenticación que maneja las operaciones con Firebase
  final AuthService _authService = AuthService();
  
  //! Variables de estado
  User? _user;                 //* Usuario actual (null si no hay sesión)
  String? _errorMessage;       //* Mensaje de error (null si no hay error)
  bool _isLoading = false;     //* Indicador de carga para operaciones asíncronas

  //! Getters para acceder al estado desde los widgets
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;  //* Atajo para verificar si hay sesión activa

  //! Constructor: inicializa y configura los listeners
  AuthProvider() {
    _init();
  }

  //! Inicialización: configura el listener para cambios en la autenticación
  void _init() {
    //! Suscribirse al stream de cambios de autenticación
    //* Cada vez que cambia el estado de auth (login/logout), se actualiza _user
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      //! Notificar a todos los widgets que están escuchando este proveedor
      notifyListeners();
    });
  }

  //! Método para registrar un nuevo usuario
  //! Retorna true si el registro fue exitoso, false en caso contrario
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    //! Preparar el estado para la operación
    _errorMessage = null;      //* Limpiar errores anteriores
    _isLoading = true;         //* Indicar que hay una operación en curso
    notifyListeners();         //* Notificar cambios (mostrar loading)

    try {
      //! Llamar al servicio de autenticación para registrar al usuario
      await _authService.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      //! Actualizar estado al completar
      _isLoading = false;
      notifyListeners();
      return true;    //* Éxito
    } catch (e) {
      //! Capturar y almacenar el error
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;   //* Fallo
    }
  }

  //! Método para iniciar sesión con email y contraseña
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    //! Preparar el estado para la operación
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      //! Llamar al servicio de autenticación para iniciar sesión
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //! Actualizar estado al completar
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      //! Capturar y almacenar el error
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //! Método para cerrar la sesión del usuario actual
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      //! Llamar al servicio de autenticación para cerrar sesión
      await _authService.signOut();
      //? No es necesario actualizar _user ya que el listener lo hará automáticamente
    } catch (e) {
      //! Capturar cualquier error durante el cierre de sesión
      _errorMessage = e.toString();
    } finally {
      //! Siempre finalizar el estado de carga, incluso si hay error
      _isLoading = false;
      notifyListeners();
    }
  }

  //! Método para enviar correo de recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      //! Llamar al servicio para enviar el correo de recuperación
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //! Método para obtener datos adicionales del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;  //* No hay usuario autenticado
    
    try {
      //! Obtener datos del usuario usando su UID
      return await _authService.getUserData(_user!.uid);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  //! Método para limpiar mensajes de error
  //! Útil para resetear el estado después de mostrar un error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 