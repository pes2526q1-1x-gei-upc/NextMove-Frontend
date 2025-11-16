import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/presentacion/edit_user_data_preferences_page.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({Key? key}) : super(key: key);

  void _navigateToEditUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditUserDataPreferences()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToEditUser(context),
        child: const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.grey, size: 28),
        ),
      ),
    );
  }
}
