import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/link_provider.dart';
import '../../services/app_scan_service.dart';

class ChildEnterCodeScreen extends StatefulWidget {
  const ChildEnterCodeScreen({super.key});

  @override
  State<ChildEnterCodeScreen> createState() => _ChildEnterCodeScreenState();
}

class _ChildEnterCodeScreenState extends State<ChildEnterCodeScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pair() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O código tem 6 dígitos')),
      );
      return;
    }
    final link = context.read<LinkProvider>();
    final ok = await link.pairWithCode(code);
    if (!mounted) return;
    if (ok) {
      // Sync real installed apps to backend so parent can see them
      try {
        final appsData = await AppScanService.scanRealApps();
        await AppScanService.syncApps(appsData);
      } catch (_) {}
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.childHome);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(link.error ?? 'Código inválido ou expirado'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = context.watch<LinkProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular ao responsável')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.family_restroom, size: 64, color: Colors.blue[400]),
            const SizedBox(height: 24),
            const Text(
              'Digite o código do seu responsável',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Peça para o seu pai ou mãe mostrar o código no app deles.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(color: Colors.grey[300], letterSpacing: 8),
                counterText: '',
              ),
            ),
            const SizedBox(height: 32),
            link.loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _pair, child: const Text('Vincular')),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.childHome),
              child: const Text('Vincular depois'),
            ),
          ],
        ),
      ),
    );
  }
}
