import 'dart:io';

import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/core/logger.dart';

class IPABuilder implements IBuilder {
  IPABuilder();

  @override
  Future<void> build(String flavor, {String? outputDir}) async {
      Logger.processing('Preparing $flavor ios build...');


    final result = await Process.run(
      'flutter',
      ['build', 'ipa', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor'],
    );

    if (result.exitCode != 0) {
      Logger.error('Ios build failed: ${result.stderr}');
      throw Exception('Build failed');
    }

    Logger.success('Ios build completed');
  }
}
