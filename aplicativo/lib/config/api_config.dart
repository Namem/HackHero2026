class ApiConfig {
  // Permite trocar a URL no build sem editar este arquivo:
  //   flutter run --dart-define=API_URL=https://numik.com.br/api
  //   flutter build apk --dart-define=API_URL=https://numik.com.br/api
  //
  // Sem --dart-define usa o emulador Android default (10.0.2.2 = host machine).
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration timeout = Duration(seconds: 30);
}

