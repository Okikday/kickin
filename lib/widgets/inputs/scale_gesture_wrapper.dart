import 'package:flutter/material.dart';

/// A wrapper widget that provides a scaling "squish" effect when pressed.
///
/// This is typically used to create Apple/iOS style bouncy buttons, where the
/// button shrinks slightly when pressed down and bounces back when released.
class ScaleGestureWrapper extends StatefulWidget {
  /// The border radius used for the [InkWell] splash effect.
  final double borderRadius;

  /// The scale factors to animate between: (normal scale, pressed scale).
  /// Defaults to `(1.0, 0.9)`, meaning it shrinks to 90% of its size when pressed.
  final (double from, double to) scaleBetween;

  final void Function(TapDownDetails details)? onTapDown;

  /// The callback triggered when the pointer stops contacting the screen.
  /// You can use [delayReverseDuration] to delay the release animation.
  final void Function(TapUpDetails details)? onTapUp;

  /// The callback triggered when a tap is correctly resolved.
  final VoidCallback? onTap;

  /// The callback triggered when a long press is recognized.
  final VoidCallback? onLongPress;

  /// The duration of the scale animation. Defaults to [Durations.medium2].
  final Duration animationDuration;

  /// Optional delay before the widget scales back to its original size after release.
  final Duration? delayReverseDuration;

  /// The curve used for the scale animation.
  final Curve? curve;

  /// The widget below this widget in the tree.
  final Widget child;

  const ScaleGestureWrapper({
    super.key,
    this.scaleBetween = (1.0, 0.9),
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onLongPress,
    this.animationDuration = Durations.medium2,
    this.delayReverseDuration,
    this.borderRadius = 0,
    this.curve,
    required this.child,
  });

  @override
  State<ScaleGestureWrapper> createState() => _ScaleGestureWrapperState();
}

class _ScaleGestureWrapperState extends State<ScaleGestureWrapper> {
  late final ValueNotifier<bool> scaleClickNotifier;
  @override
  void initState() {
    super.initState();
    scaleClickNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    scaleClickNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: scaleClickNotifier,
      builder: (context, value, child) {
        return AnimatedScale(
          scale: value ? widget.scaleBetween.$2 : widget.scaleBetween.$1,
          duration: widget.animationDuration,
          curve: widget.curve ?? Curves.decelerate,
          child: _InnerScaleClickWrapper(
            scaleClickNotifier: scaleClickNotifier,
            borderRadius: widget.borderRadius,
            onTapDown: widget.onTapDown,
            onTapUp: widget.onTapUp,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            delayReverseDuration: widget.delayReverseDuration,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Internal widget that wires gesture callbacks to the scale notifier.
///
/// Responsible for forwarding tap/long-press events and updating the
/// provided [ValueNotifier] so the outer widget can animate the scale.
class _InnerScaleClickWrapper extends StatelessWidget {
  const _InnerScaleClickWrapper({
    required this.scaleClickNotifier,
    this.borderRadius = 0,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onLongPress,
    this.delayReverseDuration,
    required this.child,
  });

  final ValueNotifier<bool> scaleClickNotifier;
  final double borderRadius;
  final void Function(TapDownDetails details)? onTapDown;
  final void Function(TapUpDetails details)? onTapUp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration? delayReverseDuration;
  final Widget child;

  void updateScaleClickNotifier(bool newValue) {
    if (scaleClickNotifier.value == newValue) return;
    scaleClickNotifier.value = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTapDown: (details) {
          updateScaleClickNotifier(true);
          if (onTapDown != null) onTapDown!(details);
        },
        onTapCancel: () {
          updateScaleClickNotifier(false);
        },
        onTapUp: (details) async {
          await Future.delayed(delayReverseDuration ?? Durations.short1);
          updateScaleClickNotifier(false);
          if (onTapUp != null) onTapUp!(details);
        },
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
