import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:interact/interact.dart';

class BuildOptions {
  final bool incrementBuildNumber;
  final bool buildIpa;
  final bool deployIpa;
  final bool buildApk;
  final bool deployApk;
  final bool buildAppBundle;
  final bool deployAppBundle;

  BuildOptions({
    this.incrementBuildNumber = true,
    this.buildIpa = false,
    this.deployIpa = false,
    this.buildApk = false,
    this.deployApk = false,
    this.buildAppBundle = false,
    this.deployAppBundle = false,
  });
}

BuildOptions getBuildOptions(FlutterProjectConfig config) {
  final defaultOptions = BuildOptions();

  final List<String> options = [];
  final List<bool> defaults = [];

  options.add('Increment build number');
  defaults.add(defaultOptions.incrementBuildNumber);

  if (config.isIosEnabled) {
    options.addAll([
      'Build ipa',
      'Deploy ipa',
    ]);
    defaults.addAll([
      defaultOptions.buildIpa,
      defaultOptions.deployIpa,
    ]);
  }

  if (config.isAndroidEnabled) {
    options.addAll([
      'Build apk',
      'Deploy apk',
      'Build app bundle',
      'Deploy app bundle',
    ]);
    defaults.addAll([
      defaultOptions.buildApk,
      defaultOptions.deployApk,
      defaultOptions.buildAppBundle,
      defaultOptions.deployAppBundle,
    ]);
  }

  if (config.isWebEnabled) {
    // options.addAll([]);
  }

  final answers = MultiSelect(
    prompt: 'Select build configuration:',
    options: options,
    defaults: defaults,
  ).interact();

  return BuildOptions(
    incrementBuildNumber: answers.contains(0),
    buildIpa: answers.contains(1),
    deployIpa: answers.contains(2),
    buildApk: answers.contains(3),
    deployApk: answers.contains(4),
    buildAppBundle: answers.contains(5),
    deployAppBundle: answers.contains(6),
  );
}
