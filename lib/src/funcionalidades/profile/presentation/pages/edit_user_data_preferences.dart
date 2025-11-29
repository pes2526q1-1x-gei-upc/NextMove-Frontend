import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Widgets
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/save_changes_button_widget.dart';

// Otros Imports
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/locale_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';

class EditUserDataPreferencesPage extends StatefulWidget {
  const EditUserDataPreferencesPage({super.key});

  @override
  State<EditUserDataPreferencesPage> createState() =>
      _EditUserDataPreferencesPageState();
}

class _EditUserDataPreferencesPageState
    extends State<EditUserDataPreferencesPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _apodoController;
  late final TextEditingController _nombreCompletoController;
  late final TextEditingController _fechaNacimientoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _descripcionController;

  File? _selectedImageFile;
  final AssetImage _avatarImage = const AssetImage(
    'assets/Profile_avatar_placeholder_large.png',
  );

  String? _selectedIdioma;
  String? _selectedModoUI;
  String? _selectedModeAPI;

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _nombreCompletoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _telefonoController = TextEditingController();
    _descripcionController = TextEditingController();
    if (kDebugMode) {
      print("Cargando perfil de usuario para edición...");
    }
  }

  @override
  void dispose() {
    _apodoController.dispose();
    _nombreCompletoController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _goBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: _goBack,
        ),
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserUpdated) {
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );

            final localeProvider = Provider.of<LocaleProvider>(
              context,
              listen: false,
            );
            final firebaseUser = FirebaseAuth.instance.currentUser;

            userProvider.setUser(
              state.user.toMap(),
              firebaseUserId: firebaseUser?.uid,
              firebaseToken: null,
            );

            () async {
              final token = firebaseUser == null
                  ? null
                  : await firebaseUser.getIdToken();
              userProvider.setUser(
                state.user.toMap(),
                firebaseUserId: firebaseUser?.uid,
                firebaseToken: token,
              );
            }();

            localeProvider.setLocaleFromLanguage(state.user.idiomaPreferido);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final updatedL10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(updatedL10n.saveChangesFeedback),
                  backgroundColor: Colors.green,
                ),
              );
            });
          } else if (state is UserLoggedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => AuthBloc(),
                  child: const WelcomePage(),
                ),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded || state is UserUpdated) {
            final user = (state is UserLoaded
                ? state.user
                : (state as UserUpdated).user);

            if (_apodoController.text.isEmpty) {
              _apodoController.text = user.apodo;
              _nombreCompletoController.text = user.nombreCompleto;
              _fechaNacimientoController.text = DateFormat(
                'yyyy-MM-dd',
              ).format(user.fechaNacimiento);
              _telefonoController.text = user.numeroTelefono == 0
                  ? ''
                  : user.numeroTelefono.toString();
              _descripcionController.text = user.descripcion;
              _selectedIdioma = user.idiomaPreferido;
              _selectedModeAPI = UserEntity.mapPreferredModeToAPI(
                user.modoPreferido,
              );
            }
            _selectedModoUI = _selectedModeAPI == "BIKE"
                ? l10n.bicycle
                : l10n.car;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatarSelector(
                      selectedImageFile: _selectedImageFile,
                      imageUrl: user.photo,
                      defaultImage: _avatarImage,
                      onImagePicked: (File newFile) {
                        setState(() {
                          _selectedImageFile = newFile;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    ProfileSectionLabel(text: l10n.personalInfo),
                    ProfileStyledCard(
                      children: [
                        // Apodo
                        ProfileStyledTextField(
                          controller: _apodoController,
                          label: l10n.nicknameNonEditable,
                          icon: Icons.alternate_email_rounded,
                          readOnly: true,
                          showDivider: true,
                        ),
                        // Nombre completo
                        ProfileStyledTextField(
                          controller: _nombreCompletoController,
                          label: l10n.fullName,
                          icon: Icons.person_outline_rounded,
                          readOnly: true,
                          showDivider: true,
                        ),
                        // Fecha de nacimiento
                        ProfileStyledTextField(
                          controller: _fechaNacimientoController,
                          label: l10n.birthdate,
                          icon: Icons.cake_outlined,
                          readOnly: true,
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ProfileSectionLabel(text: l10n.contactAndBioInfo),
                    ProfileStyledCard(
                      children: [
                        // Numero telefono
                        ProfileStyledTextField(
                          controller: _telefonoController,
                          label: l10n.telephoneNumber,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          showDivider: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
                            return phoneRegExp.hasMatch(value)
                                ? null
                                : l10n.invalidPhoneNumber;
                          },
                        ),
                        // Descripción
                        ProfileStyledTextField(
                          controller: _descripcionController,
                          label: l10n.userDescription,
                          icon: Icons.notes_rounded,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ProfileSectionLabel(text: l10n.preferredMode),
                    ProfileStyledCard(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedModoUI,
                          decoration: cardInputDecoration(
                            icon: _selectedModeAPI == "BIKE"
                                ? Icons.directions_bike
                                : Icons.electric_car,
                            context: context,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                          dropdownColor: Colors.white,
                          validator: (v) =>
                              v == null ? l10n.mandatoryPreferredMode : null,
                          items: StationType.values.map((modo) {
                            return DropdownMenuItem(
                              value: modo == StationType.bicycle
                                  ? l10n.bicycle
                                  : l10n.car,
                              child: Text(
                                modo == StationType.bicycle
                                    ? l10n.bicycle
                                    : l10n.car,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() {
                            _selectedModoUI = v;
                            _selectedModeAPI = v == l10n.bicycle
                                ? "BIKE"
                                : "CAR";
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    ProfileSaveButton(
                      formKey: _formKey,
                      currentUser: user,
                      telefonoController: _telefonoController,
                      descripcionController: _descripcionController,
                      selectedIdioma: _selectedIdioma,
                      selectedModeAPI: _selectedModeAPI,
                      selectedImageFile: _selectedImageFile,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text(l10n.errorLoadingProfile));
        },
      ),
    );
  }
}
