import 'package:flutter/material.dart';

/// A lightweight text widget that applies sensible defaults from the theme.
///
/// Wraps [Text] and provides convenient parameters for common styling needs,
/// plus an optional tooltip when text is truncated.
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final bool? softWrap;
  final int? maxLines;
  final double? height;
  final double? letterSpacing;
  final bool wrapWithTooltip;
  final String? fontFamily;
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign,
    this.overflow,
    this.softWrap,
    this.maxLines,
    this.height,
    this.letterSpacing,
    this.wrapWithTooltip = false,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final child = Text(
      data,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
      style:
          style ??
          Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            fontFamily: fontFamily ?? 'Montserrat',
            height: height,
            letterSpacing: letterSpacing,
          ),
      maxLines: maxLines,
    );
    if (wrapWithTooltip) {
      return Tooltip(
        message: data,
        triggerMode: TooltipTriggerMode.longPress,
        showDuration: const Duration(seconds: 4),
        child: child,
      );
    } else {
      return child;
    }
  }
}
