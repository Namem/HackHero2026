import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';
import 'api_service.dart';

class AnalysisService {
  static Future<AnalysisResult> analyzeImage(
    File imageFile,
    int childId,
    String appPackage,
  ) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    final deviceToken = prefs.getString('device_token') ?? '';

    final json = await ApiService.post('/analyze/', {
      'image': base64Image,
      'device_token': deviceToken,
      'app_package': appPackage,
    });

    return AnalysisResult.fromJson(json);
  }

  /// Simula um alerta no backend (modo beta/demo).
  /// `riskLevel` deve ser: "high_risk", "attention" ou "safe".
  static Future<Map<String, dynamic>> simulateAlert(String riskLevel) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceToken = prefs.getString('device_token') ?? '';
    if (deviceToken.isEmpty) {
      throw Exception('Dispositivo não vinculado. Faça o pareamento primeiro.');
    }
    return await ApiService.post('/simulate-alert/', {
      'device_token': deviceToken,
      'risk_level': riskLevel,
    });
  }
}
