class AnalysisResult {
  final int riskLevel;
  final List<String> categories;
  final String description;
  final double confidence;
  final int? alertId;

  const AnalysisResult({
    required this.riskLevel,
    required this.categories,
    required this.description,
    required this.confidence,
    this.alertId,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        riskLevel: json['risk_level'],
        categories: List<String>.from(json['categories'] ?? []),
        description: json['description'] ?? '',
        confidence: (json['confidence'] as num).toDouble(),
        alertId: json['alert_id'],
      );

  Map<String, dynamic> toJson() => {
        'risk_level': riskLevel,
        'categories': categories,
        'description': description,
        'confidence': confidence,
        'alert_id': alertId,
      };
}
