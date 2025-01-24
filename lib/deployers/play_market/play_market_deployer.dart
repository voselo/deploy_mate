import 'package:deploy_mate/core/flutter_project_config.dart';
import 'package:deploy_mate/deployers/deployer_interface.dart';

class PlayMarketDeployer implements IDeployer {
  final FlutterProjectConfig config;

  PlayMarketDeployer(this.config);

  @override
  Future<void> deploy({required String filePath, Map<String, dynamic>? additionalParams}) {
    throw UnimplementedError();
  }
}
