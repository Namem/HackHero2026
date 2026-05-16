import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/trigger.dart';
import '../../providers/triggers_provider.dart';

class TriggerEditScreen extends StatefulWidget {
  const TriggerEditScreen({super.key});

  @override
  State<TriggerEditScreen> createState() => _TriggerEditScreenState();
}

class _TriggerEditScreenState extends State<TriggerEditScreen> {
  String _category = triggerCategories.first;
  final List<String> _keywords = [];
  final _kwCtrl = TextEditingController();
  double _severity = 7;
  bool _active = true;
  bool _saving = false;
  Trigger? _editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Trigger && _editing == null) {
      _editing = arg;
      _category = arg.category;
      _keywords.addAll(arg.keywords);
      _severity = arg.severity.toDouble();
      _active = arg.active;
    }
  }

  @override
  void dispose() {
    _kwCtrl.dispose();
    super.dispose();
  }

  void _addKeyword() {
    final kw = _kwCtrl.text.trim();
    if (kw.isNotEmpty && !_keywords.contains(kw)) {
      setState(() => _keywords.add(kw));
      _kwCtrl.clear();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prov = context.read<TriggersProvider>();
    bool ok;
    if (_editing != null) {
      ok = await prov.update(_editing!.id, _category, _keywords, _severity.round(), _active);
    } else {
      ok = await prov.create(_category, _keywords, _severity.round());
    }
    if (mounted) {
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prov.error ?? 'Erro ao salvar'), backgroundColor: AppTheme.danger),
        );
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing == null ? 'Novo gatilho' : 'Editar gatilho')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: triggerCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            const Text('Palavras-chave', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kwCtrl,
                    decoration: const InputDecoration(hintText: 'Digite e pressione Enter...', isDense: true),
                    onSubmitted: (_) => _addKeyword(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: AppTheme.primary,
                  onPressed: _addKeyword,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _keywords
                  .map((k) => Chip(
                        label: Text(k),
                        onDeleted: () => setState(() => _keywords.remove(k)),
                        deleteIconColor: Colors.grey,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Severidade', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_severity.round()}/10',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.riskColor(_severity.round()),
                    )),
              ],
            ),
            Slider(
              value: _severity,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppTheme.riskColor(_severity.round()),
              onChanged: (v) => setState(() => _severity = v),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Gatilho ativo'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              activeThumbColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
