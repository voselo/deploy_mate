import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/utils/process_helper.dart';

class AppBundleBuilder implements IBuilder {
  AppBundleBuilder();

  @override
  Future<void> build(String flavor) async {
    await ProcessHelper.run(
      'flutter',
      ['build', 'appbundle', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--release'],
    );
  }
}
