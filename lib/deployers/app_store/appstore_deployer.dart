import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/core/logger.dart';
import 'package:deploy_mate/deployers/deployer_interface.dart';
import 'package:deploy_mate/utils/process_helper.dart';

class AppstoreDeployer implements IDeployer {
  final FlutterProjectConfig config;

  AppstoreDeployer(this.config);

  @override
  Future<int> deploy({required String filePath, Map<String, dynamic>? additionalParams}) async {
    final exitCode = await ProcessHelper.run('xcrun', [
      'altool',
      '--upload-app',
      '--type iOS',
      '-f ${filePath}',
      '--apiKey ${config.iosApiKey}',
      '--apiIssuer ${config.iosUserIssuer}'
    ]);

    if (exitCode != 0) {
      Logger.error('Ipa deploy failed with exit code $exitCode');
      return exitCode;
    }

    return 200;
  }
}
