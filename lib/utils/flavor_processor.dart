import 'dart:io';

import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/core/project_config.dart';
import 'package:deploy_mate/interact/select_config.dart';
import 'package:deploy_mate/utils/increment_build_number.dart';

class FlavorProcessor {
  static List<String> getAvailableFlavors() {
    // Define the path for flavors (only from IOS Flutter directory)
    final currentDirectory = Directory.current;
    final IOSFlavorPath = '${currentDirectory.path}/IOS/Flutter';

    // Extract flavors from the IOS path
    return _getFlavorsFromPath(IOSFlavorPath, RegExp(r'Release-(.+)\.xcconfig'));
  }

  static List<String> _getFlavorsFromPath(String path, RegExp flavorRegExp) {
    final directory = Directory(path);

    if (!directory.existsSync()) {
      Logger.error('Error: Directory not found: $path');
      return [];
    }

    final List<String> flavors = [];
    final files = directory.listSync();

    for (final file in files) {
      if (file is File) {
        final match = flavorRegExp.firstMatch(file.uri.pathSegments.last);
        if (match != null && match.group(1) != null) {
          flavors.add(match.group(1)!);
        }
      }
    }

    return flavors;
  }

  String logFile(String flavor) => 'build_$flavor.log';
  final targetDirectory = 'build/apps_builds';

  IOSink? logFileStream;

  Future<void> processFlavor({
    required String flavor,
    required BuildOptions options,
  }) async {
    logFileStream = File(logFile(flavor)).openWrite();
    final buildConfig = await ProjectConfig().init();
    if (options.deployApk || options.deployAppBundle) {
      // await getDiskInfo();
    }

    if (options.incrementBuildNumber) {
      await incrementBuildNumber();
    }
    // Build IPA
    if (options.buildIpa) {
      logFileStream?.write('Building IPA for flavor $flavor...\n');
      // await buildIpa(flavor);
    }

    // Deploy IPA
    if (options.deployIpa) {
      logFileStream?.write('Deploying IPA for flavor $flavor...\n');
      // await deployIpa(flavor);
    }

    // Build APK
    if (options.buildApk) {
      logFileStream?.write('Building APK for flavor $flavor...\n');
      // await buildApk(flavor, targetDirectory);
    }

    // Deploy APK
    if (options.deployApk) {
      await _requiredAuth(buildConfig.yandexToken, () async {
        logFileStream?.write('Deploying APK for flavor $flavor...\n');
        // await deployApk(flavor, targetDirectory);
      });
    }

    // Build App Bundle
    if (options.buildAppBundle) {
      logFileStream?.write('Building App Bundle for flavor $flavor...\n');
      // await buildAppBundle(flavor, targetDirectory);
    }

    // Deploy App Bundle
    if (options.deployAppBundle) {
      await _requiredAuth(buildConfig.yandexToken, () async {
        logFileStream?.write('Deploying App Bundle for flavor $flavor...\n');
        // await deployAppBundle(flavor, targetDirectory);
      });
    }

    logFileStream?.write('Completed processing flavor: $flavor\n');
    await logFileStream?.close();
  }

  /// Authorization helper
  Future<void> _requiredAuth(String? token, Function() callback) async {
    if (token == null || token.isEmpty) {
      Logger.error('Authentication required for deployment.');
      throw Exception('Yandex token is missing.');
    } else {
      await callback();
    }
  }
}
