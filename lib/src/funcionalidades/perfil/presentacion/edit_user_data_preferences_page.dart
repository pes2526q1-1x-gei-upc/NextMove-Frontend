import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';

class EditUserDataPreferences extends StatefulWidget {
  const EditUserDataPreferences({super.key});

  @override
  State<EditUserDataPreferences> createState() => _EditUserDataPreferencesState();
}

class _EditUserDataPreferencesState extends State<EditUserDataPreferences> {
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
  final List<String> _modos = ['Bici', 'Coche'];

  UserData? _currentUserData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _nombreCompletoController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _telefonoController = TextEditingController();
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
        _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(userData.fechaNacimiento);
        _telefonoController.text = userData.numeroTelefono == 0 ? '' : userData.numeroTelefono.toString();
        _descripcionController.text = userData.descripcion;
        _selectedIdioma = userData.idiomaPreferido.isNotEmpty ? userData.idiomaPreferido : 'Español';
        _selectedModo = userData.modoPreferido;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
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

  // === Date Picker (no editable) ===
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
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

  // === Guardar Cambios ===
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.formError)),
      );
      return;
    }

    if (_currentUserData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Error: No hay datos de usuario'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedData = UserData(
      apodo: _apodoController.text.trim(),
      nombreCompleto: _nombreCompletoController.text.trim(),
      fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? _currentUserData!.fechaNacimiento,
      fechaRegistro: _currentUserData!.fechaRegistro,
      numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
      idiomaPreferido: _selectedIdioma ?? 'Español',
      descripcion: _descripcionController.text.trim(),
      modoPreferido: _selectedModo ?? 'Coche',
    );

    try {
      await updateUserDataPreferences(updatedData, context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveChangesFeedback), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUserData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: Center(child: Text("error al cargar datos de usuario")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
        title: Text(l10n.editProfile, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de perfil
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

              // Apodo (no editable)
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

              // Nombre Completo (no editable)
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

              // Fecha de Nacimiento (no editable)
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

              // Teléfono
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

              // Descripción
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
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      validator: (v) => v == null ? l10n.mandatoryPreferredMode : null,
                      items: _modos.map((modo) {
                        final icon = modo == 'Bici' ? Icons.directions_bike : Icons.electric_car;
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

              // Botón Guardar
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.saveChanges, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}