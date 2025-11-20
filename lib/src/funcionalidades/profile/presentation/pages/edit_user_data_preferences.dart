import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/locale_provider.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/user_data_preferences_page.dart';
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

  // Controladores
  late final TextEditingController _apodoController;
  late final TextEditingController _nombreCompletoController;
  late final TextEditingController _fechaNacimientoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _descripcionController;

  // Imagen
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  final AssetImage _avatarImage = const AssetImage(
    'assets/Profile_avatar_placeholder_large.png',
  );

  // Dropdowns
  String? _selectedIdioma;
  String? _selectedModo;

  final List<String> _idiomas = ['Español', 'English', 'Català'];

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _nombreCompletoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _telefonoController = TextEditingController();
    _descripcionController = TextEditingController();

    // Carga inicial via BLoC
    debugPrint("Cargando perfil de usuario para edición...");
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

  // === Image Picker ===
  void _showImageSourceActionSheet() {
    var l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedImageFile = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.imagePickerError)),
      );
    }
  }

  // === Guardar Cambios ===
  void _saveChanges(BuildContext context, UserEntity currentUser) {
    var l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.formError)),
      );
      return;
    }

    // Print all fields
    debugPrint('User Profile Fields:');
    debugPrint('Apodo: ${_apodoController.text}');
    debugPrint('Nombre Completo: ${_nombreCompletoController.text}');
    debugPrint('Fecha de Nacimiento: ${_fechaNacimientoController.text}');
    debugPrint('Teléfono: ${_telefonoController.text}');
    debugPrint('Descripción: ${_descripcionController.text}');
    debugPrint('Idioma Preferido: $_selectedIdioma');
    debugPrint('Modo Preferido: $_selectedModo');

    final updatedUser = currentUser.copyWith(
      numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
      descripcion: _descripcionController.text.trim(),
      idiomaPreferido: _selectedIdioma ?? currentUser.idiomaPreferido,
      modoPreferido: _selectedModo == l10n.bicycle ? "BIKE" : "CAR",
    );

    context.read<UserBloc>().add(UpdateUserProfile(updatedUser));
  }

  // === Cerrar Sesión ===
  Future<void> _onLogoutPressed() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Mostrar diálogo de confirmación
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.confirmLogOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // 2. Disparar evento al BLoC si confirma
    if (confirm == true && mounted) {
      context.read<UserBloc>().add(LogoutUser());
    }
  }

  void _goBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: Text(
          l10n.editProfile,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            // Update provider with newly updated user to avoid races
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            final localeProvider = Provider.of<LocaleProvider>(
              context,
              listen: false,
            );
            final firebaseUser = FirebaseAuth.instance.currentUser;
            // Set provider synchronously first
            userProvider.setUser(
              state.user.toMap(),
              firebaseUserId: firebaseUser?.uid,
              firebaseToken: null,
            );
            // Fetch token and update provider asynchronously
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
            // Navigator.pop(context);
          } else if (state is UserLoggedOut) {
            // Navigate to welcome page
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
          } else if (state is UserNeedsToSignUp) {
            return UserDataPreferencesPage();
          } else if (state is UserLoaded || state is UserUpdated) {
            final user = (state is UserLoaded
                ? state.user
                : (state as UserUpdated).user);
            var l10n = AppLocalizations.of(context)!;
            // Prellena controllers si no lo están
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
            }
            _selectedModo = user.modoPreferido == "BIKE" ? l10n.bicycle : l10n.car;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto (igual)
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceActionSheet,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _selectedImageFile != null
                                  ? FileImage(_selectedImageFile!)
                                  : _avatarImage,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _apodoController,
                      enabled: false,
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: l10n.nicknameNonEditable,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nombreCompletoController,
                      enabled: false,
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _fechaNacimientoController,
                      enabled: false,
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: l10n.birthdate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _telefonoController,
                      decoration: InputDecoration(
                        labelText: l10n.telephoneNumber,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
                        return phoneRegExp.hasMatch(value)
                            ? null
                            : l10n.invalidPhoneNumber;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: l10n.userDescription,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedModo,
                            decoration: InputDecoration(
                              labelText: l10n.preferredMode,
                              border: const OutlineInputBorder(),
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                            validator: (v) =>
                                v == null ? l10n.mandatoryPreferredMode : null,
                            items: StationType.values.map((modo) {
                              final icon = modo == StationType.bicycle
                                  ? Icons.directions_bike
                                  : Icons.electric_car;
                              return DropdownMenuItem(
                                value: modo == StationType.bicycle
                                    ? l10n.bicycle
                                    : l10n.car,
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      modo == StationType.bicycle
                                          ? l10n.bicycle
                                          : l10n.car,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedModo = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedIdioma,
                            decoration: InputDecoration(
                              labelText: l10n.preferredLanguage,
                              border: const OutlineInputBorder(),
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                            items: _idiomas
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(
                                      i,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedIdioma = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: ElevatedButton(
                        onPressed: () => _saveChanges(context, user),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          l10n.saveChanges,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // === Botón de Cerrar Sesión ===
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 10),

                    Center(
                      child: TextButton.icon(
                        onPressed: _onLogoutPressed,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          'Cerrar Sesión',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
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
