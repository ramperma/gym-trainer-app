import 'package:flutter/material.dart';

import '../../../../core/env.dart';
import '../../exercises/data/exercise_api.dart';
import '../../exercises/domain/exercise.dart';
import '../../exercises/presentation/exercise_detail_screen.dart';
import '../../workout_sessions/data/workout_session_api.dart';
import '../../workout_sessions/domain/workout_session.dart';
import 'widgets/status_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ExerciseApi();
  final _sessionApi = WorkoutSessionApi();
  late Future<List<Exercise>> _futureExercises;
  late Future<List<WorkoutSession>> _futureSessions;

  @override
  void initState() {
    super.initState();
    _futureExercises = _api.fetchExercises();
    _futureSessions = _sessionApi.fetchSessions();
  }

  Future<void> _reload() async {
    setState(() {
      _futureExercises = _api.fetchExercises();
      _futureSessions = _sessionApi.fetchSessions();
    });
    await Future.wait([_futureExercises, _futureSessions]);
  }

  Future<void> _openExercise(BuildContext context, Exercise exercise) async {
    final shouldReload = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ExerciseDetailScreen(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
        ),
      ),
    );

    if (shouldReload == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Trainer Prototype'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar ejercicios',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pantalla inicial conectada al backend real',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ahora ya hay lista y detalle de ejercicios saliendo de PostgreSQL a través de FastAPI.',
            ),
            const SizedBox(height: 16),
            const _FeatureChecklist(),
            const SizedBox(height: 16),
            const StatusBanner(apiBaseUrl: Env.apiBaseUrl),
            const SizedBox(height: 16),
            Text(
              'Sesiones guardadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<WorkoutSession>>(
              future: _futureSessions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                          'No se pudieron cargar las sesiones: ${snapshot.error}'),
                    ),
                  );
                }

                final sessions = snapshot.data ?? [];
                if (sessions.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Todavía no hay sesiones guardadas.'),
                    ),
                  );
                }

                return Column(
                  children: sessions
                      .map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text(session.exerciseName),
                              subtitle: Text(
                                '${session.setsCompleted} series · ${session.repsCompleted} reps\n${session.notes.isEmpty ? 'Sin notas' : session.notes}',
                              ),
                              isThreeLine: true,
                              trailing: Text(
                                '${session.performedAt.day.toString().padLeft(2, '0')}/${session.performedAt.month.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Exercise>>(
              future: _futureExercises,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                      error: snapshot.error.toString(), onRetry: _reload);
                }

                final exercises = snapshot.data ?? [];
                if (exercises.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No hay ejercicios todavía.')),
                    ),
                  );
                }

                return Column(
                  children: exercises
                      .map(
                        (exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              onTap: () => _openExercise(context, exercise),
                              leading: CircleAvatar(
                                child: Text(
                                  exercise.name.isNotEmpty
                                      ? exercise.name
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(exercise.name),
                              subtitle: Text(
                                  '${exercise.muscleGroup} · ${exercise.difficulty}'),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChecklist extends StatelessWidget {
  const _FeatureChecklist();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Estado del vertical slice'),
            SizedBox(height: 12),
            _ChecklistItem(text: 'FastAPI conectado a PostgreSQL'),
            _ChecklistItem(
                text: 'Seed inicial con metadatos y prescripción básica'),
            _ChecklistItem(
                text: 'Flutter carga catálogo y navega a detalle real'),
            _ChecklistItem(
                text:
                    'Base preparada para rutina o login en siguiente iteración'),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;

  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 12),
            const Text('No se pudo conectar con el backend.'),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
