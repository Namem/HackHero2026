import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/alert.dart';
import '../../providers/alerts_provider.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alert = ModalRoute.of(context)!.settings.arguments as Alert;
    final color = AppTheme.riskColor(alert.riskLevel);
    final fmt = DateFormat('HH:mm · dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nível de risco
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppTheme.riskIcon(alert.riskLevel), color: color, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          AppTheme.riskLabel(alert.riskLevel),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                        ),
                        const Spacer(),
                        Text('${alert.riskLevel}/10', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: alert.riskLevel / 10,
                        minHeight: 8,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categorias
            if (alert.categories.isNotEmpty) ...[
              const Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: alert.categories
                    .map((c) => Chip(
                          label: Text(c),
                          backgroundColor: color.withOpacity(0.1),
                          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Descrição
            const Text('Descrição da IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(alert.description, style: const TextStyle(height: 1.5)),
              ),
            ),
            const SizedBox(height: 16),

            // Detalhes
            const Text('Detalhes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _DetailRow(label: 'Horário', value: fmt.format(alert.timestamp)),
                    if (alert.appName != null) _DetailRow(label: 'App', value: alert.appName!),
                    if (alert.appPackage != null)
                      _DetailRow(label: 'Pacote', value: alert.appPackage!, small: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!alert.seen)
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Marcar como visto'),
                onPressed: () async {
                  await context.read<AlertsProvider>().markSeen(alert.id);
                  if (context.mounted) Navigator.pop(context);
                },
              ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Por segurança e privacidade, nenhuma imagem é armazenada.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _DetailRow({required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: small ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
