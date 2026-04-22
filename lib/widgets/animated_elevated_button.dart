import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';
import '../utils/animations.dart';

/// Premium Animated Elevated Button
class AnimatedElevatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool useGradient;
  final Color? backgroundColor;

  const AnimatedElevatedButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.useGradient = true,
    this.backgroundColor,
    super.key,
  });

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() => _controller.forward();
  void _onTapUp() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) {
        _onTapUp();
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: _onTapUp,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          decoration: widget.useGradient
              ? BoxDecoration(
                  gradient: RentifyTheme.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: RentifyTheme.goldPrimary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : BoxDecoration(
                  color: widget.backgroundColor ?? RentifyTheme.goldPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (widget.backgroundColor ?? RentifyTheme.goldPrimary)
                              .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null && !widget.isLoading) ...[
                      Icon(widget.icon, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
