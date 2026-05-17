import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/apps_provider.dart';
import '../../providers/link_provider.dart';
import '../../models/alert.dart';
import '../../data/awareness_tips.dart';
import '../../widgets/aura_logo.dart';
import 'alerts_list_screen.dart';
import 'select_apps_screen.dart';
import 'parent_profile_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _tab = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      // Auto-refresh dos alertas a cada 10s — útil para captar simulações da criança em tempo real
      _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) context.read<AlertsProvider>().load();
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final link = context.read<LinkProvider>();
    await link.restoreLinkedChild();
    await link.checkStatus();
    await context.read<AlertsProvider>().load();
    await context.read<AppsProvider>().loadApps(link.linkedChildId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const AuraLogo(size: 30, showLabel: true),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          AlertsListScreen(embedded: true),
          SelectAppsScreen(embedded: true),
          ParentProfileScreen(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppTheme.primaryDark,
            indicatorColor: AppTheme.primary.withValues(alpha: 0.25),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white);
              return IconThemeData(color: Colors.white.withValues(alpha: 0.45));
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700);
              }
              return TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11);
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: context.watch<AlertsProvider>().unseenCount > 0,
                label: Text(context.watch<AlertsProvider>().unseenCount.toString()),
                backgroundColor: AppTheme.danger,
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: const Icon(Icons.notifications),
              label: 'Alertas',
            ),
            const NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Apps'),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertsProvider>();
    final apps = context.watch<AppsProvider>();

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => alerts.load(),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A6E), AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat("'Hoje,' dd 'de' MMMM", 'pt_BR').format(DateTime.now()),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Colors.white.withValues(alpha: 0.65)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aura está protegendo\nseus filhos',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5, height: 1.2),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _HeroStat(n: alerts.unseenCount.toString(), label: 'alertas', sub: 'novos', highlight: alerts.unseenCount > 0)),
                    const SizedBox(width: 10),
                    Expanded(child: _HeroStat(n: apps.apps.where((a) => a.isMonitored).length.toString(), label: 'jogos', sub: 'monitorados')),
                    const SizedBox(width: 10),
                    Expanded(child: _HeroStat(n: alerts.alerts.length.toString(), label: 'total', sub: 'histórico')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Alertas recentes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
              if (alerts.alerts.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text('Ver todos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (alerts.loading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.primary)))
          else if (alerts.alerts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: AppTheme.safe.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle, size: 28, color: AppTheme.safe),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tudo tranquilo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Nenhum alerta registrado', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ]),
              ),
            )
          else
            ...alerts.alerts.take(5).map((a) => _AlertCard(alert: a)),

          const SizedBox(height: 28),

          // ====== Conscientização ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Conscientização e dicas',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                ),
              ),
              Icon(Icons.menu_book_outlined, color: AppTheme.primary.withValues(alpha: 0.7), size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Em vez de saber exatamente o que aconteceu, aprenda a conversar e orientar.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: AwarenessTipsData.tips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _AwarenessCard(tip: AwarenessTipsData.tips[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AwarenessCard extends StatelessWidget {
  final AwarenessTip tip;
  const _AwarenessCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            Routes.awarenessDetail,
            arguments: tip,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: tip.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tip.icon, color: tip.color, size: 20),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tip.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tip.category,
                        style: TextStyle(
                          color: tip.color,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    tip.summary,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Ler dica',
                      style: TextStyle(
                        color: tip.color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: tip.color, size: 13),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String n;
  final String label;
  final String sub;
  final bool highlight;

  const _HeroStat({required this.n, required this.label, required this.sub, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.danger.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: highlight ? AppTheme.danger.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(n, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: highlight ? const Color(0xFFFF6B6B) : Colors.white, letterSpacing: -1)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.55))),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(alert.riskLevel);
    final bg = AppTheme.riskBg(alert.riskLevel);
    final fg = AppTheme.riskFg(alert.riskLevel);
    final fmt = DateFormat('HH:mm · dd/MM');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, Routes.alertDetail, arguments: alert),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                          child: Icon(AppTheme.riskIcon(alert.riskLevel), color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                                child: Text(AppTheme.riskLabel(alert.riskLevel), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text('${AppTheme.riskLabel(alert.riskLevel)} detectado', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 4),
                            Text('${fmt.format(alert.timestamp)} · ${alert.appName ?? ""}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            const SizedBox(height: 2),
                            Text('Toque para ver orientação', style: TextStyle(fontSize: 10.5, color: color.withValues(alpha: 0.7), fontStyle: FontStyle.italic)),
                          ],
                        )),
                        if (!alert.seen)
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
