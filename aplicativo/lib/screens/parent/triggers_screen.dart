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
      body = const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    } else if (prov.triggers.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune, size: 32, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text('Nenhum gatilho cadastrado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text('Adicione palavras-chave para monitorar', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar gatilho'),
              onPressed: () => Navigator.pushNamed(context, Routes.triggerEdit),
            ),
          ],
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(14),
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
              foregroundColor: Colors.white,
              elevation: 4,
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
        foregroundColor: Colors.white,
        elevation: 4,
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
      case 'Violência': return const Color(0xFFDC2626);
      case 'Conteúdo Adulto': return const Color(0xFF9333EA);
      case 'Jogos de Azar': return const Color(0xFFEA580C);
      case 'Cyberbullying': return AppTheme.primary;
      case 'Drogas': return const Color(0xFF92400E);
      case 'Armas': return const Color(0xFF991B1B);
      default: return const Color(0xFF475569);
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
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TriggersProvider>().remove(trigger.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, Routes.triggerEdit, arguments: trigger),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(trigger.category, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: trigger.active ? AppTheme.safe : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trigger.active ? 'Ativo' : 'Inativo',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: trigger.active ? AppTheme.safe : Colors.grey),
                      ),
                    ],
                  ),
                  if (trigger.keywords.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: trigger.keywords
                          .map((k) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(k, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('Severidade: ', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    Text('${trigger.severity}/10', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
