import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// === IMPORTS DE WIDGETS DE ESTILO ===
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

  // Image picker instance used in _pickImage
  final ImagePicker _picker = ImagePicker();

  // Dropdowns
  String? _selectedIdioma = 'Español'; // Valor por defecto para evitar nulos
  String? _selectedModo = 'Coche';     // Valor por defecto

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
    
    // NO cargamos usuario (LoadUserProfile) porque sabemos que es nuevo.
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

  // === Finalizar Registro: Firebase -> Backend ===
  Future<void> _finalizarOnboarding() async {
    var l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.formError)));
      return;
    }

    setState(() => _isCreatingFirebaseUser = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      UserEntity newUser;

      if (firebaseUser != null) {
        // User is already authenticated (Google sign-in), skip Firebase creation
        debugPrint("Usuario ya autenticado con Google: ${firebaseUser.email}");
        newUser = UserEntity(
          email: firebaseUser.email!,
          apodo: _apodoController.text.trim(),
          nombreCompleto: _nombreCompletoController.text.trim(),
          fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
          fechaRegistro: DateTime.now(), // Fecha actual de registro
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
            SnackBar(content: Text(l10n.errorOccurred("No hay credenciales pendientes de registro."))),
          );
          return;
        }

        // Crear usuario en Firebase Authentication
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailProvider,
          password: pwdProvider,
        );

        final createdFirebaseUser = userCredential.user;
        if (createdFirebaseUser == null) {
          throw Exception("Error creando usuario en Firebase");
        }

        debugPrint("Usuario Firebase creado: ${createdFirebaseUser.email}");
        debugPrint("Tenemos su contraseña y email desde el Provider, contraseña: $pwdProvider");
        newUser = UserEntity(
          email: createdFirebaseUser.email!,
          apodo: _apodoController.text.trim(),
          nombreCompleto: _nombreCompletoController.text.trim(),
          fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
          fechaRegistro: DateTime.now(), // Fecha actual de registro
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
      if (e.code == 'email-already-in-use') {
        errorMsg = 'El email ya está en uso.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isCreatingFirebaseUser = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error desconocido: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      // Bloqueamos volver atrás solo si se está creando el usuario (loading)
      onWillPop: () async => !_isCreatingFirebaseUser,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F7),
          elevation: 0,
          title: Text(
            l10n.userDataPreferences,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          centerTitle: true,
          // 1. CAMBIO: Permitimos que Flutter decida si mostrar la flecha
          automaticallyImplyLeading: true, 
          // 2. OPCIONAL: Personalizamos el botón de atrás si queremos estilo iOS
          leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () {
                  if (!_isCreatingFirebaseUser) {
                    Navigator.pop(context);
                  }
                },
              )
            : null, // Si no hay historial, no mostramos nada (o mostramos botón de salir si es modal)
        ),
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              setState(() => _isCreatingFirebaseUser = false);
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
              final firebaseUserNow = FirebaseAuth.instance.currentUser;
              userProvider.setUser(state.user.toMap(), firebaseUserId: firebaseUserNow?.uid, firebaseToken: null);
              () async {
                final token = firebaseUserNow == null
                    ? null
                    : await firebaseUserNow.getIdToken();
                userProvider.setUser(
                  state.user.toMap(),
                  firebaseUserId: firebaseUserNow?.uid,
                  firebaseToken: token,
                );
              }();
              
              localeProvider.setLocaleFromLanguage(state.user.idiomaPreferido);
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final updatedL10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(updatedL10n.saveChangesFeedback)),
                );
              });
              
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
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
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

                    // --- 4. PREFERENCIAS ---
                    ProfileSectionLabel(text: l10n.preferredMode),
                    ProfileStyledCard(
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

                    // --- 5. BOTÓN FINALIZAR ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _finalizarOnboarding,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        ),
                        child: Text(
                          l10n.finishRegistration,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
