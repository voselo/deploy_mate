import 'dart:io';

import 'package:deploy_mate/core/logger.dart';

class CodeAnalyzer {
  static Future<void> run() async {
    Logger.processing('Running dependency check: `flutter pub get`...');
    final pubGetResult = await Process.run('flutter', ['pub', 'get']);
    if (pubGetResult.exitCode != 0) {
      Logger.error('Dependency check failed: ${pubGetResult.stderr}');
      exit(pubGetResult.exitCode);
    }

    Logger.processing('Running static analysis: `flutter analyze --no-pub`...');
    final analyzeResult = await Process.run('flutter', ['analyze', '--no-pub']);
    if (analyzeResult.exitCode != 0) {
      Logger.error('Static analysis failed:\n${analyzeResult.stdout}');
      exit(analyzeResult.exitCode);
    }

    Logger.success('Static analysis passed successfully.');
  }
}
