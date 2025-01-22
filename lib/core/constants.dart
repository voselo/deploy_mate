class Constants {
  static const String configFilePath = 'build_config.yaml';
  static const String defaultOutputDir = 'build_outputs';

  // Required keys
  static const String botToken = 'bot_token';
  static const String chatId = 'chat_id';
  static const String yandexToken = 'yandex_token';
  static const String IOSApiKey = 'IOS_api_key';
  static const String IOSUserIssuer = 'IOS_user_issuer';

  // Grouped lists
  static const List<String> requiredKeys = [
    botToken,
    chatId,
    yandexToken,
    IOSApiKey,
    IOSUserIssuer,
  ];
}
