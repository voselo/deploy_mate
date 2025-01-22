import 'dart:io';

import 'package:deploy_mate/core/logger.dart';
import 'package:yaml/yaml.dart';

class ProjectConfig {
  final Map<String, dynamic> _config = {};

  String? get botToken => _config['bot_token'];
  String? get chatId => _config['chat_id'];
  String? get yandexToken => _config['yandex_token'];

  ProjectConfig();

  /// Initialize configuration from the default YAML file
  Future<ProjectConfig> init({String configFilePath = 'build_config.yaml'}) async {
    Logger.processing('Initializing build configuration from $configFilePath...');

    final file = File(configFilePath);

    if (!file.existsSync()) {
      Logger.error('Configuration file $configFilePath not found.');
      exit(1);
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content);

    if (yaml is YamlMap) {
      _config.addAll(yaml.cast<String, dynamic>());
    } else {
      Logger.error('Invalid format in configuration file $configFilePath.');
      exit(1);
    }

    Logger.success('Build configuration loaded successfully.');
    return this;
  }

  /// Get a value from the configuration
  T? getValue<T>(String key) {
    if (!_config.containsKey(key)) {
      Logger.warning('Configuration key not found: $key');
      return null;
    }
    return _config[key] as T?;
  }

  void validateKeys(List<String> requiredKeys) {
    for (final key in requiredKeys) {
      if (!_config.containsKey(key)) {
        throw Exception('Missing required configuration key: $key');
      }
    }
  }
}
