import 'package:flutter/material.dart';

/// Entrance animation that fades in and slides its [child] upward.
///
/// Uses an [Interval] over a single [AnimationController] when [delay] is
/// non-zero so the animation advances continuously without standalone timers.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 320),
    this.offsetY = 14.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: totalDuration);

    final startFraction = totalDuration.inMicroseconds > 0
        ? (widget.delay.inMicroseconds / totalDuration.inMicroseconds)
            .clamp(0.0, 0.95)
        : 0.0;

    _curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1.0, curve: widget.curve),
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
    return FadeTransition(
      opacity: _curved,
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.offsetY * (1.0 - _curved.value)),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Scale-and-fade entrance animation with an overshoot curve, suited for
/// confirmation icons, badges, and empty-state illustrations.
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;

  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.beginScale = 0.65,
  });

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: totalDuration);

    final startFraction = totalDuration.inMicroseconds > 0
        ? (widget.delay.inMicroseconds / totalDuration.inMicroseconds)
            .clamp(0.0, 0.95)
        : 0.0;

    _scale = Tween<double>(begin: widget.beginScale, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(startFraction, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1.0, curve: Curves.easeOut),
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
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// Subtle tactile press-down scale feedback that observes raw pointer events
/// without competing in the gesture arena with nested [InkWell] widgets.
class PressScale extends StatefulWidget {
  final Widget child;
  final double pressedScale;
  final bool enabled;

  const PressScale({
    super.key,
    required this.child,
    this.pressedScale = 0.96,
    this.enabled = true,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
      onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Animates short dynamic text (such as quantities, badges, and totals) with
/// a crisp vertical slide and fade whenever [text] changes.
class AnimatedValueText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const AnimatedValueText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: style,
      ),
    );
  }
}

/// Favorite heart icon that pops with an overshoot scale when toggled.
class AnimatedFavoriteIcon extends StatelessWidget {
  final bool isFavorite;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedFavoriteIcon({
    super.key,
    required this.isFavorite,
    required this.size,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        key: ValueKey<bool>(isFavorite),
        size: size,
        color: isFavorite ? activeColor : inactiveColor,
      ),
    );
  }
}
