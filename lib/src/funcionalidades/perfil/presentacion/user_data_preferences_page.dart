import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/presentacion/edit_user_data_preferences_page.dart';

class UserDataPreferencesPage extends StatelessWidget {
  const UserDataPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = fetchUserDataPreferencesFromProvider(context);
    final firebaseUserId = userProvider.firebaseUserId;

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil de Usuario')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos del usuario...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserDataPreferencesPage(),
                ),
              );
            },
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                  'assets/Profile_avatar_placeholder_large.png',
                ),
              ),
            ),
            SizedBox(height: 24),

            // Firebase User ID
            if (firebaseUserId != null)
              _buildInfoCard(
                'Firebase User ID',
                firebaseUserId,
                Icons.fingerprint,
              ),
            SizedBox(height: 12),

            // Apodo
            _buildInfoCard('Apodo', userData.apodo, Icons.person),
            SizedBox(height: 12),

            // Nombre completo
            _buildInfoCard(
              'Nombre Completo',
              userData.nombreCompleto,
              Icons.badge,
            ),
            SizedBox(height: 12),

            // Fecha de nacimiento
            _buildInfoCard(
              'Fecha de Nacimiento',
              '${userData.fechaNacimiento.day}/${userData.fechaNacimiento.month}/${userData.fechaNacimiento.year}',
              Icons.cake,
            ),
            SizedBox(height: 12),

            // Teléfono
            _buildInfoCard(
              'Número de Teléfono',
              userData.numeroTelefono.toString(),
              Icons.phone,
            ),
            SizedBox(height: 12),

            // Idioma
            _buildInfoCard(
              'Idioma Preferido',
              userData.idiomaPreferido.isEmpty
                  ? 'No especificado'
                  : userData.idiomaPreferido,
              Icons.language,
            ),
            SizedBox(height: 12),

            // Modo preferido
            _buildInfoCard(
              'Modo Preferido',
              userData.modoPreferido,
              Icons.directions_car,
            ),
            SizedBox(height: 12),

            // Descripción
            if (userData.descripcion.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, size: 28, color: Colors.blue),
                          SizedBox(width: 16),
                          Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        userData.descripcion,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}