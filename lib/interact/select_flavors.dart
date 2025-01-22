import 'package:interact/interact.dart';

List<String> selectFlavors(List<String> flavors) {
  final answers = MultiSelect(
    prompt: 'Select flavors',
    options: flavors,
  ).interact();
  final selectedFlavors = answers.map((index) => flavors[index]).toList();
  return selectedFlavors;
}
