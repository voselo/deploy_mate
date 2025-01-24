import 'dart:io';

import 'package:deploy_mate/core/logger.dart';

class Cleaner {
  static Future<void> cleanDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    Logger.processing('Preparing target directory');

    if (!directory.existsSync()) {
      Logger.info('Directory does not exist: $directoryPath');
      return;
    }

    final files = directory.listSync();

    if (files.isEmpty) return;

    for (final file in files) {
      try {
        if (file is File) {
          file.deleteSync();
        } else if (file is Directory) {
          file.deleteSync(recursive: true);
        }
      } catch (e) {
        Logger.error('Failed to delete ${file.path}: $e');
      }
    }

    Logger.success('Target directory prepared');
  }
}
