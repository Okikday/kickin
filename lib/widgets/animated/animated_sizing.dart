import 'package:flutter/material.dart';
import 'package:kickin/core/base/src/extensions/extensions.dart';

class AnimatedSizing extends StatelessWidget {
  final Duration? duration;
  final Curve? curve;
  final Widget child;
  const AnimatedSizing({super.key, this.duration, this.curve, required this.child});
  factory AnimatedSizing.fast({required Widget child}) {
    return AnimatedSizing(duration: const Duration(milliseconds: 400), child: child);
  }

  factory AnimatedSizing.normal({required Widget child}) {
    return AnimatedSizing(child: child);
  }

  factory AnimatedSizing.slow({required Widget child}) {
    return AnimatedSizing(duration: const Duration(milliseconds: 1000), child: child);
  }
  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: duration ?? const Duration(milliseconds: 700),
    curve: curve ?? Curves.decelerate,
    child: child,
  );
}
