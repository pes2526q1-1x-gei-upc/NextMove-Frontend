import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_home_page.dart';


class UserDataPreferencesPage extends StatefulWidget {
  const UserDataPreferencesPage({super.key});

  @override
  State<UserDataPreferencesPage> createState() => _UserDataPreferencesPageState();
}

class _UserDataPreferencesPageState extends State<UserDataPreferencesPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late final TextEditingController _apodoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _fechaNacimientoController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _nombreCompletoController;

  // Imagen
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  final AssetImage _avatarImage = const AssetImage('assets/Profile_avatar_placeholder_large.png');

  // Dropdowns
  String? _selectedIdioma;
  String? _selectedModo;

  final List<String> _idiomas = ['Español', 'English', 'Català'];
  final List<String> _modos = ['Bici', 'Coche'];

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _telefonoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _descripcionController = TextEditingController();
    _nombreCompletoController = TextEditingController();

    // Carga inicial via BLoC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        context.read<UserBloc>().add(LoadUserProfile(user!.email!));
      }
    });
  }

  @override
  void dispose() {
    _apodoController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    _descripcionController.dispose();
    _nombreCompletoController.dispose();
    super.dispose();
  }

  // === Date Picker ===
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // === Image Picker ===
  void _showImageSourceActionSheet() {
    final l10n = AppLocalizations.of(context)!;
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
      final XFile? pickedFile = await _picker.pickImage(
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

  // === Guardar y Finalizar Onboarding ===
  void _finalizarOnboarding(UserEntity currentUser) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.formError)),
      );
      return;
    }

    final updatedUser = currentUser.copyWith(  // Asume copyWith en UserEntity
      apodo: _apodoController.text.trim(),
      nombreCompleto: _nombreCompletoController.text.trim(),
      fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
      numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
      idiomaPreferido: _selectedIdioma ?? 'Español',
      descripcion: _descripcionController.text.trim(),
      modoPreferido: _selectedModo ?? 'Coche',
      needsToRegister: false,
    );

    context.read<UserBloc>().add(UpdateUserProfile(updatedUser));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.userDataPreferences,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is UserUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.saveChangesFeedback)),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MapHomePage()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoaded || state is UserUpdated) {
              final user = (state is UserLoaded ? state.user : (state as UserUpdated).user);
              // Prellena controllers si no lo están (solo primera vez)
              if (_apodoController.text.isEmpty) {
                _apodoController.text = user.apodo;
                _nombreCompletoController.text = user.nombreCompleto;
                _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(user.fechaNacimiento);
                _telefonoController.text = user.numeroTelefono == 0 ? '' : user.numeroTelefono.toString();
                _descripcionController.text = user.descripcion;
                _selectedIdioma = user.idiomaPreferido;
                _selectedModo = user.modoPreferido;
              }
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
                                  child: const Icon(Icons.edit, size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Apodo
                      TextFormField(
                        controller: _apodoController,
                        decoration: InputDecoration(
                          labelText: l10n.nickname,
                          border: const OutlineInputBorder(),
                          hintText: l10n.nicknameHint,
                        ),
                        validator: (v) => v?.trim().isEmpty ?? true ? l10n.mandatoryNickname : null,
                      ),
                      const SizedBox(height: 16),

                      // Nombre Completo
                      TextFormField(
                        controller: _nombreCompletoController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v?.trim().isEmpty ?? true ? l10n.mandatoryFullName : null,
                      ),
                      const SizedBox(height: 16),

                      // Fecha Nacimiento
                      TextFormField(
                        controller: _fechaNacimientoController,
                        decoration: InputDecoration(
                          labelText: l10n.birthdate,
                          border: const OutlineInputBorder(),
                          hintText: l10n.bithdateHint,
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (v) => v?.isEmpty ?? true ? l10n.mandatoryBirthDate : null,
                      ),
                      const SizedBox(height: 16),

                      // Teléfono
                      TextFormField(
                        controller: _telefonoController,
                        decoration: InputDecoration(
                          labelText: l10n.telephoneNumber,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v) ? null : l10n.invalidPhoneNumber;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        decoration: InputDecoration(
                          labelText: l10n.userDescription,
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),

                      // Modo e Idioma
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedModo,
                              decoration: InputDecoration(
                                labelText: l10n.preferredMode,
                                border: const OutlineInputBorder(),
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              validator: (v) => v == null ? l10n.mandatoryPreferredMode : null,
                              items: _modos.map((m) {
                                final icon = m == 'Bici' ? Icons.directions_bike : Icons.electric_car;
                                return DropdownMenuItem(
                                  value: m,
                                  child: Row(children: [
                                    Icon(icon, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 12),
                                    Text(m),
                                  ]),
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
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _idiomas
                                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedIdioma = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Botón Finalizar
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _finalizarOnboarding(user),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                          ),
                          child: Text(
                            'Finalizar Registro',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('Error al cargar datos de usuario'));
          },
        ),
      ),
    );
  }
}