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

class EditUserDataPreferencesPage extends StatefulWidget {
  const EditUserDataPreferencesPage({super.key});

  @override
  State<EditUserDataPreferencesPage> createState() => _EditUserDataPreferencesPageState();
}

class _EditUserDataPreferencesPageState extends State<EditUserDataPreferencesPage> {
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
  final AssetImage _avatarImage = const AssetImage('assets/Profile_avatar_placeholder_large.png');

  // Dropdowns
  String? _selectedIdioma;
  String? _selectedModo;

  final List<String> _idiomas = ['Español', 'English', 'Català'];
  final List<String> _modos = ['Bicicleta', 'Coche'];

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _nombreCompletoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _telefonoController = TextEditingController();
    _descripcionController = TextEditingController();

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
    _nombreCompletoController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
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
      final pickedFile = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
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
  void _saveChanges(UserEntity currentUser) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.formError)),
      );
      return;
    }

    final updatedUser = currentUser.copyWith(
      numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
      descripcion: _descripcionController.text.trim(),
      idiomaPreferido: _selectedIdioma ?? currentUser.idiomaPreferido,
      modoPreferido: _selectedModo ?? currentUser.modoPreferido,
    );

    context.read<UserBloc>().add(UpdateUserProfile(updatedUser));
  }

  void _goBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
        title: Text(l10n.editProfile, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is UserUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.saveChangesFeedback), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded || state is UserUpdated) {
            final user = (state is UserLoaded ? state.user : (state as UserUpdated).user);
            // Prellena controllers si no lo están
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
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
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
                        return phoneRegExp.hasMatch(value) ? null : l10n.invalidPhoneNumber;
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
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            validator: (v) => v == null ? l10n.mandatoryPreferredMode : null,
                            items: _modos.map((modo) {
                              final icon = modo == 'Bicicleta' ? Icons.directions_bike : Icons.electric_car;
                              return DropdownMenuItem(
                                value: modo,
                                child: Row(
                                  children: [
                                    Icon(icon, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 12),
                                    Text(modo, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            items: _idiomas
                                .map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontWeight: FontWeight.w500))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedIdioma = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: ElevatedButton(
                        onPressed: () => _saveChanges(user),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: Text(l10n.saveChanges, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}