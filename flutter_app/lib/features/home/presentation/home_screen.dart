import 'package:flutter/material.dart';

import '../../../../core/env.dart';
import '../../exercises/data/exercise_api.dart';
import '../../exercises/domain/exercise.dart';
import '../../profile/data/profile_api.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/ai_trainer_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../workout_sessions/data/workout_session_api.dart';
import '../../workout_sessions/domain/workout_session.dart';
import '../../workout_sessions/presentation/training_hub_screen.dart';
import '../../workout_sessions/presentation/workout_history_screen.dart';
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

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WorkoutHistoryScreen()),
    );
    await _reload();
  }

  void _openAiTrainerTab() {
    setState(() => _selectedIndex = 3);
  }

  void _openTrainingTab() {
    setState(() => _selectedIndex = 1);
  }

  void _openProfileTab() {
    setState(() => _selectedIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_selectedIndex) {
            0 => 'Dashboard',
            1 => 'Entrenamientos',
            2 => 'Perfil',
            _ => 'Personal Trainer IA',
          },
        ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar datos',
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
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                  children: [
                    _HeroPanel(
                      profileName: data.profile.displayName,
                      exerciseCount: data.exercises.length,
                      sessionCount: data.sessions.length,
                      aiReady: data.aiStatus.personalizationReady,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Accesos rápidos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Organiza entreno, progreso y personalización desde una sola vista.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _HomeOptionCard(
                      title: 'Entrenamientos',
                      subtitle: 'Planes por cuerpo, objetivo y nivel',
                      icon: Icons.fitness_center,
                      accent: const Color(0xFF1363DF),
                      onTap: _openTrainingTab,
                    ),
                    const SizedBox(height: 10),
                    _HomeOptionCard(
                      title: 'Personal Trainer IA',
                      subtitle: 'Genera plan diario, semanal o mensual',
                      icon: Icons.auto_awesome,
                      accent: const Color(0xFF1A9D8C),
                      onTap: _openAiTrainerTab,
                    ),
                    const SizedBox(height: 10),
                    _HomeOptionCard(
                      title: 'Historial',
                      subtitle: '${data.sessions.length} sesiones registradas',
                      icon: Icons.query_stats,
                      accent: const Color(0xFFEE7A23),
                      onTap: _openHistory,
                    ),
                    const SizedBox(height: 10),
                    _HomeOptionCard(
                      title: 'Nutrición y perfil',
                      subtitle: data.aiStatus.personalizationReady
                          ? 'Perfil listo para recomendaciones personalizadas'
                          : 'Completa tu perfil para activar personalización',
                      icon: Icons.person,
                      accent: const Color(0xFF8D5DDB),
                      onTap: _openProfileTab,
                    ),
                    const SizedBox(height: 16),
                    StatusBanner(apiBaseUrl: Env.apiBaseUrl),
                  ],
                );
              },
            ),
          ),
          const TrainingHubScreen(),
          const ProfileScreen(),
          const AiTrainerScreen(),
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
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Entreno',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'IA',
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final String profileName;
  final int exerciseCount;
  final int sessionCount;
  final bool aiReady;

  const _HeroPanel({
    required this.profileName,
    required this.exerciseCount,
    required this.sessionCount,
    required this.aiReady,
  });

  @override
  Widget build(BuildContext context) {
    final name = profileName.trim().isEmpty ? 'Atleta' : profileName.trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2747), Color(0xFF1E4F8A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25122A48),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $name',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Control total de tu progreso con métricas claras y sesiones guardadas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD8E6F8),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricBadge(
                  icon: Icons.fitness_center,
                  label: 'Ejercicios',
                  value: '$exerciseCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBadge(
                  icon: Icons.bolt,
                  label: 'Sesiones',
                  value: '$sessionCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBadge(
                  icon: Icons.smart_toy,
                  label: 'IA',
                  value: aiReady ? 'Lista' : 'Parcial',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE7F2FF)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFDFECFB),
                ),
          ),
        ],
      ),
    );
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
  final Color accent;
  final VoidCallback onTap;

  const _HomeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent.withValues(alpha: 0.95), accent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_outward, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chevron_right),
              ),
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
