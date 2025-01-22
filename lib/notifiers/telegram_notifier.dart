import 'package:deploy_mate/notifiers/interface/notifier_interface.dart';
import 'package:dio/dio.dart';

class TelegramNotifier implements INotifier {
  final String botToken;
  final String chatId;
  final Dio dio;

  TelegramNotifier({
    required this.botToken,
    required this.chatId,
  }) : dio = Dio();

  @override
  Future<void> sendReport({
    required String title,
    required String body,
    Map<String, dynamic>? metadata,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/sendMessage';
    final message = _formatMessage(title, body, metadata);

    try {
      final response = await dio.post(
        url,
        data: {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'Markdown',
        },
      );

      if (response.statusCode == 200) {
        print('Telegram report sent: $title');
      } else {
        print('Failed to send Telegram report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending Telegram report: $e');
    }
  }

  String _formatMessage(String title, String body, Map<String, dynamic>? metadata) {
    final buffer = StringBuffer();
    buffer.writeln('*$title*');
    buffer.writeln(body);

    if (metadata != null && metadata.isNotEmpty) {
      buffer.writeln('\n*Details:*');
      metadata.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    return buffer.toString();
  }
}
