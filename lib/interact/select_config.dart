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
    this.incrementBuildNumber = false,
    this.buildIpa = false,
    this.deployIpa = false,
    this.buildApk = false,
    this.deployApk = false,
    this.buildAppBundle = false,
    this.deployAppBundle = false,
  });
}

BuildOptions getBuildOptions() {
  final defaultOptions = BuildOptions();
  final answers = MultiSelect(
    prompt: 'Select build configuration:',
    options: [
      'Increment build number',
      'Build ipa',
      'Deploy ipa',
      'Build apk',
      'Deploy apk',
      'Build app bundle',
      'Deploy app bundle',
    ],
    defaults: [
      defaultOptions.incrementBuildNumber,
      defaultOptions.buildIpa,
      defaultOptions.deployIpa,
      defaultOptions.buildApk,
      defaultOptions.deployApk,
      defaultOptions.buildAppBundle,
      defaultOptions.deployAppBundle,
    ],
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
