import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Use [ref.context] to access the [BuildContext context]
typedef KAbsorberBuilder<OutT> = Widget Function(WidgetRef ref, OutT value, Widget? _);

/// Small helper API for embedding provider `watch` and `read` builders inline.
///
/// Provides convenience static methods `Absorb.watch` and `Absorb.read` which
/// return lightweight widgets that expose a `ref` and provider value to a builder.
class KAbsorber {
  static Widget watch<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required KAbsorberBuilder<OutT> builder,
    Widget? child,
  }) => KAbsorbWatch(key: key, listenable: listenable, builder: builder, child: child);

  static Widget read<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required KAbsorberBuilder<OutT> builder,
    Widget? child,
  }) => KAbsorbRead(key: key, listenable: listenable, builder: builder, child: child);
}

/// Watches the Provider supplied
class KAbsorbWatch<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final KAbsorberBuilder<OutT> builder;
  final Widget? child;
  const KAbsorbWatch({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(ref, ref.watch(listenable), child);
}

/// Reads the Provider supplied
class KAbsorbRead<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final KAbsorberBuilder<OutT> builder;
  final Widget? child;
  const KAbsorbRead({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(ref, ref.read(listenable), child);
}
