import 'dart:convert';

import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/utils/get_current_git_branch.dart';
import 'package:http/http.dart' as http;

class TelegramNotifier {
  final String? botToken;
  final String? chatId;

  TelegramNotifier(FlutterProjectConfig config)
      : botToken = config.botToken,
        chatId = config.chatId;

  Future<void> sendReport({
    required String flavor,
    required String version,
    bool isIpaDeployed = false,
    String? apkLink,
    String? appBundleLink,
  }) async {
    if (botToken == null || chatId == null) {
      Logger.error('Telegram bot token or chat ID is missing in configuration.');
      return;
    }

    final buffer = StringBuffer();

    buffer.writeln('📦 *$flavor $version*');

    final branch = await getCurrentGitBranch();

    buffer.writeln('🌿 *$branch*');

    if (isIpaDeployed) {
      buffer.writeln('✅ Deployed to App Store Connect');
    }

    if (apkLink != null) {
      buffer.writeln('👉 [download APK]($apkLink)');
    }

    if (appBundleLink != null) {
      buffer.writeln('👉 [download App Bundle]($appBundleLink)');
    }

    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': chatId,
        'text': buffer.toString(),
        'parse_mode': 'Markdown',
      }),
    );

    if (response.statusCode == 200) {
      Logger.success('Telegram report sent');
    } else {
      Logger.error('Failed to send report to Telegram: ${response.body}');
    }
  }
}
