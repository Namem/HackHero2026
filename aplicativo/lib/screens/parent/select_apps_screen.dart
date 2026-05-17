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
        backgroundColor: ok ? AppTheme.safe : AppTheme.danger,
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
      body = const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    } else if (apps.apps.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                child: const Icon(Icons.phone_android, size: 32, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aguardando sincronização',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'A lista será carregada quando o app do seu filho sincronizar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    } else {
      body = Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Buscar app...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          // App list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final app = filtered[i];
                final idx = apps.apps.indexOf(app);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: app.isMonitored
                        ? Border.all(color: AppTheme.primary.withOpacity(0.3))
                        : Border.all(color: Colors.grey.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => apps.toggleApp(idx),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            // App icon
                            app.iconBase64 != null && app.iconBase64!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(app.iconBase64!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
                                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                    ),
                                  ),
                            const SizedBox(width: 12),
                            // App info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.appName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    app.packageName,
                                    style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary, fontFamily: 'monospace'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Toggle
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: app.isMonitored ? AppTheme.primary : Colors.transparent,
                                border: Border.all(
                                  color: app.isMonitored ? AppTheme.primary : Colors.grey.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: app.isMonitored
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Salvar seleção'),
                onPressed: _save,
              ),
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
