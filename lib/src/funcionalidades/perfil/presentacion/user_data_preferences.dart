import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class UserDataPreferences extends StatefulWidget {
  const UserDataPreferences({super.key});

  @override
  State<UserDataPreferences> createState() => _UserDataPreferencesState();
}

class _UserDataPreferencesState extends State<UserDataPreferences> {
  final TextEditingController _apodoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();

  String _fechaNacimiento = '1990-01-01'; // Hay que pillar la fecha de naciomiento de Google si no, será null y tendra que añadirla manualmente
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.userDataPreferences,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/Profile_avatar_placeholder_large.png'),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _apodoController,
              decoration: InputDecoration(
                labelText: 'Apodo *',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Fecha de nacimiento (editable con teclado de fechas)
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento (YYYY-MM-DD)', //Pasar a diferentes idiomas
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 1990-01-01', //Pasar a diferentes idiomas
                ),
                keyboardType: TextInputType.datetime, // Teclado exclusivo para fechas
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La fecha de nacimiento es obligatoria'; //Pasar a diferentes idiomas
                  }
                  try {
                    DateTime.parse(value); // Valida formato YYYY-MM-DD
                    return null;
                  } catch (e) {
                    return 'Formato de fecha inválido. Usa YYYY-MM-DD';   //Pasar a diferentes idiomas
                  }
                },
              ),
              SizedBox(height: 16),
              
            //Teléfono
            TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  labelText: 'Teléfono', //Pasar a diferentes idiomas
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}