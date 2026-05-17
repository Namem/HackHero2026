class InstalledApp {
  final int id;
  final String packageName;
  final String appName;
  final String? iconBase64;
  final bool isMonitored;

  const InstalledApp({
    required this.id,
    required this.packageName,
    required this.appName,
    this.iconBase64,
    this.isMonitored = false,
  });

  factory InstalledApp.fromJson(Map<String, dynamic> json) => InstalledApp(
        id: json['id'],
        packageName: json['package_name'],
        appName: json['app_name'],
        iconBase64: json['icon_base64'],
        isMonitored: json['is_monitored'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'package_name': packageName,
        'app_name': appName,
        'icon_base64': iconBase64,
        'is_monitored': isMonitored,
      };

  InstalledApp copyWith({bool? isMonitored}) => InstalledApp(
        id: id,
        packageName: packageName,
        appName: appName,
        iconBase64: iconBase64,
        isMonitored: isMonitored ?? this.isMonitored,
      );
}
