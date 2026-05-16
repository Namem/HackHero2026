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
      body = const Center(child: CircularProgressIndicator());
    } else if (alerts.alerts.isEmpty) {
      body = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum alerta registrado', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => alerts.load(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: alerts.alerts.length,
          itemBuilder: (_, i) => _AlertTile(alert: alerts.alerts[i]),
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

class _AlertTile extends StatelessWidget {
  final Alert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(alert.riskLevel);
    final fmt = DateFormat('HH:mm · dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, Routes.alertDetail, arguments: alert),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(AppTheme.riskIcon(alert.riskLevel), color: color),
        ),
        title: Row(
          children: [
            Text(
              AppTheme.riskLabel(alert.riskLevel),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.categories.join(', '),
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text('${fmt.format(alert.timestamp)} · ${alert.appName ?? ""}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        isThreeLine: true,
        trailing: alert.seen
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
      ),
    );
  }
}
