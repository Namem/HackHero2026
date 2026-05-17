import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/link_provider.dart';
import '../../services/app_scan_service.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LinkProvider>().checkStatus();
      _syncApps();
    });
  }

  Future<void> _syncApps() async {
    try {
      final appsData = await AppScanService.scanRealApps();
      await AppScanService.syncApps(appsData);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final link = context.watch<LinkProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vigília'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (mounted) Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status principal
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.shield, size: 72, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Vigília está ativo',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seus pais estão cuidando de você online',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: link.linked ? AppTheme.primary : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        link.linked ? 'Conectado' : 'Aguardando vinculação',
                        style: TextStyle(
                          color: link.linked ? AppTheme.primary : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (link.partnerName != null) ...[
                    const SizedBox(height: 8),
                    Text('Responsável: ${link.partnerName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botões
            OutlinedButton.icon(
              icon: const Icon(Icons.apps),
              label: const Text('Ver apps monitorados'),
              onPressed: () => Navigator.pushNamed(context, Routes.childAppsList),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary),
                foregroundColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Modo Demo — ícone de laboratório
            TextButton.icon(
              icon: const Icon(Icons.science_outlined),
              label: const Text('Modo Demo (simulação)'),
              onPressed: () => Navigator.pushNamed(context, Routes.childSimulate),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            ),

            if (!link.linked) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.childEnterCode),
                child: const Text('Inserir código de vinculação'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
