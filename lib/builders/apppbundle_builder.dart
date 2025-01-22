import 'dart:io';

import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/core/logger.dart';

class AppBundleBuilder implements IBuilder {
  AppBundleBuilder();

  @override
  Future<void> build(String flavor, {String? outputDir}) async {
    Logger.processing('Preparing $flavor appbundle build...');

    final result = await Process.run(
      'flutter',
      ['build', 'appbundle', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--output-dir=$outputDir'],
    );

    if (result.exitCode != 0) {
      Logger.error('App Bundle build failed: ${result.stderr}');
      throw Exception('App Bundle build failed');
    }

    Logger.success('App Bundle build completed. Output: $outputDir');
  }
}
