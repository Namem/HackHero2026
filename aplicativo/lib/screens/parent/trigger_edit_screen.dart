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
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Text(_editing == null ? 'Novo gatilho' : 'Editar gatilho'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categoria', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: triggerCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      filled: true,
                      fillColor: AppTheme.surface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Keywords
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Palavras-chave', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _kwCtrl,
                          decoration: InputDecoration(
                            hintText: 'Digite e pressione Enter...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            filled: true,
                            fillColor: AppTheme.surface,
                          ),
                          onSubmitted: (_) => _addKeyword(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _addKeyword,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  if (_keywords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _keywords
                          .map((k) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => setState(() => _keywords.remove(k)),
                                      child: Icon(Icons.close, size: 14, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Severity
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Severidade', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.riskBg(_severity.round()),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_severity.round()}/10',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.riskFg(_severity.round())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.riskColor(_severity.round()),
                      thumbColor: AppTheme.riskColor(_severity.round()),
                      inactiveTrackColor: AppTheme.riskColor(_severity.round()).withOpacity(0.15),
                    ),
                    child: Slider(
                      value: _severity,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (v) => setState(() => _severity = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Active toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: SwitchListTile(
                title: const Text('Gatilho ativo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                activeColor: AppTheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _saving
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
