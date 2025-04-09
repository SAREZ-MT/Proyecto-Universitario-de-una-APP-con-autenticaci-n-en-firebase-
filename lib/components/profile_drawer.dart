import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentication/auth_provider.dart' as app;

//! DRAWER DE PERFIL DE USUARIO
//! Este widget muestra la información del perfil del usuario y opciones adicionales
//! Se utiliza como menú lateral en la pantalla principal

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app.AuthProvider>(context);
    final User? firebaseUser = authProvider.user;
    
    return Drawer(
      child: Column(
        children: [
          // Encabezado del drawer con información del usuario
          FutureBuilder<Map<String, dynamic>?>(
            future: firebaseUser != null ? authProvider.getUserData() : null,
            builder: (context, snapshot) {
              // Mostrar datos del perfil
              String userName = 'Usuario invitado';
              String userEmail = 'Sin cuenta registrada';
              
              if (firebaseUser != null) {
                userEmail = firebaseUser.email ?? 'Email no disponible';
                
                // Si tenemos datos de Firestore, usamos el nombre almacenado
                if (snapshot.hasData && snapshot.data != null) {
                  userName = snapshot.data!['name'] ?? 'Usuario';
                } else {
                  // Si no hay datos o están cargando, usar displayName de Firebase Auth
                  userName = firebaseUser.displayName ?? 'Usuario';
                }
              }
              
              return UserAccountsDrawerHeader(
                accountName: Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                ),
              );
            },
          ),
          
          // Opciones del menú
          if (firebaseUser != null) ...[
            // Solo mostrar estas opciones si el usuario está autenticado
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context); // Cerrar el drawer
                // Aquí se podría navegar a una pantalla de perfil detallado
              },
            ),
            
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Historial de Conversiones'),
              onTap: () {
                Navigator.pop(context); // Cerrar el drawer
                // Aquí se podría navegar a un historial de conversiones
              },
            ),
            
            Divider(),
            
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context); // Cerrar el drawer
                await authProvider.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ] else ...[
            // Opciones para usuario invitado
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Iniciar Sesión'),
              onTap: () {
                Navigator.pop(context); // Cerrar el drawer
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
          
          Spacer(), // Empuja el contenido siguiente hacia abajo
          
          // Pie de página con información de la app
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(),
                SizedBox(height: 8),
                Text(
                  'Convertidor de Divisas v1.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '© 2023 - Todos los derechos reservados',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 