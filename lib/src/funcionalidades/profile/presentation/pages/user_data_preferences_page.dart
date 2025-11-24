import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// === IMPORTS DE WIDGETS DE ESTILO ===
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_avatar_widget.dart';
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
  State<UserDataPreferencesPage> createState() => _UserDataPreferencesPageState();
}

class _UserDataPreferencesPageState extends State<UserDataPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isCreatingFirebaseUser = false;

  late final TextEditingController _apodoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _fechaNacimientoController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _nombreCompletoController;

  File? _selectedImageFile;
  final AssetImage _avatarImage = const AssetImage('assets/Profile_avatar_placeholder_large.png');

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

  // === Finalizar Onboarding ===
  Future<void> _finalizarOnboarding() async {
    var l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.formError)),
      );
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
            SnackBar(content: Text(l10n.errorOccurred("Credenciales faltantes."))),
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() => _isCreatingFirebaseUser = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error desconocido: $e"), backgroundColor: Colors.red),
      );
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
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is UserUpdated) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
              final firebaseUserNow = FirebaseAuth.instance.currentUser;
              
              userProvider.setUser(state.user.toMap(), firebaseUserId: firebaseUserNow?.uid, firebaseToken: null);
              () async {
                final token = firebaseUserNow == null ? null : await firebaseUserNow.getIdToken();
                userProvider.setUser(state.user.toMap(), firebaseUserId: firebaseUserNow?.uid, firebaseToken: token);
              }();
              
              localeProvider.setLocaleFromLanguage(state.user.idiomaPreferido);
              
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
                    
                    // --- 1. AVATAR ---
                    ProfileAvatarSelector(
                      selectedImageFile: _selectedImageFile,
                      defaultImage: _avatarImage,
                      onImagePicked: (File newFile) {
                        setState(() => _selectedImageFile = newFile);
                      },
                    ),
                    const SizedBox(height: 30),

                    // --- 2. DATOS PERSONALES ---
                    ProfileSectionLabel(text: l10n.nicknameNonEditable),
                    ProfileStyledCard(
                      children: [
                        ProfileStyledTextField(
                          controller: _apodoController,
                          label: l10n.nickname,
                          icon: Icons.alternate_email_rounded,
                          showDivider: true,
                          validator: (v) => v?.trim().isEmpty ?? true ? l10n.mandatoryNickname : null,
                        ),
                        ProfileStyledTextField(
                          controller: _nombreCompletoController,
                          label: l10n.fullName,
                          icon: Icons.person_outline_rounded,
                          showDivider: true,
                          validator: (v) => v?.trim().isEmpty ?? true ? l10n.mandatoryFullName : null,
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: ProfileStyledTextField(
                              controller: _fechaNacimientoController,
                              label: l10n.birthdate,
                              icon: Icons.cake_outlined,
                              showDivider: false,
                              validator: (v) => v?.isEmpty ?? true ? l10n.mandatoryBirthDate : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- 3. CONTACTO Y DETALLES ---
                    const ProfileSectionLabel(text: "Contacto y Detalles"),
                    ProfileStyledCard(
                      children: [
                        ProfileStyledTextField(
                          controller: _telefonoController,
                          label: l10n.telephoneNumber,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          showDivider: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v) ? null : l10n.invalidPhoneNumber;
                          },
                        ),
                        ProfileStyledTextField(
                          controller: _descripcionController,
                          label: l10n.userDescription,
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- 4. PREFERENCIAS ---
                    ProfileSectionLabel(text: l10n.preferredMode),
                    ProfileStyledCard(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedModo,
                          decoration: cardInputDecoration(
                            icon: _selectedModo == 'Bici' ? Icons.directions_bike : Icons.electric_car, 
                            context: context
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                          dropdownColor: Colors.white,
                          validator: (v) => v == null ? l10n.mandatoryPreferredMode : null,
                          items: _modos.map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text(m, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedModo = v),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0), indent: 50),
                        DropdownButtonFormField<String>(
                          value: _selectedIdioma,
                          decoration: cardInputDecoration(icon: Icons.language_rounded, context: context),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                          dropdownColor: Colors.white,
                          items: _idiomas.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)))).toList(),
                          onChanged: (v) => setState(() => _selectedIdioma = v),
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
                          elevation: 2,
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          l10n.finishRegistration,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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