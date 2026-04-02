class AppConfig {
  const AppConfig._();

  static const String baseUrl = 'https://plant-disease-api-ei9p.onrender.com';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
