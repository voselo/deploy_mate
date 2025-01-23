import 'dart:io';

String getAndroidOutputName(String flavor) {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    throw Exception('Error: pubspec.yaml not found');
  }

  final lines = pubspecFile.readAsLinesSync();
  String? version;
  String? buildNumber;

  for (final line in lines) {
    if (line.startsWith('version:')) {
      final versionInfo = line.split(':')[1].trim();
      final parts = versionInfo.split('+');
      if (parts.length == 2) {
        version = parts[0].trim();
        buildNumber = parts[1].trim();
      }
      break;
    }
  }

  if (version == null || buildNumber == null) {
    throw Exception('Error: version or build number not found in pubspec.yaml');
  }

  return '$flavor-${version}_$buildNumber';
}
