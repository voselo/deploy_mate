import 'dart:io';

Future<String> getCurrentGitBranch() async {
  final result = await Process.run('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  } else {
    throw Exception('Failed to get current Git branch: ${result.stderr}');
  }
}
