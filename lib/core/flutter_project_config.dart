import 'dart:io';

import 'package:deploy_mate/core/logger.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

class FlutterProjectConfig {
  final Map<String, dynamic> _config = {};

  final targetDirectory = 'build/apps_builds';

  String? get botToken => _config['bot_token'];
  set botToken(String? value) => _updateConfig('bot_token', value);

  String? get chatId => _config['chat_id'];
  set chatId(String? value) => _updateConfig('chat_id', value);

  String? get yandexToken => _config['yandex_token'];
  set yandexToken(String? value) => _updateConfig('yandex_token', value);

  String get yandexFolder => _config['yandex_folder'] ?? '/deploy_mate_builds';
  set yandexFolder(String? value) => _updateConfig('yandex_folder', value);

  String? get yandexAppClientId => _config['yandex_app_client_id'];
  set yandexAppClientId(String? value) => _updateConfig('yandex_app_client_id', value);

  int get yandexMaxSavedBuilds => _config['yandex_max_saved_builds'] ?? 5;
  set yandexMaxSavedBuilds(int value) => _updateConfig('yandex_max_saved_builds', value);

  String? get yandexAppClientSecret => _config['yandex_app_client_secret'];
  set yandexAppClientSecret(String? value) => _updateConfig('yandex_app_client_secret', value);

  bool get isIosEnabled => _config['use_ios'] ?? false;
  set useIos(bool value) => _updateConfig('use_ios', value);

  bool get isAndroidEnabled => _config['use_android'] ?? false;
  set useAndroid(bool value) => _updateConfig('use_android', value);

  bool get isWebEnabled => _config['use_web'] ?? false;
  set useWeb(bool value) => _updateConfig('use_web', value);

  FlutterProjectConfig();

  /// Initialize configuration from the default YAML file
  Future<FlutterProjectConfig> init({String configFilePath = 'build_config.yaml'}) async {
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

    Logger.success('Build configuration loaded successfully');
    return this;
  }

  /// Save configuration back to the YAML file
  Future<void> save({String configFilePath = 'build_config.yaml'}) async {
    Logger.processing('Saving configuration to $configFilePath...');
    final yamlWriter = YamlWriter();
    final yamlString = yamlWriter.write(_config);
    final configFile = File(configFilePath);
    await configFile.writeAsString(yamlString);
    Logger.success('Configuration saved successfully');
  }

  /// Update a specific key in the configuration
  void _updateConfig(String key, dynamic value) {
    if (value == null) {
      _config.remove(key);
    } else {
      _config[key] = value;
    }
  }

  /// Get a value from the configuration
  T? getValue<T>(String key) {
    if (!_config.containsKey(key)) {
      Logger.warning('Configuration key not found: $key');
      return null;
    }
    return _config[key] as T?;
  }

  /// Validate that required keys exist in the configuration
  void validateKeys(List<String> requiredKeys) {
    for (final key in requiredKeys) {
      if (!_config.containsKey(key)) {
        throw Exception('Missing required configuration key: $key');
      }
    }
  }
}
