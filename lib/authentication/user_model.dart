//! MODELO DE USUARIO
//! Esta clase define la estructura de datos para los usuarios
//! Facilita la conversión entre Firestore y la aplicación

class UserModel {
  //! Propiedades principales del usuario
  final String uid;        //* Identificador único de Firebase Auth
  final String name;       //* Nombre completo del usuario
  final String email;      //* Correo electrónico (debe coincidir con Auth)
  final DateTime createdAt; //* Fecha de creación de la cuenta

  //! Constructor principal con parámetros nombrados
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  //! FACTORY: Crea un modelo de usuario a partir de datos de Firestore
  //! Permite convertir los datos almacenados en la BD a objetos de la app
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',  //* Valor por defecto si es null
      email: data['email'] ?? '',
      //! Convertir Timestamp de Firestore a DateTime de Dart
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  //! Convierte el modelo a un mapa para guardar en Firestore
  //! No incluye el UID ya que se usa como ID del documento
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt,
    };
  }

  //! Crea una copia del usuario con algunos campos modificados
  //! Útil para actualizar datos sin modificar el objeto original (inmutabilidad)
  UserModel copyWith({
    String? name,
    String? email,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: this.createdAt,
    );
  }
} 