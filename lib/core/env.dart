class AppEnv {
  static const mode = String.fromEnvironment('APP_ENV', defaultValue: 'mock');
  static bool get isMock => mode == 'mock';
}
