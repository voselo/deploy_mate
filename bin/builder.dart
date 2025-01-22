import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/core/project_config.dart';
import 'package:deploy_mate/interact/select_config.dart';
import 'package:deploy_mate/interact/select_flavors.dart';
import 'package:deploy_mate/utils/check_directories.dart';
import 'package:deploy_mate/utils/flavor_processor.dart';

void main() async {
  final projectConfig = await ProjectConfig().init();

  // Stage 1: Check directories and configuration
  checkDirectoriesAndFile();

  // Stage 2: Select build options
  final options = getBuildOptions();

  // Stage 3: Fetch available flavors
  final flavors = FlavorProcessor.getAvailableFlavors();
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

  // Stage 5: Process each selected flavor
  final flavorProcessor = FlavorProcessor(projectConfig);
  for (final flavor in selectedFlavors) {
    Logger.processing('Processing flavor: $flavor');
    await flavorProcessor.run(
      flavor: flavor,
      options: options,
    );
  }

  Logger.success('CI/CD completed successfully');
}
