import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/MapHomePage.dart';

class OnboardingUserDataPage extends StatefulWidget {
  const OnboardingUserDataPage({super.key});

  @override
  State<OnboardingUserDataPage> createState() => _OnboardingUserDataPageState();
}

class _OnboardingUserDataPageState extends State<OnboardingUserDataPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apodoController;
  late TextEditingController _nombreCompletoController;
  late TextEditingController _numeroTelefonoController;
  String _modoPreferido = "Coche";
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController();
    _nombreCompletoController = TextEditingController();
    _numeroTelefonoController = TextEditingController();

    // Pre-rellenar con datos de Firebase si existen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = userProvider.user;
      if (userData != null) {
        setState(() {
          _nombreCompletoController.text = userData['name'] ?? '';
          _apodoController.text = userData['username'] ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _apodoController.dispose();
    _nombreCompletoController.dispose();
    _numeroTelefonoController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseUserId = userProvider.firebaseUserId;

    if (firebaseUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No se encontró usuario autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userData = UserData(
      apodo: _apodoController.text,
      nombreCompleto: _nombreCompletoController.text,
      fechaNacimiento: DateTime.now(), 
      fechaRegistro: DateTime.now(),
      numeroTelefono: int.tryParse(_numeroTelefonoController.text) ?? 0,
      idiomaPreferido: "Español",
      descripcion: "",
      modoPreferido: _modoPreferido,
    );

    try {
      await updateUserDataPreferences(userData, context);

      if (mounted) {
        // Navegar al home y eliminar todo el stack anterior
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MapHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevenir que el usuario retroceda
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Completa tu perfil'),
          automaticallyImplyLeading: false, // Sin botón atrás
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    _completeOnboarding();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep--;
                    });
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(
                            _currentStep == 2 ? 'Finalizar' : 'Continuar',
                          ),
                        ),
                        if (_currentStep > 0) ...[
                          SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text('Atrás'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: Text('Información básica'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                    content: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nombreCompletoController,
                            decoration: InputDecoration(
                              labelText: 'Nombre Completo *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _apodoController,
                            decoration: InputDecoration(
                              labelText: 'Apodo *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El apodo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: Text('Contacto'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : StepState.indexed,
                    content: Column(
                      children: [
                        TextField(
                          controller: _numeroTelefonoController,
                          decoration: InputDecoration(
                            labelText: 'Número de Teléfono (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: Text('Preferencias'),
                    isActive: _currentStep >= 2,
                    content: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _modoPreferido,
                          decoration: InputDecoration(
                            labelText: 'Modo de Transporte Preferido',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.directions_car),
                          ),
                          items: ['Coche', 'Bicicleta']
                              .map(
                                (mode) => DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _modoPreferido = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
