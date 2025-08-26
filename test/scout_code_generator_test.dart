import 'package:flutter_test/flutter_test.dart';
import 'package:scout_code_generator/scout_code_generator.dart';
import 'package:scout_code_generator/scout_code_generator_platform_interface.dart';
import 'package:scout_code_generator/scout_code_generator_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScoutCodeGeneratorPlatform
    with MockPlatformInterfaceMixin
    implements ScoutCodeGeneratorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScoutCodeGeneratorPlatform initialPlatform = ScoutCodeGeneratorPlatform.instance;

  test('$MethodChannelScoutCodeGenerator is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScoutCodeGenerator>());
  });

  test('getPlatformVersion', () async {
    ScoutCodeGenerator scoutCodeGeneratorPlugin = ScoutCodeGenerator();
    MockScoutCodeGeneratorPlatform fakePlatform = MockScoutCodeGeneratorPlatform();
    ScoutCodeGeneratorPlatform.instance = fakePlatform;

    expect(await scoutCodeGeneratorPlugin.getPlatformVersion(), '42');
  });
}
