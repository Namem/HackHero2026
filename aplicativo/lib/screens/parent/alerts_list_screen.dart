import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/alert.dart';
import '../../providers/alerts_provider.dart';

class AlertsListScreen extends StatefulWidget {
  final bool embedded;
  const AlertsListScreen({super.key, this.embedded = false});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AlertsProvider>().load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertsProvider>();

    Widget body;
    if (alerts.loading) {
      body = const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    } else if (alerts.alerts.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.safe.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 36, color: AppTheme.safe),
            ),
            const SizedBox(height: 16),
            const Text('Tudo tranquilo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Nenhum alerta registrado', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      );
    } else {
      final high = alerts.alerts.where((a) => a.riskLevel > 6).toList();
      final medium = alerts.alerts.where((a) => a.riskLevel > 3 && a.riskLevel <= 6).toList();
      final low = alerts.alerts.where((a) => a.riskLevel <= 3).toList();

      body = RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => alerts.load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (high.isNotEmpty) ...[
              _SectionHeader(label: 'Risco Alto', count: high.length, color: AppTheme.danger, bg: const Color(0xFFFEE2E2)),
              ...high.map((a) => _AlertTile(alert: a)),
              const SizedBox(height: 12),
            ],
            if (medium.isNotEmpty) ...[
              _SectionHeader(label: 'Risco Médio', count: medium.length, color: AppTheme.warning, bg: const Color(0xFFFFEDD5)),
              ...medium.map((a) => _AlertTile(alert: a)),
              const SizedBox(height: 12),
            ],
            if (low.isNotEmpty) ...[
              _SectionHeader(label: 'Risco Baixo', count: low.length, color: AppTheme.safe, bg: const Color(0xFFD1FAE5)),
              ...low.map((a) => _AlertTile(alert: a)),
            ],
          ],
        ),
      );
    }

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: body,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _SectionHeader({required this.label, required this.count, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
            child: Text('$count', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Alert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(alert.riskLevel);
    final fmt = DateFormat('HH:mm · dd/MM');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, Routes.alertDetail, arguments: alert),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${AppTheme.riskLabel(alert.riskLevel)} detectado',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!alert.seen)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toque para ver como conversar sobre isso',
                          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${fmt.format(alert.timestamp)} · ${alert.appName ?? ""}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                        ),
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
