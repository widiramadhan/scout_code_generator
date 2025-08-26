import 'dart:io';
import 'package:args/command_runner.dart';

import 'src/config.dart';
import 'src/init.dart';
import 'src/make_feature.dart';
import 'src/make_usecase.dart';

/// Entry point utama untuk command runner
Future<void> main(List<String> args) async {
  final runner = CommandRunner('scout', 'CLI scaffolder')
    ..addCommand(InitCommand())
    ..addCommand(MakeFeatureCommand())
    ..addCommand(MakeUsecaseCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  }
}

// ---------------- Commands ----------------

class InitCommand extends Command {
  @override
  final name = 'init';
  @override
  final description = 'Initialize scout_config.dart file';

  @override
  void run() {
    handleInit();
  }
}

class MakeFeatureCommand extends Command {
  @override
  final name = 'make:feature';
  @override
  final description = 'Generate a new feature scaffold';

  MakeFeatureCommand() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite files if already exist',
      negatable: false,
    );
  }

  @override
  void run() {
    if (argResults!.rest.isEmpty) {
      print('Usage: scout make:feature <feature_name> "Author Name" [--force]');
      return;
    }

    final featureName = argResults!.rest[0];
    final author = (argResults!.rest.length >= 2)
        ? argResults!.rest[1]
        : 'Unknown';
    final force = argResults!['force'] == true;

    final config = loadConfigOrExit();
    if (config == null) return;

    final ok = validateConfig(config);
    if (!ok) {
      stderr.writeln('Config invalid. Please re-run `scout init`.');
      exit(65);
      return;
    }

    // --- tanya state management ---
    stdout.writeln('Pilih state management untuk feature "$featureName":');
    stdout.writeln('1) setState (default Flutter)');
    stdout.writeln('2) Provider');
    stdout.writeln('3) Riverpod');
    stdout.writeln('4) Bloc / Cubit');
    stdout.writeln('5) GetX');
    stdout.writeln('6) MobX');
    stdout.writeln('7) Redux');
    stdout.writeln('8) MVVM');
    stdout.write(
      'Masukkan pilihan (1-8) [default: ${config.stateManagement}]: ',
    );

    final input = stdin.readLineSync();
    String stateManagement = config.stateManagement; // default global
    switch (input) {
      case '1':
        stateManagement = 'setstate';
        break;
      case '2':
        stateManagement = 'provider';
        break;
      case '3':
        stateManagement = 'riverpod';
        break;
      case '4':
        stateManagement = 'bloc';
        break;
      case '5':
        stateManagement = 'getx';
        break;
      case '6':
        stateManagement = 'mobx';
        break;
      case '7':
        stateManagement = 'redux';
        break;
      case '8':
        stateManagement = 'mvvm';
        break;
      default:
        stateManagement = 'provider';
        break;
    }
    // --- auto install dependency sesuai state management ---
    String? dep;
    switch (stateManagement) {
      case 'provider':
        dep = 'provider';
        break;
      case 'riverpod':
        dep = 'flutter_riverpod';
        break;
      case 'bloc':
        dep = 'flutter_bloc';
        break;
      case 'getx':
        dep = 'get';
        break;
      case 'mobx':
        dep = 'flutter_mobx';
        break;
      case 'redux':
        dep = 'flutter_redux';
        break;
      // setstate & mvvm biasanya tidak perlu package tambahan
      default:
        dep = null;
        break;
    }
    if (dep != null) {
      // Cek apakah dependency sudah ada di pubspec.yaml
      final pubspecFile = File('pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final pubspecContent = pubspecFile.readAsStringSync();
        final alreadyExists = RegExp(
          '^  $dep:',
          multiLine: true,
        ).hasMatch(pubspecContent);
        if (alreadyExists) {
          stdout.writeln(
            '[auto] Dependency $dep sudah ada di pubspec.yaml, skip penambahan.',
          );
        } else {
          stdout.writeln('Menambahkan dependency: $dep ...');
          final result = Process.runSync('flutter', ['pub', 'add', dep]);
          stdout.write(result.stdout);
          stderr.write(result.stderr);
          if (result.exitCode == 0) {
            stdout.writeln('[✓] Dependency $dep berhasil ditambahkan.');
          } else {
            stderr.writeln('[!] Gagal menambahkan dependency $dep.');
          }
        }
      } else {
        stderr.writeln(
          '[!] pubspec.yaml tidak ditemukan, tidak bisa cek dependency.',
        );
      }
    }

    generateFeature(
      config: config,
      featureName: featureName,
      author: author,
      force: force,
      stateManagement: stateManagement,
    );
  }
}

class MakeUsecaseCommand extends Command {
  @override
  final name = 'make:usecase';
  @override
  final description = 'Generate a usecase inside an existing feature';

  MakeUsecaseCommand() {
    //argParser.addFlag('help', abbr: 'h', negatable: false, help: 'Show help');
  }

  @override
  Future<void> run() async {
    if (argResults!.rest.length < 2) {
      print(
        'Usage: scout make:usecase <feature_name> <usecase_name> "Author Name"',
      );
      return;
    }

    final featureName = argResults!.rest[0];
    final usecaseName = argResults!.rest[1];
    final author = argResults!.rest.length >= 3
        ? argResults!.rest[2]
        : 'Unknown';

    final config = loadConfigOrExit();
    if (config == null) return;

    await generateUsecase(
      config: config,
      featureName: featureName,
      usecaseName: usecaseName,
      author: author,
    );
  }
}
