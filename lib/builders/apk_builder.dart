import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/utils/process_helper.dart';

class ApkBuilder implements IBuilder {
  ApkBuilder();

  @override
  Future<void> build(String flavor) async {
    await ProcessHelper.run(
      'flutter',
      ['build', 'apk', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--release'],
    );
  }
}
