import 'package:flutter_test/flutter_test.dart';
import 'package:telephony_plugin/telephony_plugin.dart';
import 'package:telephony_plugin/telephony_plugin_platform_interface.dart';
import 'package:telephony_plugin/telephony_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTelephonyPluginPlatform
    with MockPlatformInterfaceMixin
    implements TelephonyPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TelephonyPluginPlatform initialPlatform = TelephonyPluginPlatform.instance;

  test('$MethodChannelTelephonyPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTelephonyPlugin>());
  });

  test('getPlatformVersion', () async {
    TelephonyPlugin telephonyPlugin = TelephonyPlugin();
    MockTelephonyPluginPlatform fakePlatform = MockTelephonyPluginPlatform();
    TelephonyPluginPlatform.instance = fakePlatform;

    expect(await telephonyPlugin.getPlatformVersion(), '42');
  });
}
