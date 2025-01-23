abstract class Logger {
  static void info(String message) => print('ℹ️ $message');
  static void warning(String message) => print('⚠️  $message');

  static void processing(String message) => print('⏳ $message');
  static void success(String message) => print('✅  $message');
  static void error(String message) => print('🚨  $message');

  static void deploy(String message) => print('🚀 $message');
  static void outputPath(String path) => print('\x1B[32mOutput\x1B[0m /$path');
}
