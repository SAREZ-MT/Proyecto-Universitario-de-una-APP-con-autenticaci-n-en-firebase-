import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ! Importante: Importación del proveedor de autenticación que gestionará toda la lógica de auth
import 'authentication/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/currency_converter_screen.dart';
import 'firebase_options.dart';

//! ARCHIVO PRINCIPAL: Punto de entrada de la aplicación
//! Este archivo inicializa Firebase y configura el proveedor de autenticación

void main() async {
  //! Paso 1: Asegurar que Flutter esté inicializado antes de usar plugins nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  //! Paso 2: Inicializar Firebase con las opciones de configuración
  //* Esto conecta la app con los servicios de Firebase (Auth, Firestore, etc.)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  //! Paso 3: Iniciar la aplicación con el widget principal
  runApp(const MyApp());
}

//! Widget principal que configura los temas y proveedores
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //! Configuración del AuthProvider para manejar el estado de autenticación
    //* ChangeNotifierProvider permite que los widgets accedan y reaccionen al estado de AuthProvider
    return ChangeNotifierProvider<AuthProvider>(
      //! Creación de la instancia única del proveedor de autenticación
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Convertidor de Divisas',
        debugShowCheckedModeBanner: false,
        //! Configuración del tema general de la aplicación
        theme: ThemeData(
          primarySwatch: Colors.blue,
          //! Personalización de los campos de texto en toda la app
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade800, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        //! Pantalla inicial: LoginPage para autenticación
        home: const LoginPage(),
        //! Definición de rutas para navegación
        routes: {
          //! Ruta al convertidor de divisas después de autenticarse
          '/converter': (context) => const CurrencyConverterScreen(),
        },
      ),
    );
  }
}

