import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_home_page.dart';

class UserDataPreferences extends StatefulWidget {
  const UserDataPreferences({super.key});

  @override
  State<UserDataPreferences> createState() => _UserDataPreferencesState();
}

class _UserDataPreferencesState extends State<UserDataPreferences> {
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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _telefonoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _descripcionController = TextEditingController();
    _nombreCompletoController = TextEditingController();

    // Solo prellenamos con datos de Firebase Auth (si existen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = userProvider.user;

      if (userData != null && userData['name'] != null) {
        setState(() {
          _nombreCompletoController.text = userData['name'];
          // Opcional: usar email como apodo inicial
          // _apodoController.text = userData['email']?.split('@').first ?? '';
        });
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
      setState(() {
        _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
  Future<void> _finalizarOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.formError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseUserId = userProvider.firebaseUserId;

    if (firebaseUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final userData = UserData(
      apodo: _apodoController.text.trim(),
      nombreCompleto: _nombreCompletoController.text.trim(),
      fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
      fechaRegistro: DateTime.now(),
      numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
      idiomaPreferido: _selectedIdioma ?? 'Español',
      descripcion: _descripcionController.text.trim(),
      modoPreferido: _selectedModo ?? 'Coche',
    );

    try {
      await updateUserDataPreferences(userData, context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveChangesFeedback)),
        );

        // Limpiar stack y ir al home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MapHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            //content: Text('Error al guardar: $e'),
            content : Text(AppLocalizations.of(context)!.saveChangesError + ' $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false, // Evitar retroceder
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.userDataPreferences,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto
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
                          labelText: AppLocalizations.of(context)!.telephoneNumber,
                          border: OutlineInputBorder(),
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
                          labelText: AppLocalizations.of(context)!.userDescription,
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
                          onPressed: _isLoading ? null : _finalizarOnboarding,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  'Finalizar Registro',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}