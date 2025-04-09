# Convertidor de Divisas con Autenticación Firebase

Esta aplicación es un convertidor de divisas que incluye un sistema completo de autenticación con Firebase. Permite a los usuarios registrarse, iniciar sesión y acceder a la funcionalidad de conversión de divisas.

## Características Principales

- **Sistema de autenticación completo**: Registro, inicio de sesión, cierre de sesión y recuperación de contraseña.
- **Almacenamiento de datos de usuario** en Firestore.
- **Interfaz moderna y amigable** con pestañas para alternar entre inicio de sesión y registro.
- **Convertidor de divisas** con soporte para múltiples monedas.
- **Validación de formularios** y manejo de errores.
- **Menú lateral con perfil de usuario** para visualizar información y opciones de cuenta.

## Estructura del Proyecto

```
lib/
├── authentication/         # Lógica de autenticación
│   ├── auth_provider.dart  # Gestión del estado de autenticación
│   ├── auth_service.dart   # Servicios de Firebase Auth y Firestore
│   └── user_model.dart     # Modelo de datos de usuario
├── components/             # Componentes reutilizables 
│   └── profile_drawer.dart # Menú lateral con información de perfil
├── pages/                  # Pantallas de la aplicación
│   ├── login_page.dart     # Pantalla de login/registro
│   └── currency_converter_screen.dart # Convertidor de divisas
├── firebase_options.dart   # Configuración de Firebase
└── main.dart              # Punto de entrada de la aplicación
```

## Descripción Detallada de Archivos

### 1. main.dart

Este archivo es el punto de entrada de la aplicación. Sus funciones principales son:

- Inicializar Firebase y sus servicios.
- Configurar el proveedor de autenticación para toda la aplicación.
- Definir las rutas y temas de la aplicación.

Código clave:
```dart
// Inicialización de Firebase
await Firebase.initializeApp();

// Configuración del proveedor de autenticación
return ChangeNotifierProvider(
  create: (context) => AuthProvider(),
  child: MaterialApp(...))
```

### 2. authentication/auth_service.dart

Este archivo contiene el servicio que interactúa directamente con Firebase Authentication y Firestore. Sus funciones principales son:

- Manejar el registro de usuarios con email y contraseña.
- Gestionar el inicio y cierre de sesión.
- Guardar información de usuario en Firestore.
- Recuperar contraseñas.
- Traducir errores de Firebase a mensajes amigables.

Métodos principales:
- `signUpWithEmailAndPassword`: Registra un nuevo usuario y guarda sus datos.
- `signInWithEmailAndPassword`: Inicia sesión con email y contraseña.
- `signOut`: Cierra la sesión del usuario.
- `resetPassword`: Envía un correo para restablecer la contraseña.
- `_saveUserData`: Guarda los datos del usuario en Firestore.
- `getUserData`: Obtiene los datos del usuario desde Firestore.

### 3. authentication/auth_provider.dart

Este archivo implementa un ChangeNotifier para gestionar el estado de autenticación en toda la aplicación. Sus funciones son:

- Proporcionar acceso al estado de autenticación (usuario actual, errores, loading).
- Intermediar entre la UI y los servicios de autenticación.
- Notificar a los widgets cuando cambia el estado.

Métodos principales:
- `signUp`: Registra un nuevo usuario y maneja el estado de carga y errores.
- `signIn`: Inicia sesión y maneja el estado de carga y errores.
- `signOut`: Cierra la sesión del usuario.
- `resetPassword`: Envía un correo para restablecer la contraseña.
- `getUserData`: Obtiene los datos del usuario.

### 4. authentication/user_model.dart

Define la estructura de datos para representar un usuario en la aplicación.

Propiedades:
- `uid`: Identificador único del usuario.
- `name`: Nombre del usuario.
- `email`: Correo electrónico.
- `createdAt`: Fecha de creación de la cuenta.

Métodos:
- `fromMap`: Crea un usuario desde datos de Firestore.
- `toMap`: Convierte un usuario a formato para guardar en Firestore.

### 5. components/profile_drawer.dart

Implementa el menú lateral que muestra información del perfil del usuario y opciones de navegación:

- Muestra el nombre y correo del usuario autenticado.
- Presenta diferentes opciones según el estado de autenticación.
- Permite cerrar sesión directamente desde el menú.
- Utiliza un FutureBuilder para obtener datos del usuario desde Firestore.

Secciones principales:
- Encabezado con información de usuario (UserAccountsDrawerHeader)
- Opciones de menú condicionalmente renderizadas (autenticado vs. invitado)
- Pie de página con información de la aplicación

### 6. pages/login_page.dart

Implementa la interfaz de usuario para el registro e inicio de sesión. Características:

- Sistema de pestañas para alternar entre inicio de sesión y registro.
- Validación de formularios.
- Visualización de errores de autenticación.
- Recuperación de contraseña.
- Acceso como invitado.
- Redirección automática a la pestaña de inicio de sesión tras un registro exitoso.

Secciones principales:
- `_buildLoginForm`: Formulario de inicio de sesión.
- `_buildRegisterForm`: Formulario de registro.
- `_signIn` y `_signUp`: Lógica para iniciar sesión y registrarse.
- Validadores para email, contraseña y confirmación.

### 7. pages/currency_converter_screen.dart

Implementa el convertidor de divisas. Características:

- Interfaz para ingresar el monto a convertir.
- Selección de monedas de origen y destino.
- Cálculo y visualización del resultado.
- Menú lateral accesible mediante el botón de hamburguesa en la AppBar.

Funciones principales:
- `_convertCurrency`: Realiza el cálculo de la conversión.
- `_buildCurrencyDropdown`: Construye los desplegables para seleccionar monedas.

## Guía de Instalación

1. **Clonar el repositorio**:
   ```
   git clone [URL_DEL_REPOSITORIO]
   cd covert_login
   ```

2. **Instalar dependencias**:
   ```
   flutter pub get
   ```

3. **Configurar Firebase**:
   - Crear un proyecto en la [consola de Firebase](https://console.firebase.google.com/).
   - Agregar una aplicación Android/iOS.
   - Descargar el archivo de configuración (`google-services.json` para Android o `GoogleService-Info.plist` para iOS).
   - Colocarlo en la ubicación correcta del proyecto:
     - Android: `/android/app/google-services.json`
     - iOS: `/ios/Runner/GoogleService-Info.plist`
   - O usar FlutterFire CLI:
     ```
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```

4. **Ejecutar la aplicación**:
   ```
   flutter run
   ```

## Guía de Uso

### Para Usuarios

1. **Pantalla de Inicio de Sesión/Registro**:
   - Selecciona la pestaña "Iniciar Sesión" o "Registrarse".
   - Para iniciar sesión: Ingresa email y contraseña.
   - Para registrarte: Completa todos los campos (nombre, email, contraseña y confirmación).
   - Después de registrarte, serás redirigido automáticamente a la pestaña de inicio de sesión.
   - Si olvidaste tu contraseña, puedes usar la opción "¿Olvidaste tu contraseña?".
   - También puedes acceder como invitado sin necesidad de registrarte.

2. **Convertidor de Divisas**:
   - Ingresa el monto a convertir.
   - Selecciona la moneda de origen ("De").
   - Selecciona la moneda de destino ("A").
   - Haz clic en "Convertir" para realizar la conversión.
   - El resultado se muestra en la parte inferior.
   - Accede al menú lateral presionando el botón en la esquina superior izquierda para ver tu información de perfil y opciones.

### Para Desarrolladores

#### Autenticación

Para implementar nuevas funcionalidades de autenticación:
1. Agrega los métodos necesarios en `auth_service.dart`.
2. Actualiza el estado en `auth_provider.dart`.
3. Implementa la interfaz de usuario en `login_page.dart`.

#### Componentes de UI

Para extender o modificar el menú lateral:
1. Modifica el archivo `profile_drawer.dart` en la carpeta `components`.
2. Para agregar nuevas opciones, añade más ListTiles con la funcionalidad correspondiente.

#### Convertidor de Divisas

Para añadir más monedas o actualizar tasas de cambio:
1. Modifica el mapa `_exchangeRates` en `currency_converter_screen.dart`.
2. Para tasas dinámicas, considera implementar una API de tasas de cambio.

## Consideraciones de Seguridad

- La autenticación se realiza a través de Firebase Authentication, que maneja de forma segura las credenciales.
- Los datos de usuario se almacenan en Firestore.
- Para aplicaciones en producción, considera implementar reglas de seguridad en Firestore.

