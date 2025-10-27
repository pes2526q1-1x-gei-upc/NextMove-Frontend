import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';

class EditUserDataPreferencesPage extends StatefulWidget {
  const EditUserDataPreferencesPage({super.key});

  @override
  State<EditUserDataPreferencesPage> createState() =>
      _EditUserDataPreferencesPageState();
}

class _EditUserDataPreferencesPageState
    extends State<EditUserDataPreferencesPage> {
  late TextEditingController _apodoController;
  late TextEditingController _nombreCompletoController; 
  late TextEditingController _numeroTelefonoController;
  late TextEditingController _descripcionController;
  String _idiomaPreferido = "Español";
  String _modoPreferido = "Coche";
  UserData? _currentUserData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _apodoController = TextEditingController();
    _nombreCompletoController = TextEditingController(); 
    _numeroTelefonoController = TextEditingController();
    _descripcionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userData = fetchUserDataPreferencesFromProvider(context);

    if (userData != null) {
      setState(() {
        _currentUserData = userData;
        _apodoController.text = userData.apodo;
        _nombreCompletoController.text = userData.nombreCompleto; 
        _numeroTelefonoController.text = userData.numeroTelefono.toString();
        _descripcionController.text = userData.descripcion;
        _idiomaPreferido = userData.idiomaPreferido.isNotEmpty
            ? userData.idiomaPreferido
            : "Español";
        _modoPreferido = userData.modoPreferido;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _apodoController.dispose();
    _nombreCompletoController.dispose(); 
    _numeroTelefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_currentUserData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No hay datos de usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedData = UserData(
      apodo: _apodoController.text,
      nombreCompleto:
          _nombreCompletoController.text, 
      fechaNacimiento: _currentUserData!.fechaNacimiento,
      fechaRegistro: _currentUserData!.fechaRegistro,
      numeroTelefono: int.tryParse(_numeroTelefonoController.text) ?? 0,
      idiomaPreferido: _idiomaPreferido,
      descripcion: _descripcionController.text,
      modoPreferido: _modoPreferido,
    );

    try {
      // Llamar a la capa de dominio para actualizar
      await updateUserDataPreferences(updatedData, context);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cambios guardados correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla anterior
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Editar Perfil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUserData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Editar Perfil')),
        body: Center(
          child: Text('No se pudieron cargar los datos del usuario'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar (no editable por ahora)
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(
                      'assets/Profile_avatar_placeholder_large.png',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 20,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Apodo
            TextField(
              controller: _apodoController,
              decoration: InputDecoration(
                labelText: 'Apodo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // Nombre completo
            TextField(
              controller: _nombreCompletoController, 
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
                enabled:
                    true, // TODO: decidir si queremos que este campo sea editable? (true o false) 
              ),
            ),
            SizedBox(height: 16),

            // Número de teléfono
            TextField(
              controller: _numeroTelefonoController,
              decoration: InputDecoration(
                labelText: 'Número de Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Idioma preferido
            DropdownButtonFormField<String>(
              value: _idiomaPreferido,
              decoration: InputDecoration(
                labelText: 'Idioma Preferido',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              items: ['Español', 'English', 'Català']
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _idiomaPreferido = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Modo preferido
            DropdownButtonFormField<String>(
              value: _modoPreferido,
              decoration: InputDecoration(
                labelText: 'Modo Preferido',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: ['Coche', 'Bicicleta']
                  .map(
                    (mode) => DropdownMenuItem(value: mode, child: Text(mode)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _modoPreferido = value;
                  });
                }
              },
            ),
            SizedBox(height: 24),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.save),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
