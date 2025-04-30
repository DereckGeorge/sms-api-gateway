import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'telephony_plugin_method_channel.dart';

abstract class TelephonyPluginPlatform extends PlatformInterface {
  /// Constructs a TelephonyPluginPlatform.
  TelephonyPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TelephonyPluginPlatform _instance = MethodChannelTelephonyPlugin();

  /// The default instance of [TelephonyPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelTelephonyPlugin].
  static TelephonyPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TelephonyPluginPlatform] when
  /// they register themselves.
  static set instance(TelephonyPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
