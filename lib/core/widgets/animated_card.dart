import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/theme.dart';
import '../theme/app_animations.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool useGlass;
  final Gradient? gradient;
  final double? height;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.useGlass = false,
    this.gradient,
    this.height,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AppAnimations.standard,
            curve: AppAnimations.easeOut,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              color: widget.useGlass ? null : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: widget.useGlass
                  ? Border.all(color: AppColors.glassBorder, width: 1.5)
                  : null,
              boxShadow: _isHovered
                  ? AppTheme.elevatedShadow
                  : AppTheme.cardShadow,
            ),
            child: widget.useGlass
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.glassBackground,
                              AppColors.glassBackground.withOpacity(0.05),
                            ],
                          ),
                        ),
                        padding: widget.padding ??
                            const EdgeInsets.all(AppTheme.spacing16),
                        child: widget.child,
                      ),
                    ),
                  )
                : Padding(
                    padding: widget.padding ??
                        const EdgeInsets.all(AppTheme.spacing16),
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}
