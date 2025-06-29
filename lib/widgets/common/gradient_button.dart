import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradient;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppColors.purpleGradient,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.enabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = widget.height ?? AppSizes.buttonHeight;
    final effectivePadding = widget.padding ?? 
        const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg);
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(AppSizes.radiusMd);
    final effectiveTextStyle = widget.textStyle ?? 
        Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapCancel,
            onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              width: widget.width,
              height: effectiveHeight,
              padding: effectivePadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.enabled 
                      ? widget.gradient 
                      : widget.gradient.map((c) => c.withValues(alpha: 0.5)).toList(),
                ),
                borderRadius: effectiveBorderRadius,
                boxShadow: widget.enabled && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: widget.gradient.first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.paddingSm),
                          ],
                          Text(
                            widget.text,
                            style: effectiveTextStyle,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OutlineGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradient;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final bool enabled;

  const OutlineGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppColors.purpleGradient,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.enabled = true,
  });

  @override
  State<OutlineGradientButton> createState() => _OutlineGradientButtonState();
}

class _OutlineGradientButtonState extends State<OutlineGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = widget.height ?? AppSizes.buttonHeight;
    final effectivePadding = widget.padding ?? 
        const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg);
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(AppSizes.radiusMd);
    final effectiveTextStyle = widget.textStyle ?? 
        Theme.of(context).textTheme.titleMedium?.copyWith(
          color: widget.enabled ? widget.gradient.first : AppColors.textMuted,
          fontWeight: FontWeight.w600,
        );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapCancel,
            onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              width: widget.width,
              height: effectiveHeight,
              padding: effectivePadding,
              decoration: BoxDecoration(
                gradient: _isPressed && widget.enabled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.gradient.map((c) => c.withValues(alpha: 0.1)).toList(),
                      )
                    : null,
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  width: 2,
                  color: widget.enabled 
                      ? widget.gradient.first 
                      : AppColors.textMuted,
                ),
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.gradient.first,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.enabled 
                                  ? widget.gradient.first 
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.paddingSm),
                          ],
                          Text(
                            widget.text,
                            style: effectiveTextStyle,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IconGradientButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final List<Color> gradient;
  final bool isLoading;
  final double size;
  final BorderRadius? borderRadius;
  final bool enabled;

  const IconGradientButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.gradient = AppColors.purpleGradient,
    this.isLoading = false,
    this.size = 48,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  State<IconGradientButton> createState() => _IconGradientButtonState();
}

class _IconGradientButtonState extends State<IconGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(widget.size / 2);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapCancel,
            onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.enabled 
                      ? widget.gradient 
                      : widget.gradient.map((c) => c.withValues(alpha: 0.5)).toList(),
                ),
                borderRadius: effectiveBorderRadius,
                boxShadow: widget.enabled && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: widget.gradient.first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: widget.size * 0.4,
                        height: widget.size * 0.4,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: AppColors.textPrimary,
                        size: widget.size * 0.5,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
