import 'package:deploy_mate/core/build_executor.dart';
import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/interact/select_flavors.dart';
import 'package:deploy_mate/interact/select_options.dart';
import 'package:deploy_mate/notifiers/telegram_notifier.dart';
import 'package:deploy_mate/utils/check_directories.dart';
import 'package:deploy_mate/utils/cleaner.dart';
import 'package:deploy_mate/utils/increment_build_number.dart';

void main() async {
  final FlutterProjectConfig flutterProjectConfig = await FlutterProjectConfig().init();
  final TelegramNotifier telegramNotifier = TelegramNotifier(flutterProjectConfig);

  // Stage 1: Check directories and configuration
  checkDirectoriesAndFile();

  // Stage 2: Select build options
  final options = getBuildOptions(flutterProjectConfig);

  // Stage 3: Fetch available flavors
  final flavors = BuildExecutor.getAvailableFlavors();
  if (flavors.isEmpty) {
    Logger.error('No flavors found. Exiting...');
    return;
  }

  // Stage 4: Select flavors to process
  final selectedFlavors = selectFlavors(flavors);
  if (selectedFlavors.isEmpty) {
    Logger.error('No flavors selected. Exiting...');
    return;
  }

  // Increment build number
  if (options.incrementBuildNumber) {
    await incrementBuildNumber();
  }

  await Cleaner.cleanDirectory(flutterProjectConfig.targetDirectory);

  // Stage 5: Process each selected flavor
  final flavorProcessor = BuildExecutor(flutterProjectConfig, telegramNotifier);
  for (final flavor in selectedFlavors) {
    Logger.processing('Processing flavor: $flavor');
    await flavorProcessor.run(
      flavor: flavor,
      options: options,
    );
  }

  Logger.success('CI/CD completed successfully');
}
