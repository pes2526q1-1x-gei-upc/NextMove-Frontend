import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';

class EditUserDataPreferences extends StatefulWidget {
  const EditUserDataPreferences({super.key});

  @override
  State<EditUserDataPreferences> createState() => _UserDataPreferencesState();
}

class _UserDataPreferencesState extends State<EditUserDataPreferences> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final TextEditingController _apodoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nombreCompletoController = TextEditingController();

  // Estado para la imagen 
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile; // Guardará la imagen seleccionada por el usuario
  
  // Imagen por defecto, obtener la de google si existe, futura implementación
  final AssetImage _avatarImage = const AssetImage('assets/Profile_avatar_placeholder_large.png');

  // Estado para los Dropdowns
  String? _selectedIdioma;
  String? _selectedModo;

  final List<String> _idiomas = ['Español', 'English', 'Català'];
  final List<String> _modos = ['Bici', 'Coche'];

  @override
  void initState() {
    super.initState();
    //Cargamos los datos del usuario existentes
    UserData data = fetchUserDataPreferences();

    if(data.numeroTelefono == 0){
      _telefonoController.text = ''; // Valor por defecto si no hay número
    }
    else{
      _telefonoController.text = data.numeroTelefono.toString();
    }
    _selectedIdioma ??= 'Español';
    _apodoController.text = data.apodo;
    _nombreCompletoController.text = data.nombreCompleto;
    _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(data.fechaNacimiento);
    _descripcionController.text = data.descripcion;
    _selectedModo = data.modoPreferido;     
    //_avatarImage = AssetImage(data.fotoPerfilUrl);
  }

  @override
  void dispose() {
    //Limpiar controladores
    _apodoController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  //Método para mostrar el DatePicker
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

  // Método para mostrar el menú de selección de imagen
  void _showImageSourceActionSheet() {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.gallery), 
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(l10n.camera),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para seleccionar la imagen
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.imagePickerError)),
      );
    }
  }

  // Método para guardar cambios
  void _guardarCambios() {
    // Primero, validamos que el formulario esté correcto
    if (_formKey.currentState!.validate()) {
      // Si es válido, recopilamos todos los datos
      // Implementar la lógica para guardar los datos en el backend
      //print('Datos a guardar: $userData');
      UserData preferences = UserData(
        apodo: _apodoController.text,
        nombreCompleto: '', // Completar según sea necesario
        //email: '', // Completar según sea necesario
        fechaNacimiento: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(1990),
        //password: '', // Completar según sea necesario
        fechaRegistro: DateTime.now(), //No se le hará caso pero debe inicializarse
        numeroTelefono: int.tryParse(_telefonoController.text) ?? 0,
        idiomaPreferido: _selectedIdioma ?? '',
        descripcion: _descripcionController.text,
        modoPreferido: _selectedModo ?? '',
        //fotoPerfilUrl: '', // Completar según sea necesario
      );
      updateUserDataPreferences(preferences);


      // Damos feedback al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveChangesFeedback)),
      );
    } else {
      // Si el formulario no es válido, mostramos un error
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.formError)),
      );
    }
  }

  void _goBack() {
    // Al volver atrás, se descartan los cambios sin guardar (comportamiento por defecto al hacer pop)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

  return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: Text(
          l10n.editProfile,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceActionSheet,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          // Mostramos la imagen seleccionada, o la de por defecto
                          backgroundImage: _selectedImageFile != null
                              ? FileImage(_selectedImageFile!) as ImageProvider
                              : _avatarImage,
                        ),
                        // Icono de "editar" sobre la foto
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
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

                // Apodo no editable
                TextFormField(
                  controller: _apodoController,
                  enabled: false, // No editable ni interactivo
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    labelText: l10n.nicknameNonEditable,
                    border: OutlineInputBorder(),
                  )
                ),
                SizedBox(height: 16),

                //Nombre Completo no editable
                TextFormField(
                  controller: _nombreCompletoController,
                  enabled: false, // No editable ni interactivo
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Fecha de nacimiento no editable
                TextFormField(
                  controller: _fechaNacimientoController,
                  enabled: false, // No editable ni interactivo
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    labelText: l10n.birthdate,
                    border: OutlineInputBorder(),
                    hintText: l10n.bithdateHint,
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 16),

                //Teléfono
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: l10n.telephoneNumber,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validación simple de formato de teléfono
                    final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
                    if (!phoneRegExp.hasMatch(value!)) {
                      if(value.isNotEmpty) return l10n.invalidPhoneNumber;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                //Descripcion
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: l10n.userDescription,
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 16),

// Modo e Idioma preferidos en la misma fila
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedModo,
                        decoration: InputDecoration(
                          labelText: l10n.preferredMode,
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                        menuMaxHeight: 200,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.mandatoryPreferredMode;
                          }
                          return null;
                        },
                        items: _modos.map((String modo) {
                          IconData icon = modo == 'Bici' ? Icons.directions_bike : Icons.electric_car;
                          return DropdownMenuItem<String>(
                            value: modo,
                            child: Row(
                              children: [
                                Icon(icon, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 12),
                                Text(
                                  modo,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _selectedModo = nuevoValor;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedIdioma,
                        decoration: InputDecoration(
                          labelText: l10n.preferredLanguage,
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                        menuMaxHeight: 200,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        items: _idiomas.map((String idioma) {
                          return DropdownMenuItem<String>(
                            value: idioma,
                            child: Row(
                              children: [
                                
                                const SizedBox(width: 12),
                                Text(
                                  idioma,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _selectedIdioma = nuevoValor;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Guardar cambios
                //SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text(l10n.saveChanges),
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