class Alert {
  final int id;
  final int riskLevel; // 0-10
  final List<String> categories;
  final String description;
  final String? appName;
  final String? appPackage;
  final DateTime timestamp;
  final bool seen;

  const Alert({
    required this.id,
    required this.riskLevel,
    required this.categories,
    required this.description,
    this.appName,
    this.appPackage,
    required this.timestamp,
    this.seen = false,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'],
        riskLevel: json['risk_level'],
        categories: List<String>.from(json['categories'] ?? []),
        description: json['description'] ?? '',
        appName: json['app_name'],
        appPackage: json['app_package'],
        timestamp: DateTime.parse(json['timestamp']),
        seen: json['seen'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'risk_level': riskLevel,
        'categories': categories,
        'description': description,
        'app_name': appName,
        'app_package': appPackage,
        'timestamp': timestamp.toIso8601String(),
        'seen': seen,
      };

  // Mock data para testar UI sem backend
  static List<Alert> getMockAlerts() {
    return [
      Alert(
        id: 1,
        riskLevel: 8,
        categories: ['violência', 'armas'],
        description: 'Conteúdo com armas de fogo detectado em jogo online',
        appName: 'Free Fire',
        appPackage: 'com.dts.freefireth',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        seen: false,
      ),
      Alert(
        id: 2,
        riskLevel: 3,
        categories: ['seguro'],
        description: 'Conteúdo educacional — aula de matemática',
        appName: 'YouTube',
        appPackage: 'com.google.android.youtube',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        seen: true,
      ),
      Alert(
        id: 3,
        riskLevel: 9,
        categories: ['apostas', 'jogos de azar'],
        description: 'Site de apostas esportivas detectado com interface de pagamento visível',
        appName: 'Chrome',
        appPackage: 'com.android.chrome',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        seen: false,
      ),
    ];
  }
}
