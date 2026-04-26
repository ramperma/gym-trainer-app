import 'package:flutter/material.dart';

import '../../../../core/env.dart';
import '../../exercises/data/exercise_api.dart';
import '../../exercises/domain/exercise.dart';
import '../../exercises/presentation/exercise_catalog_screen.dart';
import '../../profile/data/profile_api.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../workout_sessions/data/workout_session_api.dart';
import '../../workout_sessions/domain/workout_session.dart';
import '../../workout_sessions/presentation/workout_history_screen.dart';
import '../../profile/presentation/ai_trainer_screen.dart';
import 'widgets/status_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _exerciseApi = ExerciseApi();
  final _sessionApi = WorkoutSessionApi();
  final _profileApi = ProfileApi();

  int _selectedIndex = 0;
  late Future<_HomeData> _futureHomeData;

  @override
  void initState() {
    super.initState();
    _futureHomeData = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final results = await Future.wait([
      _exerciseApi.fetchExercises(),
      _sessionApi.fetchSessions(),
      _profileApi.fetchProfile(),
      _profileApi.fetchAiStatus(),
    ]);

    return _HomeData(
      exercises: results[0] as List<Exercise>,
      sessions: results[1] as List<WorkoutSession>,
      profile: results[2] as UserProfile,
      aiStatus: results[3] as AiStatus,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _futureHomeData = _loadHomeData();
    });
    await _futureHomeData;
  }

  Future<void> _openExerciseCatalog() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ExerciseCatalogScreen()),
    );
    await _reload();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WorkoutHistoryScreen()),
    );
    await _reload();
  }

  Future<void> _openAiTrainer() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AiTrainerScreen()),
    );
  }

  void _openProfileTab() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Inicio' : 'Perfil'),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recargar inicio',
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
            onRefresh: _reload,
            child: FutureBuilder<_HomeData>(
              future: _futureHomeData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _HomeErrorState(
                    error: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return _HomeErrorState(
                    error: 'No se pudo construir la home.',
                    onRetry: _reload,
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    Text(
                      'Opciones de inicio',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Accesos directos a las secciones principales.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _HomeOptionCard(
                      title: 'Entrenamientos',
                      subtitle: '${data.exercises.length} ejercicios disponibles',
                      icon: Icons.fitness_center,
                      onTap: _openExerciseCatalog,
                    ),
                    const SizedBox(height: 10),
                    _HomeOptionCard(
                      title: 'Personal Trainer',
                      subtitle: 'Crea entrenamientos personalizados con IA',
                      icon: Icons.person_pin,
                      onTap: _openAiTrainer,
                    ),
                    const SizedBox(height: 10),
                    _HomeOptionCard(
                      title: 'Historial',
                      subtitle: '${data.sessions.length} sesiones registradas',
                      icon: Icons.history,
                      onTap: _openHistory,
                    ),
                    const SizedBox(height: 10),
                    _HomeOptionCard(
                      title: 'Nutricion',
                      subtitle: data.aiStatus.personalizationReady
                          ? 'Tu perfil ya esta listo para sugerencias personalizadas'
                          : 'Completa tu perfil para personalizar recomendaciones',
                      icon: Icons.restaurant_menu,
                      onTap: _openProfileTab,
                    ),
                    const SizedBox(height: 16),
                    StatusBanner(apiBaseUrl: Env.apiBaseUrl),
                  ],
                );
              },
            ),
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _goalLabel(String? goal) {
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
        return 'Pendiente';
    }
  }
}

class _HomeData {
  final List<Exercise> exercises;
  final List<WorkoutSession> sessions;
  final UserProfile profile;
  final AiStatus aiStatus;

  const _HomeData({
    required this.exercises,
    required this.sessions,
    required this.profile,
    required this.aiStatus,
  });
}

class _HomeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _HomeErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.cloud_off, size: 40),
                const SizedBox(height: 12),
                const Text('No se pudo cargar la home.'),
                const SizedBox(height: 8),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
