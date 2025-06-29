import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'glass_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final List<Color>? gradient;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.gradient,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: gradient,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSm),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconMd,
                    color: gradient?.first ?? AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMd),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: gradient?.first ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.paddingXs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final List<Color>? gradient;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Duration animationDuration;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.gradient,
    this.onTap,
    this.trailing,
    this.animationDuration = AppConstants.mediumAnimation,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;
  late Animation<double> _scaleAnimation;
  
  String _previousValue = '';
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _countAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _currentValue = widget.value;
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _currentValue = widget.value;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getAnimatedValue() {
    // Try to animate numeric values
    final previousNum = double.tryParse(_previousValue.replaceAll(RegExp(r'[^0-9.]'), ''));
    final currentNum = double.tryParse(_currentValue.replaceAll(RegExp(r'[^0-9.]'), ''));
    
    if (previousNum != null && currentNum != null) {
      final animatedNum = previousNum + (currentNum - previousNum) * _countAnimation.value;
      return _currentValue.replaceAll(RegExp(r'[0-9.]+'), animatedNum.toStringAsFixed(0));
    }
    
    return _currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: StatCard(
            title: widget.title,
            value: _getAnimatedValue(),
            subtitle: widget.subtitle,
            icon: widget.icon,
            gradient: widget.gradient,
            onTap: widget.onTap,
            trailing: widget.trailing,
          ),
        );
      },
    );
  }
}

class CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingSm),
              decoration: BoxDecoration(
                color: (color ?? AppColors.textPrimary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                icon,
                size: AppSizes.iconSm,
                color: color ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressStatCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final String? subtitle;
  final IconData? icon;
  final List<Color>? gradient;
  final VoidCallback? onTap;

  const ProgressStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    this.subtitle,
    this.icon,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: gradient,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSm),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconMd,
                    color: gradient?.first ?? AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMd),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                AppHelpers.formatPercentage(progress),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: gradient?.first ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                gradient?.first ?? AppColors.textPrimary,
              ),
              minHeight: 6,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
