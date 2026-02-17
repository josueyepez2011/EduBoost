import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../data/models/task_model.dart';
import '../widgets/task_list_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../gamification/bloc/achievement_bloc.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = today.add(const Duration(days: 7));

    if (_tabController.index == 0) {
      // Today
      return tasks
          .where((task) =>
              task.dueDate.isAfter(today) && task.dueDate.isBefore(tomorrow))
          .toList();
    } else if (_tabController.index == 1) {
      // Week
      return tasks
          .where(
              (task) => task.dueDate.isAfter(today) && task.dueDate.isBefore(weekEnd))
          .toList();
    } else {
      // All
      return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tareas',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      onTap: (_) => setState(() {}),
                      tabs: const [
                        Tab(text: 'Hoy'),
                        Tab(text: 'Semana'),
                        Tab(text: 'Todas'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocListener<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskCompletedWithAchievement) {
                    // Update achievement progress for first task
                    context.read<AchievementBloc>().add(
                      const UpdateAchievementProgress('first_task'),
                    );
                    // Update achievement progress for task master (10 tasks)
                    context.read<AchievementBloc>().add(
                      const UpdateAchievementProgress('task_master'),
                    );
                  }
                },
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TaskLoaded) {
                      final filteredTasks = _filterTasks(state.tasks);

                      if (filteredTasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.task_alt,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'No hay tareas aún',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Toca + para crear tu primera tarea',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing20,
                        ),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskListItem(
                            task: task,
                            onToggle: () {
                              context
                                  .read<TaskBloc>()
                                  .add(ToggleTaskComplete(task.id));
                            },
                            onDelete: () {
                              context.read<TaskBloc>().add(DeleteTask(task.id));
                            },
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => AddTaskScreen(task: task),
                              );
                            },
                          );
                        },
                      );
                    }

                    return const Center(child: Text('Algo salió mal'));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskScreen(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Tarea'),
      ),
    );
  }
}
