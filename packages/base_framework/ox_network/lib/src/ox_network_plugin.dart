
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class OXNetworkPlugin {
  static const MethodChannel _channel =
      const MethodChannel('ox_network');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getProxyAddress(String url) async {
    if (Platform.isMacOS) {
      return '';
    }
    final String version = await _channel.invokeMethod('getProxyAddress', { 'url': url });
    return version;
  }

}