import 'dart:convert';
import 'dart:io';

import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class YandexService {
  final FlutterProjectConfig config;

  YandexService(this.config);

  Future<String> getAccessToken() async {
    String? accessToken = config.yandexToken;

    if (accessToken == null || accessToken.isEmpty) {
      Logger.info('Yandex token not found, requesting a new one...');
      accessToken = await _authYandex();
      if (accessToken != null) {
        config.yandexToken = accessToken;
        await config.save();
        Logger.success('Yandex token saved successfully');
      } else {
        throw Exception('Failed to obtain Yandex token.');
      }
    }

    return accessToken;
  }

  Future<String> getBuildAppLink(String filePath) async {
    final filename = path.basename(filePath);
    final pathOnDisk = '${config.yandexFolder}/$filename';

    final response = await http.get(
      Uri.parse('https://cloud-api.yandex.net/v1/disk/resources/download?path=$pathOnDisk'),
      headers: {
        'Authorization': 'OAuth ${config.yandexToken}',
      },
    );

    if (response.statusCode != 200) {
      final errorResponse = json.decode(response.body);
      final errorMessage = errorResponse['error'] ?? 'Unknown error';
      print('Failed to get download URL. Error: $errorMessage');
      print('Response: ${response.body}');
      return '';
    }

    final downloadLink = json.decode(response.body)['href'];
    return downloadLink;
  }

  Future<void> getDiskInfo() async {
    final accessToken = await getAccessToken();
    final response = await http.get(
      Uri.parse('https://cloud-api.yandex.net/v1/disk/'),
      headers: {
        'Authorization': 'OAuth $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final diskInfo = json.decode(utf8.decode(response.bodyBytes));
      final totalSpace = diskInfo['total_space'];
      final usedSpace = diskInfo['used_space'];
      final freeSpace = totalSpace - usedSpace;
      Logger.info('Yandex Disk Info:');
      Logger.info('Total Space: ${(totalSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB');
      Logger.info('Used Space: ${(usedSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB');
      Logger.info('Free Space: ${(freeSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB');

      // Ensure folder exists
      await _ensureYandexFolderExists(config.yandexFolder, accessToken);
    } else {
      Logger.error('Failed to get disk info. Status code: ${response.statusCode}');
      Logger.error('Response: ${response.body}');
      throw Exception('Failed to get disk info.');
    }
  }

  Future<void> manageTargetFolder() async {
    final folderPath = Uri.parse(config.yandexFolder);
    final url = Uri.parse('https://cloud-api.yandex.net/v1/disk/resources?path=$folderPath');

    final token = config.yandexToken;

    // Получение списка файлов
    final response = await http.get(
      url,
      headers: {'Authorization': 'OAuth $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final files = (data['_embedded']['items'] as List).map((item) {
        return {
          'name': item['name'],
          'path': item['path'],
          'modified': DateTime.parse(item['modified']),
        };
      }).toList();

      // Сортировка по дате модификации (новые сверху)
      files.sort((a, b) => b['modified'].compareTo(a['modified']));

      final maxFiles = config.yandexMaxSavedBuilds - 1;

      // Удаление старых файлов
      if (files.length > maxFiles) {
        Logger.processing('Performing yandex folder before deploy');

        final filesToDelete = files.skip(maxFiles).toList();
        Logger.info('filesToDelete ${filesToDelete.length}');

        for (final file in filesToDelete) {
          await _deleteFile(file['path']);
        }

        Logger.success('Yandex folder performed');
      }
    } else {
      throw Exception('Failed to fetch folder contents. Status: ${response.statusCode}');
    }
  }

  Future<void> _ensureYandexFolderExists(String folderPath, String accessToken) async {
    final url = 'https://cloud-api.yandex.net/v1/disk/resources?path=$folderPath';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'OAuth $accessToken'},
    );

    if (response.statusCode == 404) {
      Logger.info('Folder $folderPath does not exist. Creating...');
      final createResponse = await http.put(
        Uri.parse(url),
        headers: {'Authorization': 'OAuth $accessToken'},
      );

      if (createResponse.statusCode == 201) {
        Logger.success('Folder $folderPath created successfully');
      } else {
        throw Exception(
          'Failed to create folder. Status: ${createResponse.statusCode}, Body: ${createResponse.body}',
        );
      }
    } else if (response.statusCode != 200) {
      throw Exception(
        'Failed to validate folder existence. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<String?> _authYandex() async {
    const redirectUri = 'http://localhost:8080/callback';
    final clientId = config.yandexAppClientId;
    final clientSecret = config.yandexAppClientSecret;

    if (clientId == null || clientSecret == null) {
      Logger.error('Yandex app credentials not found');
      throw Exception('Pls configure yaml file by readme instructions');
    }

    final authorizeUrl =
        'https://oauth.yandex.ru/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri';

    Logger.info('Please go to the following URL and authorize the app:');
    Logger.info(authorizeUrl);

    if (await Process.run('which', ['open']).then((result) => result.exitCode == 0)) {
      await Process.start('open', [authorizeUrl]); // macOS
    } else if (await Process.run('which', ['xdg-open']).then((result) => result.exitCode == 0)) {
      await Process.start('xdg-open', [authorizeUrl]); // Linux
    } else if (await Process.run('which', ['start']).then((result) => result.exitCode == 0)) {
      await Process.start('start', [authorizeUrl]); // Windows
    } else {
      Logger.warning('Please open the URL manually in your browser.');
    }

    final authCode = await _listenYandexCallback();
    Logger.processing('Authorization code received: $authCode');

    if (authCode.isNotEmpty) {
      final base64Creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
      final response = await http.post(
        Uri.parse('https://oauth.yandex.ru/token'),
        headers: {
          'Authorization': 'Basic $base64Creds',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final accessToken = responseBody['access_token'];
        Logger.success('Access token obtained successfully');
        return accessToken;
      } else {
        Logger.error('Failed to obtain access token: ${response.body}');
        throw Exception('Failed to obtain access token.');
      }
    } else {
      throw Exception('Authorization code is empty.');
    }
  }

  Future<String> _listenYandexCallback() async {
    final port = 8080;
    Logger.info('Listening on http://localhost:$port/callback');

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

    await for (HttpRequest request in server) {
      if (request.uri.path == '/callback') {
        final authCode = request.uri.queryParameters['code'];
        if (authCode != null) {
          Logger.success('Received OAuth code: $authCode');
          request.response
            ..statusCode = HttpStatus.ok
            ..write('Authorization successful. You can close this page.');
          await request.response.close();
          await server.close();
          return authCode;
        } else {
          Logger.warning('Invalid callback without code');
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Invalid callback. Missing authorization code.');
          await request.response.close();
        }
      }
    }
    return '';
  }

  Future<void> _deleteFile(String filePath) async {
    final url = 'https://cloud-api.yandex.net/v1/disk/resources?path=$filePath&permanently=true';

    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'OAuth ${config.yandexToken}'},
    );

    if (response.statusCode != 204) {
      Logger.error(
        'Failed to delete file $filePath. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
