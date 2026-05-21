import 'package:flutter/material.dart';
import 'package:kickin/kickin.dart';

void main() {
  runApp(const ProviderScope(child: KickinExampleApp()));
}

class KickinExampleApp extends StatelessWidget {
  const KickinExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5EE6A8), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF07111F),
        textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const _ExampleHomePage(),
    );
  }
}

class _ExampleHomePage extends StatefulWidget {
  const _ExampleHomePage();

  @override
  State<_ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<_ExampleHomePage> {
  bool showDetails = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setAppBar(context));
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold<void>(
      title: 'Kickin',
      subtitle: 'Package example',
      applyDefaultAppBar: true,
      backgroundColor: const Color(0xFF07111F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KText(
                'Kickin package demo',
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.05,
              ),
              KSpacing.sm.toVBox,
              KText(
                'This example uses KScaffold, KText, KSpacing, KAnimatedSizing, and the context extensions that ship with the package.',
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
                maxLines: 3,
              ),
              KSpacing.lg.toVBox,
              Row(
                children: const [
                  Expanded(
                    child: _FeatureCard(title: 'Spacing', body: 'KSpacing.md.toHBox keeps layout gaps consistent.'),
                  ),
                  SizedBox(width: KSpacing.md),
                  Expanded(
                    child: _FeatureCard(title: 'Text', body: 'KText gives a cleaner wrapper around Text.'),
                  ),
                ],
              ),
              KSpacing.lg.toVBox,
              KAnimatedSizing.slow(
                child: _DetailsPanel(expanded: showDetails, widthHint: context.deviceWidth),
              ),
              KSpacing.md.toVBox,
              FilledButton.icon(
                onPressed: () => setState(() => showDetails = !showDetails),
                icon: Icon(showDetails ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                label: Text(showDetails ? 'Hide package details' : 'Show package details'),
              ),
              KSpacing.lg.toVBox,
              const _FooterStrip(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String body;

  const _FeatureCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KText(title, fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            KSpacing.xs.toVBox,
            KText(body, fontSize: 13, color: Colors.white70, height: 1.45),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final bool expanded;
  final double widthHint;

  const _DetailsPanel({required this.expanded, required this.widthHint});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14304F), Color(0xFF10233B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.widgets_outlined, color: Colors.white),
                KSpacing.sm.toHBox,
                Expanded(
                  child: KText(
                    'Animated package surface',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            KSpacing.sm.toVBox,
            KText('Window width: ${widthHint.toStringAsFixed(0)} px', fontSize: 13, color: Colors.white70),
            if (expanded) ...[
              KSpacing.md.toVBox,
              KText(
                'This panel expands and collapses with KAnimatedSizing. The example also uses the package-level scaffold builder to create a custom app bar.',
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
              KSpacing.md.toVBox,
              Wrap(
                spacing: KSpacing.sm,
                runSpacing: KSpacing.sm,
                children: const [
                  _LabelChip(label: 'KScaffold'),
                  _LabelChip(label: 'KText'),
                  _LabelChip(label: 'KSpacing'),
                  _LabelChip(label: 'KAnimatedSizing'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;

  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KSpacing.md, vertical: KSpacing.xxs),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999)),
      child: KText(label, fontSize: 12, color: Colors.white),
    );
  }
}

class _FooterStrip extends StatelessWidget {
  const _FooterStrip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(KSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.rocket_launch_outlined, color: Colors.white70),
            KSpacing.sm.toHBox,
            Expanded(
              child: KText(
                'Use this file as the starting point for package consumers.',
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void setAppBar(BuildContext context) {
  KScaffold.appBarBuilderArgs = (title, subtitle, onBackButtonPressed) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(KSpacing.lg, KSpacing.md, KSpacing.lg, KSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF10172A).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KSpacing.md, vertical: KSpacing.sm),
            child: Row(
              children: [
                if (onBackButtonPressed != null)
                  IconButton(
                    onPressed: () => onBackButtonPressed(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                    tooltip: 'Back',
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KText(
                        title,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        wrapWithTooltip: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (subtitle != null) ...[
                        KSpacing.xxs.toVBox,
                        KText(
                          subtitle,
                          fontSize: 12,
                          color: Colors.white70,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.hexagon_outlined, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  };
}
