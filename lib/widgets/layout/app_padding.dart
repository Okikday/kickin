import 'package:flutter/material.dart';
import 'package:kickin/core/base/src/extensions/extensions.dart';

/// Adds top padding equal to the system status bar inset plus an optional extra height.
///
/// Returns either a padded child or a sized box with the computed height.
class TopPadding extends StatelessWidget {
  final double? withHeight;
  final Widget? child;
  const TopPadding({super.key, this.withHeight, this.child});

  @override
  Widget build(BuildContext context) {
    final withTopPadding = context.topPadding + (withHeight ?? 0.0);
    return child != null
        ? Padding(
            padding: EdgeInsetsGeometry.only(top: withTopPadding),
            child: child,
          )
        : SizedBox(height: withTopPadding);
  }
}

/// Adds bottom padding equal to the system bottom inset (keyboard, nav bar)
/// plus an optional extra height.
///
/// When [useKeyboardPadding] is true, additional padding is included for
/// the keyboard's inset so UI elements sit above the keyboard.
class BottomPadding extends StatelessWidget {
  final double? withHeight;
  final bool useKeyboardPadding;
  final Widget? child;
  const BottomPadding({super.key, this.withHeight, this.useKeyboardPadding = false, this.child});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = context.bottomPadding;
    return child != null
        ? Padding(
            padding: EdgeInsetsGeometry.only(
              bottom: bottomPadding + (withHeight ?? 0.0) + (useKeyboardPadding ? context.viewInsets.bottom : 0.0),
            ),
            child: child,
          )
        : SizedBox(height: bottomPadding + (withHeight ?? 0.0));
  }
}
