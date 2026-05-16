class MonitoredApp {
  final int id;
  final String packageName;
  final String appName;
  final bool isActive;

  const MonitoredApp({
    required this.id,
    required this.packageName,
    required this.appName,
    this.isActive = true,
  });

  factory MonitoredApp.fromJson(Map<String, dynamic> json) => MonitoredApp(
        id: json['id'] ?? 0,
        packageName: json['package_name'] ?? '',
        appName: json['app_name'] ?? '',
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'package_name': packageName,
        'app_name': appName,
        'is_active': isActive,
      };
}
