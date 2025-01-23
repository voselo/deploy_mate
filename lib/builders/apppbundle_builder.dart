import 'dart:io';

import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/utils/names/get_android_output_name.dart';
import 'package:deploy_mate/utils/process_helper.dart';

class AppBundleBuilder implements IBuilder {
  AppBundleBuilder();

  @override
  Future<void> build(String flavor, {String? targetDir}) async {
    final exitCode = await ProcessHelper.run(
      'flutter',
      ['build', 'appbundle', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--release'],
    );

    if (exitCode != 0) {
      Logger.error('Apk build failed with exit code $exitCode');
    }

    final appPath = 'build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab';
    final appOutputName = getAndroidOutputName(flavor);
    final moveTo = '$targetDir/$appOutputName.aab';

    final apkFile = File(appPath);
    if (!apkFile.existsSync()) {
      // await Telegram.buildFailed(flavor, type, 404);
      // Printer.buildFileNotFound('AppBundle', appPath);
      return;
    }

    await apkFile.rename(moveTo);

    Logger.outputPath(moveTo);
  }
}
