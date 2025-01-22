import 'dart:io';

import 'package:deploy_mate/core/logger.dart';

class CodeAnalyzer {
  static Future<void> run() async {
    Logger.processing('Running dependency check: `flutter pub get`...');
    final pubGetProcess = await Process.start('flutter', ['pub', 'get']);

    pubGetProcess.stdout.transform(SystemEncoding().decoder).listen((data) => Logger.info(data.trim()));
    pubGetProcess.stderr.transform(SystemEncoding().decoder).listen((data) => Logger.error(data.trim()));

    final pubGetExitCode = await pubGetProcess.exitCode;
    if (pubGetExitCode != 0) {
      Logger.error('Dependency check failed with exit code: $pubGetExitCode');
      exit(pubGetExitCode);
    }

    Logger.processing('Running static analysis: `flutter analyze --no-pub`...');
    final analyzeProcess = await Process.start('flutter', ['analyze', '--no-pub']);

    analyzeProcess.stdout.transform(SystemEncoding().decoder).listen((data) => Logger.info(data.trim()));
    analyzeProcess.stderr.transform(SystemEncoding().decoder).listen((data) => Logger.error(data.trim()));

    final analyzeExitCode = await analyzeProcess.exitCode;
    if (analyzeExitCode != 0) {
      Logger.error('Static analysis failed with exit code: $analyzeExitCode');
      exit(analyzeExitCode);
    }

    Logger.success('Static analysis passed successfully.');
  }
}
