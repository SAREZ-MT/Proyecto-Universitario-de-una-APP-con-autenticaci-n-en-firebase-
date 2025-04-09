import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication/auth_provider.dart';

//! PANTALLA DE LOGIN Y REGISTRO
//! Esta clase implementa la interfaz de usuario para autenticación
//! Contiene dos formularios con sistema de pestañas para alternar entre ellos

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  //! Controlador para manejar las pestañas de login y registro
  late TabController _tabController;
  
  //! Variables para controlar la visibilidad de las contraseñas
  bool _obscureLoginPassword = true;      //* Para ocultar/mostrar contraseña de login
  bool _obscureRegisterPassword = true;   //* Para ocultar/mostrar contraseña de registro
  bool _obscureConfirmPassword = true;    //* Para ocultar/mostrar confirmación de contraseña
  
  //! Controladores para los campos de texto de Login
  //* Permiten acceder y manipular el texto ingresado por el usuario
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  //! Controladores para los campos de texto de Registro
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  //! Keys para los formularios (necesarios para la validación)
  //* Permiten identificar y validar los formularios de login y registro
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //! Inicializar el controlador de pestañas con 2 tabs (login y registro)
    _tabController = TabController(length: 2, vsync: this);
    //! Configurar listener para detectar cambios de pestaña
    _tabController.addListener(_handleTabChange);
  }

  //! Variable para almacenar la altura actual del formulario (cambia según la pestaña)
  double _formHeight = 300; // Altura inicial para el login

  //! Función que se ejecuta cuando el usuario cambia de pestaña
  //* Ajusta la altura del contenedor para acomodar el formulario activo
  void _handleTabChange() {
    if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
      setState(() {
        //! Ajustar altura según la pestaña: login (300) o registro (430)
        _formHeight = _tabController.index == 0 ? 300 : 430;
      });
    }
  }

  @override
  void dispose() {
    //! Liberar recursos cuando se destruye el widget
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //! VALIDACIÓN: Verifica formato correcto de email
  //! Retorna null si es válido o un mensaje de error si no lo es
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, introduce tu correo electrónico';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      //* Expresión regular para validar formato de email
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  //! VALIDACIÓN: Verifica que la contraseña cumpla requisitos mínimos
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, introduce tu contraseña';
    } else if (value.length < 6) {
      //* Firebase requiere mínimo 6 caracteres para contraseñas
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  //! VALIDACIÓN: Verifica que las contraseñas coincidan
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirma tu contraseña';
    } else if (value != _registerPasswordController.text) {
      //* Comparar con la contraseña original ingresada
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  //! AUTENTICACIÓN: Método para iniciar sesión de usuario existente
  Future<void> _signIn() async {
    //! Paso 1: Limpiar mensajes de error anteriores
    Provider.of<AuthProvider>(context, listen: false).clearError();

    //! Paso 2: Validar todos los campos del formulario
    if (_loginFormKey.currentState!.validate()) {
      //! Paso 3: Llamar al AuthProvider para autenticar con Firebase
      final success = await Provider.of<AuthProvider>(context, listen: false).signIn(
        email: _loginEmailController.text.trim(),  //* Eliminar espacios
        password: _loginPasswordController.text,
      );

      //! Paso 4: Si fue exitoso y el widget sigue montado, navegar al convertidor
      if (success && mounted) {
        //! Usar pushReplacement para que no pueda volver atrás
        Navigator.pushReplacementNamed(context, '/converter');
      }
      //* Si hay error, se mostrará automáticamente en la UI gracias al Provider
    }
  }

  //! AUTENTICACIÓN: Método para registrar un nuevo usuario
  Future<void> _signUp() async {
    //! Paso 1: Limpiar mensajes de error anteriores
    Provider.of<AuthProvider>(context, listen: false).clearError();

    //! Paso 2: Validar todos los campos del formulario
    if (_registerFormKey.currentState!.validate()) {
      //! Paso 3: Llamar al AuthProvider para registrar en Firebase
      final success = await Provider.of<AuthProvider>(context, listen: false).signUp(
        name: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      );

      //! Paso 4: Si fue exitoso, limpiar campos y cambiar a la pestaña de inicio de sesión
      if (success && mounted) {
        // Limpiar todos los campos del formulario de registro
        _registerNameController.clear();
        _registerEmailController.clear();
        _registerPasswordController.clear();
        _confirmPasswordController.clear();
        
        // Cambiar a la pestaña de inicio de sesión
        _tabController.animateTo(0);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registro exitoso. Por favor, inicia sesión con tus credenciales.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      //* Si hay error, se mostrará automáticamente en la UI
    }
  }

  @override
  Widget build(BuildContext context) {
    // ! Importante: Acceso al proveedor de autenticación para controlar el estado
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo o Ícono
                    Icon(
                      Icons.currency_exchange,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    
                    // Título de la aplicación
                    Text(
                      'Convertidor de Divisas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // ! Importante: Mostrar mensajes de error de autenticación
                    if (authProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Card para el formulario
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // TabBar para alternar entre login y registro
                            TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.blue.shade700,
                              labelColor: Colors.blue.shade900,
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Registrarse',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // TabBarView con los formularios
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: _formHeight,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginForm(authProvider),
                                  _buildRegisterForm(authProvider),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Acceso como invitado
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(context, '/converter');
                            },
                      icon: Icon(Icons.person_outline, color: Colors.white),
                      label: Text(
                        'Acceder como invitado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el formulario de inicio de sesión
  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de correo electrónico
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            enabled: !authProvider.isLoading,
          ),
          const SizedBox(height: 15),
          
          // Campo de contraseña
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            enabled: !authProvider.isLoading,
          ),
          const SizedBox(height: 15),
          
          // Botón de olvidaste tu contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      // Mostrar diálogo para introducir correo
                      final TextEditingController emailController =
                          TextEditingController();
                      final GlobalKey<FormState> formKey = GlobalKey<FormState>();

                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Restablecer contraseña'),
                          content: Form(
                            key: formKey,
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                hintText: 'Introduce tu correo electrónico',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(context, true);
                                }
                              },
                              child: Text('Enviar'),
                            ),
                          ],
                        ),
                      );

                      // Si se confirma, enviar correo de restablecimiento
                      if (result == true) {
                        await authProvider.resetPassword(emailController.text.trim());
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Si el correo existe, recibirás un enlace para restablecer tu contraseña',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.blue.shade800),
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Botón de iniciar sesión
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: authProvider.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget para el formulario de registro
  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de nombre
          TextFormField(
            controller: _registerNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, introduce tu nombre';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            enabled: !authProvider.isLoading,
          ),
          const SizedBox(height: 15),
          
          // Campo de correo electrónico
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            enabled: !authProvider.isLoading,
          ),
          const SizedBox(height: 15),
          
          // Campo de contraseña
          TextFormField(
            controller: _registerPasswordController,
            obscureText: _obscureRegisterPassword,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureRegisterPassword = !_obscureRegisterPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            enabled: !authProvider.isLoading,
          ),
          const SizedBox(height: 15),
          
          // Campo de confirmación de contraseña
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            enabled: !authProvider.isLoading,
          ),
          const SizedBox(height: 25),
          
          // Botón de registro
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: authProvider.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}