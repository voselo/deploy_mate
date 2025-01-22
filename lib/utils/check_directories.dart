import 'dart:io';

import 'package:deploy_mate/core/logger.dart';

void checkDirectoriesAndFile() {
  // Get the current working directory
  final currentDirectory = Directory.current;

  // Define paths for required directories and files
  final IOSFlutterPath = Directory('${currentDirectory.path}/IOS/Flutter/');
  final pubspecFilePath = File('${currentDirectory.path}/pubspec.yaml');

  // Check if the IOS Flutter directory exists
  if (!IOSFlutterPath.existsSync()) {
    Logger.error('Directory IOS/Flutter not found at ${IOSFlutterPath.path}.');
    exit(1);
  }

  // Check if the pubspec.yaml file exists
  if (!pubspecFilePath.existsSync()) {
    Logger.error('File pubspec.yaml not found at ${pubspecFilePath.path}.');
    exit(1);
  }
}
