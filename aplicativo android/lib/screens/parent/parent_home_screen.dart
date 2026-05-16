import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/apps_provider.dart';
import '../../providers/triggers_provider.dart';
import '../../providers/link_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/alert.dart';
import 'alerts_list_screen.dart';
import 'select_apps_screen.dart';
import 'triggers_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final link = context.read<LinkProvider>();
    await link.restoreLinkedChild();
    await context.read<AlertsProvider>().load();
    await context.read<TriggersProvider>().load();
    if (link.linkedChildId != null) {
      await context.read<AppsProvider>().loadApps(link.linkedChildId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('Vigília'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          AlertsListScreen(embedded: true),
          SelectAppsScreen(embedded: true),
          TriggersScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: context.watch<AlertsProvider>().unseenCount > 0,
              label: Text(context.watch<AlertsProvider>().unseenCount.toString()),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alertas',
          ),
          const NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Apps'),
          const NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Gatilhos'),
        ],
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
    final triggers = context.watch<TriggersProvider>();

    return RefreshIndicator(
      onRefresh: () => alerts.load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.primary.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(
                    value: apps.apps.where((a) => a.isMonitored).length.toString(),
                    label: 'Apps monitorados',
                    icon: Icons.apps,
                  ),
                  _Stat(
                    value: triggers.triggers.where((t) => t.active).length.toString(),
                    label: 'Gatilhos ativos',
                    icon: Icons.tune,
                  ),
                  _Stat(
                    value: alerts.unseenCount.toString(),
                    label: 'Não lidos',
                    icon: Icons.notifications,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Alertas recentes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (alerts.loading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (alerts.alerts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(children: [
                  Icon(Icons.check_circle, size: 48, color: AppTheme.primary),
                  SizedBox(height: 8),
                  Text('Nenhum alerta ainda', style: TextStyle(color: Colors.grey)),
                ]),
              ),
            )
          else
            ...alerts.alerts.take(5).map((a) => _AlertCard(alert: a)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(alert.riskLevel);
    final fmt = DateFormat('HH:mm · dd/MM');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, Routes.alertDetail, arguments: alert),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(AppTheme.riskIcon(alert.riskLevel), color: color),
        ),
        title: Text(
          alert.categories.join(', '),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${fmt.format(alert.timestamp)} · ${alert.appName ?? ""}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: alert.seen
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
      ),
    );
  }
}
