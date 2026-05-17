import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../data/awareness_tips.dart';

class AwarenessDetailScreen extends StatelessWidget {
  const AwarenessDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tip = ModalRoute.of(context)!.settings.arguments as AwarenessTip;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: tip.color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tip.color,
                      Color.lerp(tip.color, AppTheme.primaryDark, 0.4)!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tip.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tip.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tip.color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(tip.icon, color: tip.color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip.summary,
                              style: TextStyle(
                                color: AppTheme.primaryDark.withValues(alpha: 0.85),
                                fontSize: 13.5,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Sections
                    for (final section in tip.sections) ...[
                      _SectionWidget(section: section, accent: tip.color),
                      const SizedBox(height: 18),
                    ],

                    // Source
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip.source,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Disclaimer
                    Center(
                      child: Text(
                        'Conteúdo educativo. Não substitui orientação profissional.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final AwarenessSection section;
  final Color accent;
  const _SectionWidget({required this.section, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        if (section.body.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              section.body,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
        if (section.bullets != null && section.bullets!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in section.bullets!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 7, right: 10),
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bullet,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
