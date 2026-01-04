import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/alertas/dominio/alert_entity.dart';
import 'package:nextmove_app/src/funcionalidades/alertas/presentacion/bloc/alert_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

class CreateAlertPage extends StatefulWidget {
  final StationAlert? alert;

  const CreateAlertPage({super.key, this.alert});

  @override
  State<CreateAlertPage> createState() => _CreateAlertPageState();
}

class _CreateAlertPageState extends State<CreateAlertPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStationId;
  final List<String> _selectedHoras = [];
  final List<int> _selectedDias = [];
  List<Map<String, dynamic>> _favoriteStations = [];
  bool _isLoadingStations = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStations();
    if (widget.alert != null) {
      _selectedStationId = widget.alert!.stationId;
      _selectedHoras.addAll(widget.alert!.horas);
      _selectedDias.addAll(widget.alert!.diasSemana);
    }
  }

  Future<void> _loadFavoriteStations() async {
    try {
      String? authHeader = await AuthRemoteDataProvider().authHeader;
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getFavBikeStations),
        context: Context().withEntry(
          HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
        ),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLConfig.client.value.query(options);

      if (result.hasException) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar estaciones: ${result.exception}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final data = result.data?['getFavBikeStations'];
      if (data != null) {
        setState(() {
          _favoriteStations = List<Map<String, dynamic>>.from(data);
          _isLoadingStations = false;
        });
      } else {
        setState(() {
          _isLoadingStations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoadingStations = false;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hora = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_selectedHoras.contains(hora)) {
        setState(() {
          _selectedHoras.add(hora);
          _selectedHoras.sort();
        });
      }
    }
  }

  void _removeHora(String hora) {
    setState(() {
      _selectedHoras.remove(hora);
    });
  }

  void _toggleDia(int dia) {
    setState(() {
      if (_selectedDias.contains(dia)) {
        _selectedDias.remove(dia);
      } else {
        _selectedDias.add(dia);
        _selectedDias.sort();
      }
    });
  }

  void _saveAlert() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una estación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedHoras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos una hora'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un día'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.alert != null) {
      // Actualizar alerta existente
      context.read<AlertBloc>().add(
        UpdateAlertEvent(
          id: widget.alert!.id,
          horas: _selectedHoras,
          diasSemana: _selectedDias,
        ),
      );
    } else {
      // Crear nueva alerta
      context.read<AlertBloc>().add(
        CreateAlertEvent(
          stationId: _selectedStationId!,
          horas: _selectedHoras,
          diasSemana: _selectedDias,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          iconSize: 22,
        ),
        title: Text(
          widget.alert != null ? 'Editar Alerta' : 'Nueva Alerta',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de estación
                Text(
                  'Estación',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoadingStations)
                  const Center(child: CircularProgressIndicator())
                else if (_favoriteStations.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No tienes estaciones de bici favoritas. Añade estaciones favoritas primero.',
                            style: TextStyle(color: Colors.orange[900]),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedStationId,
                    decoration: InputDecoration(
                      labelText: 'Selecciona una estación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    items: _favoriteStations.map((station) {
                      return DropdownMenuItem<String>(
                        value: station['station_id'] as String,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              station['nombre'] as String? ?? 'Estación',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (station['direccion'] != null)
                              Text(
                                station['direccion'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStationId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona una estación';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 32),

                // Selección de horas
                Text(
                  'Horas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                  label: const Text('Añadir hora'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (_selectedHoras.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedHoras.map((hora) {
                      return Chip(
                        label: Text(hora),
                        onDeleted: () => _removeHora(hora),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 32),

                // Selección de días
                Text(
                  'Días de la semana',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (index) {
                    final isSelected = _selectedDias.contains(index);
                    return FilterChip(
                      label: Text(diasSemana[index]),
                      selected: isSelected,
                      onSelected: (_) => _toggleDia(index),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAlert,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.alert != null ? 'Guardar cambios' : 'Crear alerta',
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

