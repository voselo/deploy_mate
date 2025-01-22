import 'dart:io';

Future<String> getVersionFromPubspec() async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return 'Unknown version';
  }

  final lines = await pubspecFile.readAsLines();
  for (final line in lines) {
    if (line.startsWith('version:')) {
      final version = line.split(':')[1].trim();
      return version;
    }
  }
  return 'Unknown version';
}
