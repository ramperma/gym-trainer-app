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

  void _openProfileTab() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Gym overview' : 'Perfil'),
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

                final recentExercises = data.exercises.take(3).toList();
                final recentSessions = data.sessions.take(3).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    _HeroPanel(
                      profile: data.profile,
                      exercisesCount: data.exercises.length,
                      sessionsCount: data.sessions.length,
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Entrenamientos',
                      subtitle:
                          'Catálogo real conectado a backend y acceso rápido a ejercicios.',
                      icon: Icons.fitness_center,
                      actionLabel: 'Ver catálogo',
                      onAction: _openExerciseCatalog,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetricPill(
                                label: 'Ejercicios activos',
                                value: '${data.exercises.length}',
                              ),
                              _MetricPill(
                                label: 'Última sesión',
                                value: data.sessions.isEmpty
                                    ? 'Sin registrar'
                                    : recentSessions.first.exerciseName,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (recentExercises.isEmpty)
                            const Text('No hay ejercicios cargados todavía.')
                          else
                            ...recentExercises.map(
                              (exercise) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _CompactListItem(
                                  icon: Icons.sports_gymnastics,
                                  title: exercise.name,
                                  subtitle:
                                      '${exercise.muscleGroup} · ${exercise.difficulty}',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Historial y seguimiento',
                      subtitle:
                          'Resumen corto de actividad y acceso al historial completo.',
                      icon: Icons.query_stats,
                      actionLabel: 'Ver historial',
                      onAction: _openHistory,
                      child: recentSessions.isEmpty
                          ? const Text('Todavía no hay sesiones guardadas.')
                          : Column(
                              children: recentSessions
                                  .map(
                                    (session) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _CompactListItem(
                                        icon: Icons.history,
                                        title: session.exerciseName,
                                        subtitle:
                                            '${session.setsCompleted} series · ${session.repsCompleted} reps · ${_formatDate(session.performedAt)}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Perfil y salud',
                      subtitle:
                          'Datos útiles para personalización, seguridad y contexto de entrenamiento.',
                      icon: Icons.favorite_outline,
                      actionLabel: 'Abrir perfil',
                      onAction: _openProfileTab,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetricPill(
                                label: 'Objetivo',
                                value: _goalLabel(data.profile.goal),
                              ),
                              _MetricPill(
                                label: 'Peso',
                                value: data.profile.weightKg == null
                                    ? 'Pendiente'
                                    : '${data.profile.weightKg!.toStringAsFixed(1)} kg',
                              ),
                              _MetricPill(
                                label: 'Lesiones',
                                value: data.profile.injuries.isEmpty
                                    ? 'No indicadas'
                                    : 'Revisar',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data.profile.displayName.isEmpty
                                ? 'Completa tu perfil para mejorar recomendaciones y contexto.'
                                : 'Perfil listo para ${data.profile.displayName}. Puedes ajustar objetivo, lesiones y personalización.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'IA / Coach',
                      subtitle:
                          'Estado real de backend y espacio reservado para recomendaciones guiadas.',
                      icon: Icons.smart_toy_outlined,
                      actionLabel: 'Configurar perfil',
                      onAction: _openProfileTab,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AiCoachSummary(status: data.aiStatus),
                          const SizedBox(height: 12),
                          const _ComingSoonTile(
                            title: 'Plan diario generado',
                            subtitle:
                                'Pendiente para la siguiente iteración cuando existan recomendaciones accionables.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SectionCard(
                      title: 'Nutrición',
                      subtitle:
                          'Bloque funcional preparado para integrar comidas, macros y adherencia.',
                      icon: Icons.restaurant_menu,
                      child: _ComingSoonTile(
                        title: 'Módulo en preparación',
                        subtitle:
                            'Reservado sin romper la UX. Se activará cuando haya backend y flujos reales.',
                      ),
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

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
  }

  String _goalLabel(String? goal) {
    switch (goal) {
      case 'perder_grasa':
        return 'Perder grasa';
      case 'ganar_musculo':
        return 'Ganar músculo';
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

class _HeroPanel extends StatelessWidget {
  final UserProfile profile;
  final int exercisesCount;
  final int sessionsCount;

  const _HeroPanel({
    required this.profile,
    required this.exercisesCount,
    required this.sessionsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola${profile.displayName.isEmpty ? '' : ', ${profile.displayName}'}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Home reorganizada por funciones de producto para entrar rápido a lo importante.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Ejercicios',
                  value: '$exercisesCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroStat(
                  label: 'Sesiones',
                  value: '$sessionsCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _CompactListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CompactListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCoachSummary extends StatelessWidget {
  final AiStatus status;

  const _AiCoachSummary({required this.status});

  @override
  Widget build(BuildContext context) {
    final readyColor = status.enabled ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 14, color: readyColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.enabled
                      ? 'Coach backend disponible'
                      : 'Coach pendiente de configuración',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Proveedor: ${status.provider}. ${status.personalizationReady ? 'El perfil ya aporta contexto.' : 'Faltan más datos de perfil para personalizar mejor.'}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ComingSoonTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.schedule),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Chip(label: Text('Próximamente')),
        ],
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
