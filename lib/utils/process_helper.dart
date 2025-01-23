import 'dart:io';

import 'package:deploy_mate/core/logger.dart';

class ProcessHelper {
  static Future<int> run(
    String command,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    Logger.processing('Running command: $command ${arguments.join(' ')}');

    final process = await Process.start(
      command,
      arguments,
      workingDirectory: workingDirectory,
    );

    process.stdout.transform(SystemEncoding().decoder).listen((data) => print(data.trim()));
    process.stderr.transform(SystemEncoding().decoder).listen((data) => Logger.error(data.trim()));

    final exitCode = await process.exitCode;
    return exitCode;
  }
}
