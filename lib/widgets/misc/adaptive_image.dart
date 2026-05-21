import 'package:kickin/core/base/src/extensions/extensions.dart';
import 'package:kickin/core/models/file_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';

export 'package:kickin/core/models/file_path.dart';

/// A widget that adapts to display an image from either a local file or a network URL, with a fallback widget for error handling.
/// Only supports file paths that are either local or network URLs. If the path is invalid or unsupported, the fallback widget will be displayed.
class KAdaptiveImage extends StatelessWidget {
  final KFilePath path;
  final Widget fallbackWidget;
  final Size? size;
  final double scale = 1.0;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final String? semanticLabel;
  final bool excludeFromSemantics = false;
  final BoxFit? fit;
  final Alignment alignment = Alignment.center;
  final ImageRepeat repeat = ImageRepeat.noRepeat;
  final Rect? centerSlice;
  final bool matchTextDirection = false;
  final bool gaplessPlayback = false;
  final bool isAntiAlias = false;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality = FilterQuality.medium;

  const KAdaptiveImage({
    super.key,
    required this.path,
    required this.fallbackWidget,
    this.size,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.semanticLabel,
    this.fit,
    this.centerSlice,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final rPath = path.resolve();
    final src = rPath.data;
    final isLocal = rPath.isLocal;

    if (src == null) return fallbackWidget;

    return switch (isLocal) {
      true => Image(
        key: key,
        image: ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, _VersionedFileImage(File(src), scale: scale)),
        fit: fit,
        width: size?.width,
        height: size?.height,
        errorBuilder: (context, error, stackTrace) => fallbackWidget,
        frameBuilder: _frameBuilder,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
      ),
      false => CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        width: size?.width,
        height: size?.height,
        progressIndicatorBuilder: (context, url, progress) => const _LoadingPreview(),
        errorWidget: (context, error, stackTrace) => fallbackWidget,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        filterQuality: filterQuality,
      ),
    }.animate().fadeIn();
  }
}

/// Displays an image from raw memory bytes with optional sizing and a fallback.
///
/// Use this when you have image data as `Uint8List` (for example, loaded from
/// an isolate or network response) and want a simple widget that renders it
/// with error handling and a frame placeholder.
class ImageFromMemory extends ConsumerWidget {
  const ImageFromMemory({
    super.key,
    required this.imageBytes,
    required this.fit,
    required this.width,
    required this.height,
    required this.fallbackWidget,
  });

  final Uint8List? imageBytes;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallbackWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Image.memory(
      imageBytes!,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: _frameBuilder,
      errorBuilder: (context, error, stackTrace) => fallbackWidget,
    );
  }
}

Widget _frameBuilder(BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) =>
    wasSynchronouslyLoaded || frame != null ? child : const _LoadingPreview();

class _LoadingPreview extends StatelessWidget {
  final double? progress;
  // ignore: unused_element_parameter
  const _LoadingPreview({this.progress});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox.expand(child: ColoredBox(color: theme.primaryColor.withAlpha(40)))
        .animate(onInit: (controller) => controller.repeat())
        .shimmer(duration: const Duration(seconds: 1), curve: Curves.decelerate)
        .blurXY(begin: 2, end: 0, duration: Duration(seconds: 1))
        .animate(onComplete: (controller) => controller.repeat(reverse: true))
        .tint(color: theme.primaryColor.withAlpha(10), duration: Duration(seconds: 1));
  }
}

class _VersionedFileImage extends FileImage {
  const _VersionedFileImage(super.file, {super.scale = 1.0});

  int get version {
    try {
      final stat = file.statSync();
      return Object.hash(stat.modified.millisecondsSinceEpoch, stat.size);
    } catch (_) {
      return file.path.hashCode;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is _VersionedFileImage &&
        other.file.path == file.path &&
        other.scale == scale &&
        other.version == version;
  }

  @override
  int get hashCode => Object.hash(file.path, scale, version);
}
