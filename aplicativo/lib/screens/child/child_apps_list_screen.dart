import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../providers/apps_provider.dart';

class ChildAppsListScreen extends StatefulWidget {
  const ChildAppsListScreen({super.key});

  @override
  State<ChildAppsListScreen> createState() => _ChildAppsListScreenState();
}

class _ChildAppsListScreenState extends State<ChildAppsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getInt('user_id') ?? 0;
    if (childId > 0 && mounted) {
      await context.read<AppsProvider>().loadApps(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = context.watch<AppsProvider>();
    final monitored = apps.apps.where((a) => a.isMonitored).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Apps monitorados'),
      ),
      body: monitored.isEmpty && !apps.loading
          ? Center(
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
                  const Text('Nenhum app monitorado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    'Seu responsável ainda não selecionou apps',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            )
          : apps.loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: monitored.length,
                  itemBuilder: (_, i) {
                    final app = monitored[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.appName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  const Text('Monitorado pelo seu responsável', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.shield, size: 14, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
