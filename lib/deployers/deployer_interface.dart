abstract class IDeployer {
  Future<int> deploy({required String filePath, Map<String, dynamic>? additionalParams});
}
