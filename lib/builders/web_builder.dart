import 'package:deploy_mate/builders/interface/builder_interface.dart';
import 'package:deploy_mate/utils/process_helper.dart';

class WebBuilder implements IBuilder {
  WebBuilder();

  @override
  Future<void> build(String flavor, {String? targetDir}) async {

    await ProcessHelper.run(
      'flutter',
      ['build', 'web', '--flavor=$flavor', '--dart-define=FLAVOR=$flavor', '--release'],
    );
  }
}
