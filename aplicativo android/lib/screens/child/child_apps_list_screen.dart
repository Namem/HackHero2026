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
      appBar: AppBar(title: const Text('Apps monitorados')),
      body: monitored.isEmpty && !apps.loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  const Text('Nenhum app sendo monitorado no momento',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : apps.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: monitored.length,
                  itemBuilder: (_, i) {
                    final app = monitored[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: app.iconBase64 != null && app.iconBase64!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(base64Decode(app.iconBase64!)),
                                backgroundColor: Colors.transparent,
                              )
                            : CircleAvatar(
                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                                child: Text(app.appName[0],
                                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                              ),
                        title: Text(app.appName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Monitorado pelo seu responsável',
                            style: TextStyle(fontSize: 12)),
                        trailing: Icon(Icons.shield, size: 18, color: AppTheme.primary),
                      ),
                    );
                  },
                ),
    );
  }
}
