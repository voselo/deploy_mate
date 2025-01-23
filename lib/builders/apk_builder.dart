import 'dart:io';

import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/utils/names/get_android_output_name.dart';
import 'package:deploy_mate/utils/process_helper.dart';

class ApkBuilder implements IBuilder {
  ApkBuilder();

  final String defaultTargetDir = 'build/app/outputs/apk';

  @override
  Future<void> build(String flavor, {String? targetDir}) async {
    final exitCode = await ProcessHelper.run(
      'flutter',
      ['build', 'apk', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--release'],
    );

    if (exitCode != 0) {
      Logger.error('Apk build failed with exit code $exitCode');
    }

    final apkPath = 'build/app/outputs/apk/$flavor/release/app-$flavor-release.apk';
    final appOutputName = getAndroidOutputName(flavor);
    final moveTo = '$targetDir/$appOutputName.apk';

    final apkFile = File(apkPath);
    if (!apkFile.existsSync()) {
      // await Telegram.buildFailed(flavor, type, 404);
      // Printer.buildFileNotFound('Apk', apkPath);
      return;
    }

    await apkFile.rename(moveTo);

    Logger.outputPath(moveTo);
  }
}
