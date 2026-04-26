import 'package:flutter/material.dart';

import '../data/profile_api.dart';
import '../data/training_plan_api.dart';
import '../domain/user_profile.dart';

class AiTrainerScreen extends StatefulWidget {
  const AiTrainerScreen({super.key});

  @override
  State<AiTrainerScreen> createState() => _AiTrainerScreenState();
}

class _AiTrainerScreenState extends State<AiTrainerScreen> {
  final _profileApi = ProfileApi();
  final _trainingPlanApi = TrainingPlanApi();
  bool _loading = true;
  bool _generatingPlan = false;
  String? _error;
  UserProfile? _profile;
  AiStatus? _aiStatus;

  // Form state
  String? _trainingType; // 'daily', 'weekly', 'monthly'
  int _restDays = 1;
  List<String> _selectedLimitations = [];
  bool _wantExpertChat = false;
  String? _additionalNotes;
  final _notesController = TextEditingController();

  static const _trainingTypes = {
    'daily': 'Diario',
    'weekly': 'Semanal',
    'monthly': 'Mensual',
  };

  static const _limitationOptions = {
    'lower_body': 'Limitación en tren inferior',
    'upper_body': 'Limitación en tren superior',
    'lower_back': 'Problemas de espalda baja',
    'shoulder': 'Problemas de hombro',
    'knee': 'Problemas de rodilla',
    'wrist': 'Problemas de muñeca',
    'cardio_limited': 'Cardio limitado',
    'strength_limited': 'Fuerza limitada',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _profileApi.fetchProfile(),
        _profileApi.fetchAiStatus(),
      ]);
      final profile = results[0] as UserProfile;
      final aiStatus = results[1] as AiStatus;

      setState(() {
        _profile = profile;
        _aiStatus = aiStatus;
        _loading = false;
        // Pre-llenar limitaciones desde el perfil si las hay
        if (profile.injuries.isNotEmpty) {
          // Aquí se podría hacer una lógica más sofisticada
          // para mapear lesiones a limitaciones
        }
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _generateTraining() async {
    if (_trainingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de entrenamiento.'),
        ),
      );
      return;
    }

    setState(() => _generatingPlan = true);

    try {
      final result = await _trainingPlanApi.generateTrainingPlan(
        trainingType: _trainingType!,
        restDays: _restDays,
        selectedLimitations: _selectedLimitations,
        additionalNotes: _notesController.text,
        wantExpertChat: _wantExpertChat,
      );

      if (!mounted) return;

      // Show success message with training plan summary
      final trainingData = result['data'];
      final message = 'Entrenamiento generado: ${trainingData['total_days']} días, '
          'Dificultad: ${trainingData['difficulty_level']}, '
          'Áreas: ${trainingData['focus_areas'].join(", ")}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );

      // Log the generated plan
      print('Plan generado: $result');

      // Reset form
      setState(() {
        _trainingType = null;
        _restDays = 1;
        _selectedLimitations = [];
        _notesController.clear();
        _wantExpertChat = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el entrenamiento: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _generatingPlan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Crear Entrenamiento Personalizado')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Crear Entrenamiento Personalizado')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 40),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Entrenamiento Personalizado'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Entrenamiento con IA',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Personaliza tu rutina considerando tu perfil, objetivo y limitaciones.'
              ' El IA generará un plan optimizado para ti.',
            ),
            const SizedBox(height: 16),
            // Estado IA
            if (_aiStatus != null)
              _AiStatusCard(status: _aiStatus!)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.smart_toy_outlined, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Estado de IA no disponible',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Formulario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de entrenamiento
                    Text(
                      'Tipo de Entrenamiento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _trainingTypes.entries.map((entry) {
                        final isSelected = _trainingType == entry.key;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(entry.value),
                          onSelected: (selected) {
                            setState(() => _trainingType = entry.key);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Días de descanso
                    Text(
                      'Días de Descanso por Semana',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _restDays.toDouble(),
                      min: 0,
                      max: 7,
                      divisions: 7,
                      label: '$_restDays día${_restDays != 1 ? 's' : ''}',
                      onChanged: (value) {
                        setState(() => _restDays = value.toInt());
                      },
                    ),
                    const SizedBox(height: 24),
                    // Limitaciones
                    Text(
                      'Limitaciones y Restricciones',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_profile?.injuries.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lesiones/Problemas en tu Perfil:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(_profile!.injuries),
                            ],
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _limitationOptions.entries.map((entry) {
                        final isSelected = _selectedLimitations.contains(entry.key);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(entry.value),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLimitations.add(entry.key);
                              } else {
                                _selectedLimitations.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Objetivo recordatorio
                    if (_profile != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tu Objetivo Principal:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGoalLabel(_profile!.goal),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Notas adicionales
                    TextField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Notas Adicionales (Opcional)',
                        hintText:
                            'Ej: Horario disponible, preferencias de ejercicios, material disponible...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() => _additionalNotes = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Chat con experto
                    SwitchListTile(
                      value: _wantExpertChat,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hablar con Experto IA'),
                      subtitle: const Text(
                        'Obtén asesoramiento personalizado en tiempo real de un experto en fitness generado por IA.',
                      ),
                      onChanged: (value) {
                        setState(() => _wantExpertChat = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Botón generar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_aiStatus?.enabled == true && !_generatingPlan)
                            ? _generateTraining
                            : null,
                        icon: _generatingPlan
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          _generatingPlan
                              ? 'Generando entrenamiento...'
                              : 'Generar Entrenamiento con IA',
                        ),
                      ),
                    ),
                    if (_aiStatus?.enabled != true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: const Text(
                            'La IA no está disponible aún. Por favor, verifica tu conexión o intenta más tarde.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalLabel(String? goal) {
    switch (goal) {
      case 'perder_grasa':
        return 'Perder grasa';
      case 'ganar_musculo':
        return 'Ganar musculo';
      case 'mantener':
        return 'Mantener';
      case 'rendimiento':
        return 'Rendimiento';
      case 'salud_general':
        return 'Salud general';
      default:
        return 'Sin definir';
    }
  }
}

class _AiStatusCard extends StatelessWidget {
  final AiStatus status;

  const _AiStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.enabled ? Colors.green : Colors.orange;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IA: ${status.enabled ? 'Conectada' : 'Pendiente'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Proveedor: ${status.provider}'),
            const SizedBox(height: 4),
            Text(
              status.personalizationReady
                  ? 'Tu perfil está listo para personalización.'
                  : 'Completa tu perfil para mejor personalización.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
