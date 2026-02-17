import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/grade_bloc.dart';
import '../data/models/grade_model.dart';
import '../widgets/grade_chart.dart';
import 'add_grade_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/animated_card.dart';
import '../../gamification/bloc/achievement_bloc.dart';
import 'package:intl/intl.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  String _getCategoryName(GradeCategory category) {
    switch (category) {
      case GradeCategory.exam:
        return 'EXAMEN';
      case GradeCategory.homework:
        return 'TAREA';
      case GradeCategory.quiz:
        return 'PRUEBA';
      case GradeCategory.project:
        return 'PROYECTO';
      case GradeCategory.participation:
        return 'PARTICIPACIÓN';
      default:
        return 'OTRO';
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notas',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocListener<GradeBloc, GradeState>(
                listener: (context, state) {
                  if (state is GradeAddedWithPerfectScore) {
                    // Update achievement progress for perfect score
                    context.read<AchievementBloc>().add(
                      const UpdateAchievementProgress('perfect_score'),
                    );
                  } else if (state is GradeAddedWithImprovement) {
                    // Update achievement progress for grade improvement
                    context.read<AchievementBloc>().add(
                      const UpdateAchievementProgress('grade_improved'),
                    );
                  } else if (state is GradeAddedWithGoodScore) {
                    // Update achievement progress for week streak (good grade)
                    context.read<AchievementBloc>().add(
                      const UpdateAchievementProgress('week_streak'),
                    );
                  }
                },
                child: BlocBuilder<GradeBloc, GradeState>(
                  builder: (context, state) {
                    if (state is GradeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GradeLoaded) {
                      if (state.grades.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.analytics,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'No hay notas aún',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Toca + para agregar tu primera nota',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Cards
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedCard(
                                    gradient: AppColors.primaryGradient,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.analytics,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(
                                          height: AppTheme.spacing12,
                                        ),
                                        Text(
                                          '${state.averageGrade.toStringAsFixed(1)}%',
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
                                const SizedBox(width: AppTheme.spacing16),
                                Expanded(
                                  child: AnimatedCard(
                                    gradient: AppColors.accentGradient,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.trending_up,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(
                                          height: AppTheme.spacing12,
                                        ),
                                        Text(
                                          '${state.grades.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Total de Notas',
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
                            ),
                            const SizedBox(height: AppTheme.spacing24),
                            // Chart
                            Text(
                              'Tendencias de Notas',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            AnimatedCard(
                              child: GradeChart(grades: state.grades),
                            ),
                            const SizedBox(height: AppTheme.spacing24),
                            // Subject Averages
                            if (state.subjectAverages.isNotEmpty) ...[
                              Text(
                                'Rendimiento por Materia',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              ...state.subjectAverages.entries.map((entry) {
                                final percentage = entry.value;
                                final color = percentage >= 90
                                    ? AppColors.success
                                    : percentage >= 75
                                    ? AppColors.primaryPurple
                                    : percentage >= 60
                                    ? AppColors.warning
                                    : AppColors.error;

                                return Column(
                                  children: [
                                    AnimatedCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              Text(
                                                '${percentage.toStringAsFixed(1)}%',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: AppTheme.spacing8,
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusRound,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor: AppColors
                                                  .textTertiary
                                                  .withOpacity(0.2),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    color,
                                                  ),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing16),
                                  ],
                                );
                              }),
                            ],
                            const SizedBox(height: AppTheme.spacing24),
                            // Recent Grades
                            Text(
                              'Notas Recientes',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            ...state.grades.take(10).map((grade) {
                              return Column(
                                children: [
                                  AnimatedCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              grade.subject,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppTheme.spacing12,
                                                    vertical: AppTheme.spacing4,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: grade.percentage >= 90
                                                    ? AppColors.primaryGradient
                                                    : null,
                                                color: grade.percentage >= 90
                                                    ? null
                                                    : grade.percentage >= 75
                                                    ? AppColors.success
                                                          .withOpacity(0.2)
                                                    : AppColors.warning
                                                          .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppTheme.radiusRound,
                                                    ),
                                              ),
                                              child: Text(
                                                '${grade.percentage.toStringAsFixed(0)}%',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      color:
                                                          grade.percentage >= 90
                                                          ? Colors.white
                                                          : grade.percentage >=
                                                                75
                                                          ? AppColors.success
                                                          : AppColors.warning,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: AppTheme.spacing8,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${grade.score} / ${grade.maxScore}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                            Text(
                                              ' • ',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                            Text(
                                              _getCategoryName(grade.category),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                            Text(
                                              ' • ',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                            Text(
                                              DateFormat(
                                                'MMM dd, yyyy',
                                              ).format(grade.date),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing16),
                                ],
                              );
                            }),
                            const SizedBox(height: AppTheme.spacing80),
                          ],
                        ),
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
            builder: (context) => const AddGradeScreen(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Nota'),
      ),
    );
  }
}
