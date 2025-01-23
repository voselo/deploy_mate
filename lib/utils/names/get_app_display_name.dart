import 'dart:io';

String? getAppDisplayName(String flavor) {
  final configFilePath = 'ios/Flutter/Release-$flavor.xcconfig';
  final configFile = File(configFilePath);

  if (!configFile.existsSync()) {
    return null;
  }

  final lines = configFile.readAsLinesSync();
  for (final line in lines) {
    if (line.startsWith('app_display_name =')) {
      final parts = line.split('=');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
  }
  return null;
}
