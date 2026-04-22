import 'package:flutter/material.dart';
import 'theme_constants.dart';

/// Custom Page Transitions
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeSlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.3, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: AnimationDurations.medium,
          reverseTransitionDuration: AnimationDurations.quick,
        );
}

/// Fade Transition Page Route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AnimationDurations.normal,
        );
}

/// Hero Animation Helper - For property cards
class PropertyHeroAnimation extends StatelessWidget {
  final String tag;
  final Widget child;

  const PropertyHeroAnimation({
    required this.tag,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext,
          toContext) {
        return ScaleTransition(
          scale: animation,
          child: fromContext.widget,
        );
      },
      child: child,
    );
  }
}

/// Animated Bounce Widget - For FAB and interactive elements
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const BounceAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.elasticOut,
    super.key,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: widget.child,
    );
  }
}

/// Animated Button - Scales on press with ripple effect
class AnimatedPressButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Duration duration;

  const AnimatedPressButton({
    required this.onPressed,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    super.key,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _controller.forward();
  }

  void _onTapUp() {
    _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Animated Card Entrance - Cards slide and fade in
class AnimatedCardEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedCardEntrance({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<AnimatedCardEntrance> createState() => _AnimatedCardEntranceState();
}

class _AnimatedCardEntranceState extends State<AnimatedCardEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}

/// Image Fade-In Animation
class FadeInImage extends StatefulWidget {
  final ImageProvider image;
  final Widget? placeholder;
  final Duration duration;

  const FadeInImage({
    required this.image,
    this.placeholder,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<FadeInImage> createState() => _FadeInImageState();
}

class _FadeInImageState extends State<FadeInImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Image _image;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _image = Image(image: widget.image);

    _image.image.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener(
        (image, synchronousCall) {
          if (mounted) {
            setState(() => _imageLoaded = true);
            _controller.forward();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_imageLoaded && widget.placeholder != null) widget.placeholder!,
        if (_imageLoaded)
          FadeTransition(
            opacity: _controller,
            child: _image,
          ),
      ],
    );
  }
}

/// Animated Rating Stars - Stagger animation
class AnimatedStarRating extends StatefulWidget {
  final double rating;
  final int maxRating;
  final double size;

  const AnimatedStarRating({
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    super.key,
  });

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.maxRating,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 80), () {
          if (mounted) _controllers[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.maxRating,
        (index) => ScaleTransition(
          scale: _controllers[index],
          child: Icon(
            index < widget.rating.floor() ? Icons.star : Icons.star_border,
            color: RentifyTheme.goldPrimary,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}

/// Shimmer Loading Effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({required this.child, super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(-1 - _controller.value * 2, 0),
          end: Alignment(-_controller.value * 2, 0),
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

/// Pulse Animation - For attention-grabbing elements
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
