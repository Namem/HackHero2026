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
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Vincular ao responsável'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.family_restroom, size: 32, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Digite o código do\nseu responsável',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Peça para o seu pai ou mãe mostrar o código no app deles.',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            // Code input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 10, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 10),
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            link.loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : ElevatedButton(onPressed: _pair, child: const Text('Vincular')),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, Routes.childHome),
                child: Text(
                  'Vincular depois',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
