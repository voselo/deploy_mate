abstract class IDeployer {
  Future<void> deploy({String? filePath, Map<String, dynamic>? additionalParams});
}
