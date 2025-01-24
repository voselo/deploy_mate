import 'dart:io';

import 'package:deploy_mate/builders/apk_builder.dart';
import 'package:deploy_mate/builders/apppbundle_builder.dart';
import 'package:deploy_mate/builders/ipa_builder.dart';
import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/deployers/app_store/appstore_deployer.dart';
import 'package:deploy_mate/deployers/yandex/yandex_deployer.dart';
import 'package:deploy_mate/deployers/yandex/yandex_service.dart';
import 'package:deploy_mate/interact/select_options.dart';
import 'package:deploy_mate/notifiers/telegram_notifier.dart';
import 'package:deploy_mate/utils/cleaner.dart';
import 'package:deploy_mate/utils/get_version_from_pubspec.dart';
import 'package:deploy_mate/utils/names/get_android_output_name.dart';
import 'package:deploy_mate/utils/names/get_app_display_name.dart';
import 'package:path/path.dart' as path;

class BuildExecutor {
  final FlutterProjectConfig config;
  final TelegramNotifier telegramNotifier;
  final Map<String, dynamic> buildReport = {};

  BuildExecutor(this.config, this.telegramNotifier);

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
  IOSink? logFileStream;

  Future<void> run({
    required String flavor,
    required BuildOptions options,
  }) async {
    logFileStream = File(logFile(flavor)).openWrite();

    await _validateTargetDirectory();

    final yandexService = YandexService(config);
    if (options.deployApk || options.deployAppBundle) {
      await yandexService.getDiskInfo();
    }

    buildReport['flavor'] = flavor;
    // buildReport['version'] = config.version;
    // buildReport['buildNumber'] = config.buildNumber;

    // Build IPA
    if (options.buildIpa) {
      await _buildIpa(flavor);
    }

    // Deploy IPA
    if (options.deployIpa) {
      await _deployIpa(flavor);
    }

    // Build APK
    if (options.buildApk) {
      await _buildApk(flavor);
    }

    // Deploy APK
    if (options.deployApk) {
      await _deployApk(yandexService, flavor);
    }

    // Build App Bundle
    if (options.buildAppBundle) {
      await _buildAab(flavor);
    }

    // Deploy App Bundle
    if (options.deployAppBundle) {
      await _deployAab(yandexService, flavor);
    }

    final version = await getVersionFromPubspec();
    await telegramNotifier.sendReport(
      flavor: flavor,
      version: version,
      apkLink: buildReport['apkLink'],
      appBundleLink: buildReport['appBundleLink'],
      isIpaDeployed: buildReport['isIpaDeployed'] ?? false,
    );

    await logFileStream?.close();
  }

  Future<void> _validateTargetDirectory() async {
    final targetDir = Directory(config.targetDirectory);

    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
      Logger.info('Created target directory: ${targetDir.path}');
    }
  }

  Future<void> _buildIpa(String flavor) async {
    Logger.processing('Building $flavor ipa');

    await Cleaner.cleanDirectory('build/ios/ipa/');

    final ipaBuilder = IpaBuilder();
    await ipaBuilder.build(flavor);
    Logger.success('$flavor ipa build completed');
  }

  Future<void> _deployIpa(String flavor) async {
    Logger.deploy('Deploying $flavor ipa');
    final appDisplayName = getAppDisplayName(flavor);
    final ipaPath = 'build/ios/ipa/$appDisplayName.ipa';
    final result = await AppstoreDeployer(config).deploy(filePath: ipaPath);

    if (result == 200) {
      buildReport['isIpaDeployed'] = true;
      Logger.success('$flavor ipa deployed successfully');
    }
  }

  Future<void> _buildApk(String flavor) async {
    Logger.processing('Building $flavor apk');
    final apkBuilder = ApkBuilder();
    await apkBuilder.build(flavor, targetDir: config.targetDirectory);
    Logger.success('$flavor apk build completed');
  }

  Future<void> _deployApk(YandexService yandexService, String flavor) async {
    Logger.deploy('Deploying $flavor apk');
    await _validateAuth(() async {
      final YandexDeployer yandexDeployer = YandexDeployer(config);

      final appOutputName = getAndroidOutputName(flavor);
      final appPath = '${config.targetDirectory}/$appOutputName.apk';

      await yandexService.manageTargetFolder();
      await yandexDeployer.deploy(filePath: appPath);
      final downloadApkLink = await yandexService.getBuildAppLink(path.basename(appPath));
      buildReport['apkLink'] = downloadApkLink;
    });
  }

  Future<void> _buildAab(String flavor) async {
    Logger.processing('Building $flavor aab');
    final appBundleBuilder = AppBundleBuilder();
    await appBundleBuilder.build(flavor, targetDir: config.targetDirectory);
    Logger.success('$flavor aab build completed');
  }

  Future<void> _deployAab(YandexService yandexService, String flavor) async {
    Logger.deploy('Deploying $flavor aab');
    await _validateAuth(() async {
      final YandexDeployer yandexDeployer = YandexDeployer(config);

      final appOutputName = getAndroidOutputName(flavor);
      final appPath = '${config.targetDirectory}/$appOutputName.aab';

      await yandexService.manageTargetFolder();
      await yandexDeployer.deploy(filePath: appPath);
      final downloadApkLink = await yandexService.getBuildAppLink(path.basename(appPath));
      buildReport['appBundleLink'] = downloadApkLink;
    });
  }

  Future<void> _validateAuth(Function() callback) async {
    if (config.yandexToken == null) {
      Logger.error('Authentication required for deployment');
    } else {
      await callback();
    }
  }
}
