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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.safe.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppTheme.safe, size: 36),
        ),
        title: const Text('Vinculado com sucesso!', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          partnerName != null
              ? 'O celular de $partnerName foi vinculado ao seu app.'
              : 'O celular do seu filho foi vinculado.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, Routes.parentHome);
              },
              child: const Text('Ir para o painel'),
            ),
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
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Vincular filho'),
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
                  color: AppTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.link, size: 32, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Digite este código no\ncelular do seu filho',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (link.loading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            else if (link.pairingCode != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                ),
                child: Text(
                  link.pairingCode!,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 14),
            if (link.pairingCode != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: 14, color: _secondsLeft < 60 ? AppTheme.danger : Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Expira em $_timerText',
                    style: TextStyle(fontSize: 12, color: _secondsLeft < 60 ? AppTheme.danger : Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _generate,
                    child: const Text('Gerar novo', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.parentHome),
              child: const Text('Código enviado, continuar'),
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, Routes.parentHome),
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
