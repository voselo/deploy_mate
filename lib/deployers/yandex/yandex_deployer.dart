import 'dart:convert';
import 'dart:io';

import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/deployers/deployer_interface.dart';
import 'package:http/http.dart' as http;

class YandexDeployer implements IDeployer {
  final FlutterProjectConfig config;

  YandexDeployer(this.config);

  @override
  Future<void> deploy({required String filePath, Map<String, dynamic>? additionalParams}) async {
    if (!File(filePath).existsSync()) {
      Logger.error('File $filePath does not exist.');
      return;
    }

    final accessToken = config.yandexToken;
    final yandexFolder = config.yandexFolder;

    if (accessToken == null) {
      Logger.error('Yandex token is not configured.');
      return;
    }

    try {
      final fileName = filePath.split('/').last;
      final uploadUrl = await _getUploadLink(fileName, accessToken, yandexFolder);

      if (uploadUrl != null) {
        await _uploadFile(filePath, uploadUrl, accessToken);
        Logger.success('File $fileName uploaded successfully to yandex drive');
      } else {
        Logger.error('Failed to get upload URL for $fileName.');
      }
    } catch (e) {
      Logger.error('Deployment failed: $e');
    }
  }

  /// Get upload link from Yandex Disk
  Future<String?> _getUploadLink(String fileName, String accessToken, String yandexFolder) async {
    final url = 'https://cloud-api.yandex.net/v1/disk/resources/upload?path=$yandexFolder/$fileName&overwrite=true';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'OAuth $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['href'];
    } else {
      Logger.error('Failed to get upload link. Status: ${response.statusCode}, Body: ${response.body}');
      return null;
    }
  }

  /// Upload file to Yandex Disk using the provided upload link
  Future<void> _uploadFile(String filePath, String uploadUrl, String accessToken) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Authorization': 'OAuth $accessToken'},
      body: File(filePath).readAsBytesSync(),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to upload file. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
