import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/apps_provider.dart';
import '../../providers/link_provider.dart';

class SelectAppsScreen extends StatefulWidget {
  final bool embedded;
  const SelectAppsScreen({super.key, this.embedded = false});

  @override
  State<SelectAppsScreen> createState() => _SelectAppsScreenState();
}

class _SelectAppsScreenState extends State<SelectAppsScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    final link = context.read<LinkProvider>();
    await link.restoreLinkedChild();
    await context.read<AppsProvider>().loadApps(link.linkedChildId ?? 0);
  }

  Future<void> _save() async {
    final link = context.read<LinkProvider>();
    final apps = context.read<AppsProvider>();
    if (link.linkedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vincule um filho antes de selecionar apps')),
      );
      return;
    }
    final ok = await apps.saveSelection(link.linkedChildId!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Seleção salva!' : 'Erro ao salvar'),
        backgroundColor: ok ? AppTheme.primary : AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = context.watch<AppsProvider>();
    final filtered = apps.apps
        .where((a) => a.appName.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    Widget body;
    if (apps.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (apps.apps.isEmpty) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'A lista será carregada quando o app do seu filho sincronizar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Buscar app...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final app = filtered[i];
                final idx = apps.apps.indexOf(app);
                return CheckboxListTile(
                  value: app.isMonitored,
                  onChanged: (_) => apps.toggleApp(idx),
                  title: Text(app.appName),
                  subtitle: Text(app.packageName, style: const TextStyle(fontSize: 11)),
                  secondary: app.iconBase64 != null && app.iconBase64!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(base64Decode(app.iconBase64!)),
                          backgroundColor: Colors.transparent,
                        )
                      : CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(app.appName[0], style: TextStyle(color: AppTheme.primary)),
                        ),
                  activeColor: AppTheme.primary,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salvar seleção'),
              onPressed: _save,
            ),
          ),
        ],
      );
    }

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Apps monitorados')),
      body: body,
    );
  }
}
