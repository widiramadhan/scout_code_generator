import 'dart:io';

/// Internal config loader untuk scout
class Config {
  final String model;
  final String entity;
  final String datasource;
  final String repository;
  final String usecase;
  final String ui;
  final String controller;
  final String stateManagement;

  Config({
    required this.model,
    required this.entity,
    required this.datasource,
    required this.repository,
    required this.usecase,
    required this.ui,
    required this.controller,
    required this.stateManagement,
  });
}

/// Baca config dari `scout_config.dart`
/// Jika tidak ada, keluar program
Config loadConfigOrExit() {
  final file = File('scout_config.dart');
  if (!file.existsSync()) {
    stderr.writeln(
      '[x] scout_config.dart tidak ditemukan. Jalankan `scout init` dulu.',
    );
    exit(1);
  }

  final text = file.readAsStringSync();

  String _extract(String key) {
    final reg = RegExp('static const String $key = "(.*)";');
    final match = reg.firstMatch(text);
    if (match == null) {
      stderr.writeln('[x] Key "$key" tidak ditemukan di scout_config.dart');
      exit(1);
    }
    return match.group(1)!;
  }

  return Config(
    model: _extract('model'),
    entity: _extract('entity'),
    datasource: _extract('datasource'),
    repository: _extract('repository'),
    usecase: _extract('usecase'),
    ui: _extract('ui'),
    controller: _extract('controller'),
    stateManagement: _extract('stateManagement'),
  );
}

bool validateConfig(Config config) {
  final paths = [
    config.model,
    config.entity,
    config.datasource,
    config.repository,
    config.usecase,
    config.ui,
    config.controller,
  ];

  // valid kalau semua path masih mengandung "features_name"
  return paths.every((p) => p.contains("features_name"));
}
