import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final bool showLabel;
  final String? label;
  final bool animated;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor = Colors.grey,
    this.gradientColors = AppColors.purpleGradient,
    this.showLabel = false,
    this.label,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.borderRadius,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      if (widget.animated) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel && widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withOpacity(0.3),
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: widget.animated ? _progressAnimation : AlwaysStoppedAnimation(widget.progress),
            builder: (context, child) {
              final progress = widget.animated ? _progressAnimation.value : widget.progress;
              return ClipRRect(
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(widget.height / 2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    widget.gradientColors.length == 1
                        ? widget.gradientColors.first
                        : null,
                  ),
                  minHeight: widget.height,
                ),
              );
            },
          ),
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '100%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int nextLevelXP;
  final int level;
  final bool showLevel;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.nextLevelXP,
    required this.level,
    this.showLevel = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nextLevelXP > 0 ? currentXP / nextLevelXP : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLevel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.purpleGradient.first,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currentXP / $nextLevelXP XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ProgressBar(
          progress: progress,
          height: 12,
          gradientColors: AppColors.tealGradient,
          backgroundColor: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
