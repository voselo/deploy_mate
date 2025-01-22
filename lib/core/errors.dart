class BuildError implements Exception {
  final String message;
  BuildError(this.message);

  @override
  String toString() => 'BuildError: $message';
}

class ConfigError extends BuildError {
  ConfigError(String message) : super(message);
}
