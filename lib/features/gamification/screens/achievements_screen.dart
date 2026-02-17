import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/achievement_bloc.dart';
import '../widgets/achievement_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
                    'Logros',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Sigue tu progreso y desbloquea recompensas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AchievementBloc, AchievementState>(
                builder: (context, state) {
                  if (state is AchievementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AchievementLoaded) {
                    final unlockedCount = state.achievements
                        .where((a) => a.isUnlocked)
                        .length;
                    final totalCount = state.achievements.length;

                    return Column(
                      children: [
                        // Progress Summary
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing20,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacing20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLarge),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$unlockedCount / $totalCount',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  'Logros Desbloqueados',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacing16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusRound),
                                  child: LinearProgressIndicator(
                                    value: unlockedCount / totalCount,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.3),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        // Achievement Grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing20,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppTheme.spacing16,
                              mainAxisSpacing: AppTheme.spacing16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: state.achievements.length,
                            itemBuilder: (context, index) {
                              final achievement = state.achievements[index];
                              return AchievementBadge(
                                achievement: achievement,
                                showAnimation: achievement.id ==
                                    state.newlyUnlocked?.id,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: Text('Algo salió mal'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
