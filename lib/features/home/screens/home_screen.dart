import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../grades/bloc/grade_bloc.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../grades/screens/grades_screen.dart';
import '../../gamification/screens/achievements_screen.dart';
import '../../ai_tutor/screens/ai_tutor_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/animated_card.dart';
import '../../tasks/data/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardView(),
    const TasksScreen(),
    const GradesScreen(),
    const AiTutorScreen(),
    const AchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing8,
              vertical: AppTheme.spacing8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Inicio', 0),
                _buildNavItem(Icons.task_alt_rounded, 'Tareas', 1),
                _buildNavItem(Icons.analytics_rounded, 'Notas', 2),
                _buildNavItem(Icons.psychology_rounded, 'IA', 3),
                _buildNavItem(Icons.emoji_events_rounded, 'Logros', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? AppTheme.spacing16 : AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textTertiary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: AppTheme.spacing8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EduBoost',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      DateFormat(
                        'EEEE, d \'de\' MMMM \'de\' y',
                        'es_ES',
                      ).format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacing16),
                    // Quick Stats
                    BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        final tasks = taskState is TaskLoaded
                            ? taskState.tasks
                            : <TaskModel>[];
                        final pendingTasks = tasks
                            .where((t) => !t.isCompleted)
                            .length;

                        return BlocBuilder<GradeBloc, GradeState>(
                          builder: (context, gradeState) {
                            final average = gradeState is GradeLoaded
                                ? gradeState.averageGrade
                                : 0.0;

                            return Row(
                              children: [
                                Expanded(
                                  child: AnimatedCard(
                                    gradient: AppColors.primaryGradient,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.task_alt,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: AppTheme.spacing12,
                                        ),
                                        Text(
                                          '$pendingTasks',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Tareas Pendientes',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacing16),
                                Expanded(
                                  child: AnimatedCard(
                                    gradient: AppColors.accentGradient,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.analytics,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: AppTheme.spacing12,
                                        ),
                                        Text(
                                          '${average.toStringAsFixed(0)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Promedio General',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    // Today's Tasks Section
                    Text(
                      'Tareas de Hoy',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                  ],
                ),
              ),
            ),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is TaskLoaded) {
                  final today = DateTime.now();
                  final todayTasks = state.tasks
                      .where(
                        (task) =>
                            !task.isCompleted &&
                            task.dueDate.year == today.year &&
                            task.dueDate.month == today.month &&
                            task.dueDate.day == today.day,
                      )
                      .toList();

                  if (todayTasks.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              '¡Todo al día!',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'No hay tareas para hoy',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = todayTasks[index];
                        return AnimatedCard(
                          onTap: () {},
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              task.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: task.isCompleted
                                  ? AppColors.success
                                  : AppColors.primaryPurple,
                            ),
                            title: Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              task.subject,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      }, childCount: todayTasks.length),
                    ),
                  );
                }

                return const SliverFillRemaining(
                  child: Center(child: Text('No hay tareas')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
