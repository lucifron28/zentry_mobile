import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradient;
  final double? blur;
  final double? opacity;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;

  const GlassCard({
    super.key,
    required this.child,
    this.gradient,
    this.blur,
    this.opacity,
    this.margin,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBlur = blur ?? 10.0;
    final effectiveOpacity = opacity ?? 0.1;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppSizes.radiusMd);
    final effectivePadding = padding ?? const EdgeInsets.all(AppSizes.paddingMd);
    
    Widget cardContent = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient!.map((color) => color.withOpacity(effectiveOpacity)).toList(),
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.cardBackground.withOpacity(effectiveOpacity),
                      AppColors.secondaryBackground.withOpacity(effectiveOpacity * 0.8),
                    ],
                  ),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          padding: effectivePadding,
          child: child,
        ),
      ),
    );

    if (onTap != null && enabled) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          splashColor: AppColors.textPrimary.withOpacity(0.1),
          highlightColor: AppColors.textPrimary.withOpacity(0.05),
          child: cardContent,
        ),
      );
    }

    if (margin != null) {
      cardContent = Container(
        margin: margin,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final List<Color>? gradient;
  final double? blur;
  final double? opacity;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final Duration animationDuration;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.gradient,
    this.blur,
    this.opacity,
    this.margin,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.animationDuration = AppConstants.mediumAnimation,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GlassCard(
              gradient: widget.gradient,
              blur: widget.blur,
              opacity: widget.opacity,
              margin: widget.margin,
              padding: widget.padding,
              borderRadius: widget.borderRadius,
              onTap: widget.onTap,
              enabled: widget.enabled,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class PulsingGlassCard extends StatefulWidget {
  final Widget child;
  final List<Color>? gradient;
  final double? blur;
  final double? opacity;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final bool shouldPulse;
  final Duration pulseDuration;

  const PulsingGlassCard({
    super.key,
    required this.child,
    this.gradient,
    this.blur,
    this.opacity,
    this.margin,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shouldPulse = false,
    this.pulseDuration = const Duration(seconds: 2),
  });

  @override
  State<PulsingGlassCard> createState() => _PulsingGlassCardState();
}

class _PulsingGlassCardState extends State<PulsingGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse != oldWidget.shouldPulse) {
      if (widget.shouldPulse) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.shouldPulse ? _pulseAnimation.value : 1.0,
          child: GlassCard(
            gradient: widget.gradient,
            blur: widget.blur,
            opacity: widget.opacity,
            margin: widget.margin,
            padding: widget.padding,
            borderRadius: widget.borderRadius,
            onTap: widget.onTap,
            enabled: widget.enabled,
            child: widget.child,
          ),
        );
      },
    );
  }
}
