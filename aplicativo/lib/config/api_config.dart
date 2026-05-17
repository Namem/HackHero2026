class ApiConfig {
  // Android emulator → host machine localhost
  // Troque para o IP real se testar em device físico
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const Duration timeout = Duration(seconds: 30);
}
