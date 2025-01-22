import 'dart:io';

import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/core/logger.dart';

class APKBuilder implements IBuilder {
  APKBuilder();

  @override
  Future<void> build(String flavor, {String? outputDir}) async {
    Logger.processing('Preparing $flavor apk build...');

    final result = await Process.run(
      'flutter',
      ['build', 'apk', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--output-dir=$outputDir'],
    );

    if (result.exitCode != 0) {
      Logger.error('APK build failed: ${result.stderr}');
      throw Exception('APK build failed');
    }

    Logger.success('APK build completed. Output: $outputDir');
  }
}
