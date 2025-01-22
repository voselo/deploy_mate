import 'dart:convert';

import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/core/project_config.dart';
import 'package:http/http.dart' as http;

class TelegramNotifier {
  final String? botToken;
  final String? chatId;

  TelegramNotifier(ProjectConfig config)
      : botToken = config.botToken,
        chatId = config.chatId;

  Future<void> sendReport({
    required String flavor,
    required String version,
    required String buildNumber,
    bool isIpaDeployed = false,
    String? apkLink,
    String? appBundleLink,
  }) async {
    if (botToken == null || chatId == null) {
      Logger.error('Telegram bot token or chat ID is missing in configuration.');
      return;
    }

    final String ipaStatus = isIpaDeployed ? '✅ Deployed to App Store Connect' : '';
    final String apkStatus = apkLink != null ? '👉 [APK]($apkLink)' : '';
    final String appBundleStatus = appBundleLink != null ? '👉 [App Bundle]($appBundleLink)' : '';

    final message = '''
      📦 *Build Report*
      Flavor: `$flavor`
      Version: `$version+$buildNumber`
      $ipaStatus
      $apkStatus
      $appBundleStatus
    ''';

    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': chatId,
        'text': message.trim(),
        'parse_mode': 'Markdown',
      }),
    );

    if (response.statusCode == 200) {
      Logger.success('Report successfully sent to Telegram.');
    } else {
      Logger.error('Failed to send report to Telegram: ${response.body}');
    }
  }
}
