import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:provider/provider.dart';


class ProfileAvatarWidget extends StatelessWidget {
  final BuildContext context;
  const ProfileAvatarWidget({Key? key, required this.context}) : super(key: key);

  void _navigateToEditUser() {
    // 1. Lee el UserRepository
    String? userUID = Provider.of<UserProvider>(
      context,
      listen: false,
    ).firebaseUserId;

    // Navega, pero envolviendo la nueva página con el BlocProvider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => UserBloc()
            // Carga los datos del perfil tan pronto como el BLoC es creado.
            ..add(LoadUserProfile(userUID!)),

          child: const EditUserDataPreferencesPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToEditUser(),
        child: const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.grey, size: 28),
        ),
      ),
    );
  }
}
