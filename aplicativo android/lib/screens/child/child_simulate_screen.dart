import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../models/analysis_result.dart';
import '../../services/analysis_service.dart';

class ChildSimulateScreen extends StatefulWidget {
  const ChildSimulateScreen({super.key});

  @override
  State<ChildSimulateScreen> createState() => _ChildSimulateScreenState();
}

class _ChildSimulateScreenState extends State<ChildSimulateScreen> {
  File? _image;
  bool _loading = false;
  AnalysisResult? _result;

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _result = null;
    });
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final childId = prefs.getInt('user_id') ?? 1;
      final result = await AnalysisService.analyzeImage(_image!, childId, 'com.simulated');
      setState(() => _result = result);
    } catch (e) {
      // Se o backend não está disponível, usa mock para a demo
      setState(() => _result = AnalysisResult(
            riskLevel: 7,
            categories: ['Jogos de Azar', 'apostas'],
            description:
                'Conteúdo simulado para demo: interface de site de apostas detectada com botões de pagamento visíveis.',
            confidence: 0.91,
            alertId: 42,
          ));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Demo'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('DEMO', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.science, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta tela existe apenas para demonstração na hackathon.',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Selecionar imagem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                    onPressed: () => _pick(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                    onPressed: () => _pick(ImageSource.camera),
                  ),
                ),
              ],
            ),

            if (_image != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              _loading
                  ? Column(children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text('Analisando conteúdo...', style: TextStyle(color: Colors.grey[600])),
                    ])
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Simular captura de tela'),
                      onPressed: _analyze,
                    ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Resultado da IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _ResultCard(result: _result!),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '👉 Para ver o alerta no app dos pais:\nAbra o app Vigília no celular do responsável e verifique a aba Alertas.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final AnalysisResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(result.riskLevel);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppTheme.riskIcon(result.riskLevel), color: color, size: 28),
                const SizedBox(width: 8),
                Text(AppTheme.riskLabel(result.riskLevel),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                const Spacer(),
                Text('${result.riskLevel}/10', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: result.riskLevel / 10,
                minHeight: 6,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: result.categories
                  .map((c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 11)),
                        backgroundColor: color.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(result.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 8),
            Text(
              'Confiança: ${(result.confidence * 100).round()}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
