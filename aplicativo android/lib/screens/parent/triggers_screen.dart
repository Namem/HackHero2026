import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/trigger.dart';
import '../../providers/triggers_provider.dart';

class TriggersScreen extends StatefulWidget {
  final bool embedded;
  const TriggersScreen({super.key, this.embedded = false});

  @override
  State<TriggersScreen> createState() => _TriggersScreenState();
}

class _TriggersScreenState extends State<TriggersScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TriggersProvider>().load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TriggersProvider>();

    Widget body;
    if (prov.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (prov.triggers.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum gatilho cadastrado', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Adicionar gatilho'),
              onPressed: () => Navigator.pushNamed(context, Routes.triggerEdit),
            ),
          ],
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: prov.triggers.length,
        itemBuilder: (_, i) => _TriggerCard(trigger: prov.triggers[i]),
      );
    }

    if (widget.embedded) {
      return Stack(
        children: [
          body,
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, Routes.triggerEdit),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gatilhos')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.triggerEdit),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TriggerCard extends StatelessWidget {
  final Trigger trigger;
  const _TriggerCard({required this.trigger});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Violência': return Colors.red;
      case 'Conteúdo Adulto': return Colors.purple;
      case 'Jogos de Azar': return Colors.orange;
      case 'Cyberbullying': return Colors.pink;
      case 'Drogas': return Colors.brown;
      case 'Armas': return Colors.red[900]!;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(trigger.category);
    return Dismissible(
      key: Key('trigger_${trigger.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppTheme.danger,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TriggersProvider>().remove(trigger.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, Routes.triggerEdit, arguments: trigger),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(trigger.category),
                      backgroundColor: color.withOpacity(0.12),
                      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      padding: EdgeInsets.zero,
                    ),
                    const Spacer(),
                    Icon(Icons.circle, size: 10, color: trigger.active ? AppTheme.primary : Colors.grey),
                    const SizedBox(width: 4),
                    Text(trigger.active ? 'Ativo' : 'Inativo',
                        style: TextStyle(fontSize: 12, color: trigger.active ? AppTheme.primary : Colors.grey)),
                  ],
                ),
                if (trigger.keywords.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: trigger.keywords
                        .map((k) => Chip(
                              label: Text(k, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 6),
                Row(children: [
                  const Text('Severidade: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${trigger.severity}/10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
