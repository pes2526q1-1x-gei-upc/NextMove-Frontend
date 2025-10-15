import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class UserDataPreferences extends StatefulWidget {
  const UserDataPreferences({super.key});

  @override
  State<UserDataPreferences> createState() => _UserDataPreferencesState();
}

class _UserDataPreferencesState extends State<UserDataPreferences> {
  final TextEditingController _apodoController = TextEditingController();

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
            )
          ],
        ),
      ),
    );
  }
}