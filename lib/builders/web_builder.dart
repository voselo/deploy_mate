import 'dart:io';

import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/core/logger.dart';

class WebBuilder implements IBuilder {
  WebBuilder();

  @override
  Future<void> build(String flavor, {String? outputDir}) async {
    Logger.processing('Preparing $flavor web build...');

    final result = await Process.run(
      'flutter',
      ['build', 'web', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--output-dir=$outputDir'],
    );

    if (result.exitCode != 0) {
      Logger.error('Web build failed: ${result.stderr}');
      throw Exception('Web build failed');
    }

    Logger.success('Web build completed. Output: $outputDir');
  }
}
