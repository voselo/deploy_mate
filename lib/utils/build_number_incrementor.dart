import 'package:deploy_mate/core/logger.dart';

Future<void> incrementBuildNumber() async {
  Logger.processing('Incrementing build number...');
  await incrementBuildNumber();
  Logger.success('Build number incremented successfully');
}
