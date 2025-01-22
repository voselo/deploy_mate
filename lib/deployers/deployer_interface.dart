abstract class IDeployer {
  Future<void> deploy({required String filePath, Map<String, dynamic>? additionalParams});
}
