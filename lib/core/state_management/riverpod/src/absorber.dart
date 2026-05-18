import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Use [ref.context] to access the [BuildContext context]
typedef AbsorbBuilder<OutT> = Widget Function(WidgetRef ref, OutT value, Widget? _);

/// Small helper API for embedding provider `watch` and `read` builders inline.
///
/// Provides convenience static methods `Absorb.watch` and `Absorb.read` which
/// return lightweight widgets that expose a `ref` and provider value to a builder.
class Absorb {
  static Widget watch<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required AbsorbBuilder<OutT> builder,
    Widget? child,
  }) => AbsorbWatch(key: key, listenable: listenable, builder: builder, child: child);

  static Widget read<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required AbsorbBuilder<OutT> builder,
    Widget? child,
  }) => AbsorbRead(key: key, listenable: listenable, builder: builder, child: child);
}

/// Watches the Provider supplied
class AbsorbWatch<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final AbsorbBuilder<OutT> builder;
  final Widget? child;
  const AbsorbWatch({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(ref, ref.watch(listenable), child);
}

/// Reads the Provider supplied
class AbsorbRead<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final AbsorbBuilder<OutT> builder;
  final Widget? child;
  const AbsorbRead({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(ref, ref.read(listenable), child);
}
