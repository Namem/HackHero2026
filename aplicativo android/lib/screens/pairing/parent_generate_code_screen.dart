import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/link_provider.dart';

class ParentGenerateCodeScreen extends StatefulWidget {
  const ParentGenerateCodeScreen({super.key});

  @override
  State<ParentGenerateCodeScreen> createState() => _ParentGenerateCodeScreenState();
}

class _ParentGenerateCodeScreenState extends State<ParentGenerateCodeScreen> {
  Timer? _timer;
  Timer? _statusPoll;
  int _secondsLeft = 600; // 10 minutos
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusPoll?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    final link = context.read<LinkProvider>();
    await link.generateCode();
    _startTimer();
    _startStatusPolling();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 600);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _startStatusPolling() {
    _statusPoll?.cancel();
    _statusPoll = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (!mounted || _navigated) {
        t.cancel();
        return;
      }
      final link = context.read<LinkProvider>();
      await link.checkStatus();
      if (link.linked && !_navigated && mounted) {
        _navigated = true;
        t.cancel();
        _timer?.cancel();
        await _showPairedDialog(link.partnerName);
      }
    });
  }

  Future<void> _showPairedDialog(String? partnerName) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.check_circle, color: AppTheme.primary, size: 56),
        title: const Text('Vinculado com sucesso!'),
        content: Text(
          partnerName != null
              ? 'O celular de $partnerName foi vinculado ao seu app.'
              : 'O celular do seu filho foi vinculado.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, Routes.parentHome);
            },
            child: const Text('Ir para o painel'),
          ),
        ],
      ),
    );
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final link = context.watch<LinkProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular filho')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.link, size: 64, color: AppTheme.primary),
            const SizedBox(height: 24),
            const Text(
              'Digite este código no celular do seu filho',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (link.loading)
              const Center(child: CircularProgressIndicator())
            else if (link.pairingCode != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: Text(
                  link.pairingCode!,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            if (link.pairingCode != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: 16, color: _secondsLeft < 60 ? AppTheme.danger : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Expira em $_timerText',
                    style: TextStyle(color: _secondsLeft < 60 ? AppTheme.danger : Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  TextButton(onPressed: _generate, child: const Text('Gerar novo')),
                ],
              ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.parentHome),
              child: const Text('Código enviado, continuar'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.parentHome),
              child: const Text('Vincular depois'),
            ),
          ],
        ),
      ),
    );
  }
}
