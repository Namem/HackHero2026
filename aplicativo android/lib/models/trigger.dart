class Trigger {
  final int id;
  final String category;
  final List<String> keywords;
  final int severity; // 1-10
  final bool active;

  const Trigger({
    required this.id,
    required this.category,
    required this.keywords,
    required this.severity,
    this.active = true,
  });

  factory Trigger.fromJson(Map<String, dynamic> json) => Trigger(
        id: json['id'],
        category: json['category'],
        keywords: List<String>.from(json['keywords'] ?? []),
        severity: json['severity'],
        active: json['active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'keywords': keywords,
        'severity': severity,
        'active': active,
      };
}

const List<String> triggerCategories = [
  'Violência',
  'Conteúdo Adulto',
  'Jogos de Azar',
  'Cyberbullying',
  'Drogas',
  'Armas',
  'Custom',
];
