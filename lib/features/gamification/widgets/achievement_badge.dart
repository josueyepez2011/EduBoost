import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../data/models/achievement_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/app_animations.dart';

class AchievementBadge extends StatefulWidget {
  final AchievementModel achievement;
  final bool showAnimation;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showAnimation = false,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.achievementDuration,
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    if (widget.showAnimation && widget.achievement.isUnlocked) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: widget.achievement.isUnlocked
            ? AppColors.primaryGradient
            : null,
        color: widget.achievement.isUnlocked
            ? null
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: widget.achievement.isUnlocked
              ? Colors.transparent
              : AppColors.textTertiary.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Text(
            widget.achievement.icon,
            style: TextStyle(
              fontSize: 48,
              color: widget.achievement.isUnlocked
                  ? Colors.white
                  : AppColors.textTertiary.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          // Title
          Text(
            widget.achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: widget.achievement.isUnlocked
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacing4),
          // Description
          Text(
            widget.achievement.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.achievement.isUnlocked
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.textTertiary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!widget.achievement.isUnlocked) ...[
            const SizedBox(height: AppTheme.spacing12),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  child: LinearProgressIndicator(
                    value: widget.achievement.progress,
                    backgroundColor:
                        AppColors.textTertiary.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPurple,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  '${widget.achievement.currentCount}/${widget.achievement.requiredCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (widget.showAnimation && widget.achievement.isUnlocked) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Shimmer.fromColors(
          baseColor: AppColors.primaryPurple,
          highlightColor: AppColors.primaryPink,
          period: AppAnimations.shimmerDuration,
          child: badge,
        ),
      );
    }

    return badge;
  }
}
