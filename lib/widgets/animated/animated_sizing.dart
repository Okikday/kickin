import 'package:flutter/material.dart';

/// A widget that automatically animates its size when its child's size changes.
///
/// This is a convenience wrapper around [AnimatedSize] that provides sensible defaults
/// and factory constructors for different animation speeds.
class KAnimatedSizing extends StatelessWidget {
  /// The duration of the sizing animation.
  final Duration? duration;

  /// The curve of the sizing animation.
  final Curve? curve;

  /// The widget below this widget in the tree.
  final Widget child;

  const KAnimatedSizing({super.key, this.duration, this.curve, required this.child});

  /// Creates an [KAnimatedSizing] with a fast animation duration (400ms).
  factory KAnimatedSizing.fast({required Widget child}) {
    return KAnimatedSizing(duration: const Duration(milliseconds: 400), child: child);
  }

  /// Creates an [KAnimatedSizing] with a normal animation duration (700ms).
  factory KAnimatedSizing.normal({required Widget child}) {
    return KAnimatedSizing(child: child);
  }

  /// Creates an [KAnimatedSizing] with a slow animation duration (1000ms).
  factory KAnimatedSizing.slow({required Widget child}) {
    return KAnimatedSizing(duration: const Duration(milliseconds: 1000), child: child);
  }
  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: duration ?? const Duration(milliseconds: 700),
    curve: curve ?? Curves.decelerate,
    child: child,
  );
}
