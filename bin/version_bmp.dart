import 'dart:io';

import 'package:args/args.dart';
import 'package:git/git.dart';

void main(List<String> arguments) async {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption("path", abbr: "p", defaultsTo: "pubspec.yaml")
    ..addOption("type", abbr: "t", defaultsTo: "patch")
    ..addFlag("git", abbr: "g", defaultsTo: false);

  ArgResults argResults = parser.parse(arguments);

  await versionBump(
      path: argResults['path'],
      type: argResults['type'],
      git: argResults['git']);
}

const validTypes = ['major', 'minor', 'patch'];

Future<void> versionBump(
    {required String path, required String type, required bool git}) async {
  var lineNumber = 0;
  var file = File(path);

  if (!await file.exists()) {
    print('File not found: $path');
    exit(1);
  }

  if (!validTypes.contains(type)) {
    print('Invalid type: $type');
    exit(1);
  }

  // Read the contents of the file
  var lines = file.readAsLinesSync();
  try {
    for (final line in lines) {
      RegExp exp = RegExp(r'version: (\d+.\d+.\d+)\+?(\d+)?');
      String str = line;
      RegExpMatch? match = exp.firstMatch(str);
      if (exp.hasMatch(str)) {
        final version = match!.group(1);
        final code = match.group(2);

        var major = int.parse(version!.split('.')[0]);
        var minor = int.parse(version.split('.')[1]);
        var patch = int.parse(version.split('.')[2]);

        if (type == 'major') {
          major++;
          minor = 0;
          patch = 0;
        } else if (type == 'minor') {
          minor++;
          patch = 0;
        } else {
          patch++;
        }

        var newVersion = '$major.$minor.$patch';

        if (code != null) {
          final newCode = int.parse(code) + 1;
          newVersion = '$newVersion+$newCode';
        }

        print("old version: $version+$code");
        print('new version: $newVersion');

        // write new version to file
        lines[lineNumber] = 'version: $newVersion';
        file.writeAsStringSync(lines.join('\n'));

        if (git && await GitDir.isGitDir(".")) {
          final gitDir = await GitDir.fromExisting(".");
          await gitDir.runCommand(["add", "."]);
          await gitDir.runCommand(["commit", "-m", "[RELEASE] $newVersion"]);
          await gitDir
              .runCommand(["tag", "-a", "$newVersion", "-m", "Release"]);
        }

        break;
      }
      lineNumber++;
    }
  } catch (err) {
    print(err);
    print('Error reading file: $path');
    exit(1);
  }
}
