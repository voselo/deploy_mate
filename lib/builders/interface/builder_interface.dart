abstract class IBuilder {
  Future<void> build(String flavor, {String? outputDir});
}
