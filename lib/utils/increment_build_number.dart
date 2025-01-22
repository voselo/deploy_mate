import 'dart:async';
import 'dart:io';

Future<void> incrementBuildNumber() async {
  final pubspecPath = 'pubspec.yaml';
  final pubspecFile = File(pubspecPath);

  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final lines = pubspecFile.readAsLinesSync();
  String? versionLine;
  int? currentBuildNumber;

  for (final line in lines) {
    if (line.startsWith('version:')) {
      versionLine = line;
      final buildNumberMatch = RegExp(r'\+(\d+)$').firstMatch(line);
      if (buildNumberMatch != null) {
        currentBuildNumber = int.tryParse(buildNumberMatch.group(1)!);
      }
      break;
    }
  }

  if (versionLine == null || currentBuildNumber == null) {
    print('Error: version or build number not found in pubspec.yaml');
    exit(1);
  }

  final newBuildNumber = currentBuildNumber + 1;
  final newVersionLine = versionLine.replaceFirst(RegExp(r'\+\d+$'), '+$newBuildNumber');

  final newLines = lines.map((line) => line == versionLine ? newVersionLine : line).toList();
  pubspecFile.writeAsStringSync(newLines.join('\n'));

  print('Updated build number to: $newBuildNumber');
}
