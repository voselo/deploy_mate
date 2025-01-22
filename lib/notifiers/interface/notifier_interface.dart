abstract class INotifier {
  Future<void> sendReport({required String title, required String body, Map<String, dynamic>? metadata});
}
