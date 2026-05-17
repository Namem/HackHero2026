import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/link_provider.dart';
import '../../services/analysis_service.dart';

class ChildSimulateScreen extends StatefulWidget {
  const ChildSimulateScreen({super.key});

  @override
  State<ChildSimulateScreen> createState() => _ChildSimulateScreenState();
}

class _ChildSimulateScreenState extends State<ChildSimulateScreen> {
  bool _loadingHigh = false;
  bool _loadingMedium = false;
  bool _loadingLow = false;
  String? _lastResult;
  String? _deviceToken;
  int _highCount = 0;
  int _mediumCount = 0;
  int _lowCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _deviceToken = prefs.getString('device_token');
      _highCount = prefs.getInt('sim_count_high') ?? 0;
      _mediumCount = prefs.getInt('sim_count_medium') ?? 0;
      _lowCount = prefs.getInt('sim_count_low') ?? 0;
    });
  }

  Future<void> _simulate(String riskLevel, String label) async {
    setState(() {
      _lastResult = null;
      if (riskLevel == 'high_risk') _loadingHigh = true;
      if (riskLevel == 'attention') _loadingMedium = true;
      if (riskLevel == 'safe') _loadingLow = true;
    });

    try {
      final result = await AnalysisService.simulateAlert(riskLevel);
      final prefs = await SharedPreferences.getInstance();
      if (riskLevel == 'high_risk') {
        _highCount += 1;
        await prefs.setInt('sim_count_high', _highCount);
      } else if (riskLevel == 'attention') {
        _mediumCount += 1;
        await prefs.setInt('sim_count_medium', _mediumCount);
      } else {
        _lowCount += 1;
        await prefs.setInt('sim_count_low', _lowCount);
      }
      if (mounted) {
        setState(() {
          _lastResult = '✓ $label enviado!\nCategoria: ${result['category']}\nApp: ${result['app_package']}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label simulado — verifique no celular do pai'),
            backgroundColor: AppTheme.safe,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _lastResult = '✗ Erro: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingHigh = false;
          _loadingMedium = false;
          _loadingLow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final link = context.watch<LinkProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Modo Beta'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('BETA', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Perfil mockado da criança
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A6E), AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.primaryDark.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _initials(user?.name ?? 'Beta'),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Conta de teste', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(user?.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11.5)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: link.linked ? AppTheme.accent.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 5, height: 5, decoration: BoxDecoration(color: link.linked ? AppTheme.accent : Colors.orange, shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  Text(
                                    link.linked ? (link.partnerName != null ? 'Vinculado a ${link.partnerName}' : 'Vinculado') : 'Sem vínculo',
                                    style: TextStyle(color: link.linked ? AppTheme.accent : Colors.orange, fontWeight: FontWeight.w700, fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _MiniStat(label: 'Alto', count: _highCount, color: AppTheme.danger)),
                      Expanded(child: _MiniStat(label: 'Médio', count: _mediumCount, color: AppTheme.warning)),
                      Expanded(child: _MiniStat(label: 'Baixo', count: _lowCount, color: AppTheme.safe)),
                    ],
                  ),
                  if (_deviceToken != null) ...[
                    const SizedBox(height: 10),
                    Text('Token: ${_deviceToken!.substring(0, 8)}…', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontFamily: 'monospace')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Aviso modo beta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science, color: AppTheme.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo de testes: aperte os botões abaixo para simular alertas no celular do responsável.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800], height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Simular alerta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
            const SizedBox(height: 12),

            _SimButton(
              icon: Icons.error_outline,
              color: AppTheme.danger,
              level: 'Risco Alto',
              description: 'Aliciamento, conteúdo adulto, extremismo',
              loading: _loadingHigh,
              onTap: () => _simulate('high_risk', 'Risco Alto'),
            ),
            const SizedBox(height: 10),
            _SimButton(
              icon: Icons.warning_amber_outlined,
              color: AppTheme.warning,
              level: 'Risco Médio',
              description: 'Violência, gambling, bullying',
              loading: _loadingMedium,
              onTap: () => _simulate('attention', 'Risco Médio'),
            ),
            const SizedBox(height: 10),
            _SimButton(
              icon: Icons.check_circle_outline,
              color: AppTheme.safe,
              level: 'Risco Baixo',
              description: 'Microtransação, FOMO',
              loading: _loadingLow,
              onTap: () => _simulate('safe', 'Risco Baixo'),
            ),

            if (_lastResult != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lastResult!.startsWith('✓')
                      ? AppTheme.safe.withValues(alpha: 0.08)
                      : AppTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _lastResult!.startsWith('✓')
                        ? AppTheme.safe.withValues(alpha: 0.3)
                        : AppTheme.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _lastResult!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _lastResult!.startsWith('✓') ? Colors.green[900] : Colors.red[900],
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.accent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verifique no celular do responsável a aba "Alertas" ou puxe a Home para atualizar.',
                      style: TextStyle(fontSize: 11.5, color: Colors.green[800], height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SimButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String level;
  final String description;
  final bool loading;
  final VoidCallback onTap;

  const _SimButton({
    required this.icon,
    required this.color,
    required this.level,
    required this.description,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
                    const SizedBox(height: 3),
                    Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3)),
                  ],
                ),
              ),
              loading
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: color, strokeWidth: 2.5))
                  : Icon(Icons.play_arrow_rounded, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
