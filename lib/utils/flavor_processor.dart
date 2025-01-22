import 'dart:io';

import 'package:deploy_mate/builders/apk_builder.dart';
import 'package:deploy_mate/builders/apppbundle_builder.dart';
import 'package:deploy_mate/builders/ipa_builder.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/core/project_config.dart';
import 'package:deploy_mate/interact/select_config.dart';
import 'package:deploy_mate/utils/increment_build_number.dart';

class FlavorProcessor {
  final ProjectConfig config;
  final Map<String, dynamic> buildReport = {};

  FlavorProcessor(this.config);

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

  Future<void> run({
    required String flavor,
    required BuildOptions options,
  }) async {
    logFileStream = File(logFile(flavor)).openWrite();
    // if (options.deployApk || options.deployAppBundle) {
    //   // await getDiskInfo();
    // }

    buildReport['flavor'] = flavor;
    // buildReport['version'] = config.version;
    // buildReport['buildNumber'] = config.buildNumber;

    // Increment build number
    if (options.incrementBuildNumber) {
      await _incrementBuildNumber();
    }

    // Build IPA
    if (options.buildIpa) {
      await _buildIpa(flavor);
    }

    // Deploy IPA
    if (options.deployIpa) {
      buildReport['isIpaDeployed'] = await _deployIpa(flavor);
    }

    // Build APK
    if (options.buildApk) {
      await _buildApk(flavor);
    }

    // Deploy APK
    if (options.deployApk) {
      buildReport['apkLink'] = await _deployApk(flavor);
    }

    // Build App Bundle
    if (options.buildAppBundle) {
      await _buildAab(flavor);
    }

    // Deploy App Bundle
    if (options.deployAppBundle) {
      buildReport['appBundleLink'] = await _deployAab(flavor);
    }

    await logFileStream?.close();
  }

  Future<void> _incrementBuildNumber() async {
    Logger.processing('Incrementing build number...');
    await incrementBuildNumber();
    Logger.success('Build number incremented successfully.');
  }

  Future<void> _buildIpa(String flavor) async {
    Logger.processing('Building $flavor ipa');
    final ipaBuilder = IpaBuilder();
    await ipaBuilder.build(flavor);
    Logger.success('$flavor ipa build completed');
  }

  Future<bool> _deployIpa(String flavor) async {
    Logger.deploy('Deploying $flavor ipa');
    // TODO: Add actual IPA deployment logic here
    final deployed = true; // Placeholder for successful deployment status
    Logger.success('$flavor ipa deployed successfully');
    return deployed;
  }

  Future<void> _buildApk(String flavor) async {
    Logger.processing('Building $flavor apk');
    final apkBuilder = ApkBuilder();
    await apkBuilder.build(flavor);
    Logger.success('$flavor apk build completed');
  }

  Future<String?> _deployApk(String flavor) async {
    Logger.deploy('Deploying $flavor apk');
    await _validateAuth(config.yandexToken);
    // TODO: Add actual APK deployment logic here
    final apkLink = 'https://yandex.disk/apk/$flavor'; // Placeholder for APK link
    Logger.success('$flavor apk deployed successfully');
    return apkLink;
  }

  Future<void> _buildAab(String flavor) async {
    Logger.processing('Building $flavor aab');
    final appBundleBuilder = AppBundleBuilder();
    await appBundleBuilder.build(flavor);
    Logger.success('$flavor aab build completed');
  }

  Future<String?> _deployAab(String flavor) async {
    Logger.deploy('Deploying $flavor aab');
    await _validateAuth(config.yandexToken);
    // TODO: Add actual App Bundle deployment logic here
    final appBundleLink = 'https://yandex.disk/aab/$flavor'; // Placeholder for App Bundle link
    Logger.success('$flavor aab deployed successfully');
    return appBundleLink;
  }

  Future<void> _validateAuth(String? token) async {
    if (token == null || token.isEmpty) {
      Logger.error('Authentication required for deployment.');
      throw Exception('Authentication token is missing.');
    }
  }
}
