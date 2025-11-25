import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// === IMPORTS DE WIDGETS DE ESTILO ===
// Asegúrate de que estos widgets existan en tu proyecto tal como en la página de edición
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';

// === OTROS IMPORTS ===
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/locale_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:provider/provider.dart';

class UserDataPreferencesPage extends StatefulWidget {
  const UserDataPreferencesPage({super.key});

  @override
  State<UserDataPreferencesPage> createState() =>
      _UserDataPreferencesPageState();
}

class _UserDataPreferencesPageState extends State<UserDataPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Variable local para controlar la carga de Firebase antes de llamar al Bloc
  bool _isCreatingFirebaseUser = false;

  late final TextEditingController _apodoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _fechaNacimientoController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _nombreCompletoController;

  File? _selectedImageFile;
  final AssetImage _avatarImage = const AssetImage(
    'assets/Profile_avatar_placeholder_large.png',
  );

  final ImagePicker _picker = ImagePicker();

  // Dropdowns
  String? _selectedIdioma = 'Español'; 
  String? _selectedModo = 'Coche';     

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
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

  // === Finalizar Registro ===
  Future<void> _finalizarOnboarding() async {
    var l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.formError)));
      return;
    }

    setState(() => _isCreatingFirebaseUser = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      UserEntity newUser;

      if (firebaseUser != null) {
        newUser = UserEntity(
          email: firebaseUser.email!,
          apodo: _apodoController.text.trim(),
          nombreCompleto: _nombreCompletoController.text.trim(),
          fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
          fechaRegistro: DateTime.now(),
          numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
          idiomaPreferido: _selectedIdioma ?? 'Español',
          descripcion: _descripcionController.text.trim(),
          modoPreferido: _selectedModo ?? 'Coche',
          photo: '',
        );
      } else {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final String? emailProvider = userProvider.email;
        final String? pwdProvider = userProvider.pwd;

        if (emailProvider == null || pwdProvider == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorOccurred("No hay credenciales."))),
          );
          return;
        }

        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailProvider,
          password: pwdProvider,
        );

        final createdFirebaseUser = userCredential.user;
        if (createdFirebaseUser == null) throw Exception("Error creando usuario en Firebase");

        newUser = UserEntity(
          email: createdFirebaseUser.email!,
          apodo: _apodoController.text.trim(),
          nombreCompleto: _nombreCompletoController.text.trim(),
          fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
          fechaRegistro: DateTime.now(),
          numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
          idiomaPreferido: _selectedIdioma ?? 'Español',
          descripcion: _descripcionController.text.trim(),
          modoPreferido: _selectedModo ?? 'Coche',
          photo: '',
        );
      }

      if (mounted) {
        context.read<UserBloc>().add(CreateUserProfile(newUser));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isCreatingFirebaseUser = false);
      String errorMsg = 'Error de registro';
      if (e.code == 'weak-password') errorMsg = 'La contraseña es muy débil.';
      if (e.code == 'email-already-in-use') errorMsg = 'El email ya está en uso.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isCreatingFirebaseUser = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Método auxiliar para el estilo de input limpio dentro de Cards
  InputDecoration _buildInputDecoration(String label, IconData icon, {bool showBorder = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: showBorder ? const OutlineInputBorder() : InputBorder.none, 
      enabledBorder: showBorder ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)) : InputBorder.none,
      focusedBorder: showBorder ? OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)) : InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async => !_isCreatingFirebaseUser,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7), // Fondo estilo EditPage
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F7),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, // Controlamos manual
          leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () {
                  if (!_isCreatingFirebaseUser) Navigator.pop(context);
                },
              )
            : null,
          title: Text(
            l10n.userDataPreferences,
            style: const TextStyle(
              fontSize: 24, // Ajustado para ser grande pero caber
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              setState(() => _isCreatingFirebaseUser = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is UserUpdated) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
              final firebaseUserNow = FirebaseAuth.instance.currentUser;
              
              userProvider.setUser(state.user.toMap(), firebaseUserId: firebaseUserNow?.uid, firebaseToken: null);
              
              localeProvider.setLocaleFromLanguage(state.user.idiomaPreferido);
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              });
            }
          },
          builder: (context, state) {
            if (_isCreatingFirebaseUser || state is UserLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.creatingYourAccount),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FOTO DE PERFIL ---
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
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // --- INFO PERSONAL ---
                    ProfileSectionLabel(text: l10n.personalInfo),
                    ProfileStyledCard(
                      children: [
                        // Apodo
                        TextFormField(
                          controller: _apodoController,
                          decoration: _buildInputDecoration(l10n.nickname, Icons.alternate_email_rounded),
                          validator: (v) => v?.trim().isEmpty ?? true ? l10n.mandatoryNickname : null,
                        ),
                        const Divider(height: 1, indent: 40), // Divisor interno
                        
                        // Nombre Completo
                        TextFormField(
                          controller: _nombreCompletoController,
                          decoration: _buildInputDecoration(l10n.fullName, Icons.person_outline_rounded),
                          validator: (v) => v?.trim().isEmpty ?? true ? l10n.mandatoryFullName : null,
                        ),
                        const Divider(height: 1, indent: 40),

                        // Fecha Nacimiento
                        TextFormField(
                          controller: _fechaNacimientoController,
                          decoration: _buildInputDecoration(l10n.birthdate, Icons.cake_outlined),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (v) => v?.isEmpty ?? true ? l10n.mandatoryBirthDate : null,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // --- CONTACTO Y BIO ---
                    ProfileSectionLabel(text: l10n.contactAndBioInfo), // Usamos una key parecida o genérica
                    ProfileStyledCard(
                      children: [
                        // Teléfono
                        TextFormField(
                          controller: _telefonoController,
                          decoration: _buildInputDecoration(l10n.telephoneNumber, Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v) ? null : l10n.invalidPhoneNumber;
                          },
                        ),
                        const Divider(height: 1, indent: 40),
                        
                        // Descripción
                        TextFormField(
                          controller: _descripcionController,
                          decoration: _buildInputDecoration(l10n.userDescription, Icons.notes_rounded),
                          maxLines: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- PREFERENCIAS ---
                    ProfileSectionLabel(text: 
                    "Preferencias"),
                    ProfileStyledCard(
                      children: [
                        // SOLUCIÓN RENDERFLEX: Usar Row con Expanded
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedModo,
                                decoration: InputDecoration(
                                  labelText: l10n.preferredMode,
                                  prefixIcon: Icon(
                                    _selectedModo == 'Bici' ? Icons.directions_bike : Icons.electric_car,
                                    color: Colors.grey
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                validator: (v) => v == null ? l10n.mandatoryPreferredMode : null,
                                items: _modos.map((m) {
                                  return DropdownMenuItem(
                                    value: m,
                                    child: Text(m, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedModo = v),
                              ),
                            ),
                            
                            // Divisor vertical sutil
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),

                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedIdioma,
                                decoration: InputDecoration(
                                  labelText: l10n.preferredLanguage,
                                  prefixIcon: const Icon(Icons.language, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                items: _idiomas
                                    .map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14))))
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedIdioma = v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),

                    // --- BOTÓN FINALIZAR ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _finalizarOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: Text(
                          l10n.finishRegistration,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}