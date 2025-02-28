import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_event_handler.dart';

class ZebraRfidSdkPlugin {
  static const MethodChannel _channel =
      MethodChannel('com.example.zebra_rfid_sdk_plugin/plugin');
  static const EventChannel _eventChannel =
      EventChannel('com.example.zebra_rfid_sdk_plugin/event_channel');
  static ZebraEngineEventHandler? _handler;

  static Future<String?> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> toast(String text) async {
    return _channel.invokeMethod('toast', {"text": text});
  }

  // set power
  static Future<dynamic> setPower(int power) async {
    return _channel.invokeMethod('setPower', {"power": power});
  }

  ///
  static Future<dynamic> onRead() async {
    return _channel.invokeMethod('startRead');
  }

  ///
  static Future<dynamic> write(
    String sourceEPC,
    String rfidPassword,
    String targetEPC,
    String type,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>('write', {
        "sourceEPC": sourceEPC,
        "rfidPassword": rfidPassword,
        "targetEPC": targetEPC,
        "type": type,
      });
      return result ?? "Success";
    } on PlatformException catch (e) {
      return "Error: ${e.message}";
    }
  }

  ///
  static Future<String> lockTag(String sourceEPC) async {
    try {
      final result = await _channel.invokeMethod<String>('lock', {
        "sourceEPC": sourceEPC,
      });
      return result ?? "Success";
    } on PlatformException catch (e) {
      return "Error: ${e.message}";
    }
  }

  ///connect device
  static Future<dynamic> connect() async {
    try {
      await _addEventChannelHandler();
      var result = await _channel.invokeMethod('connect');
      return result;
    } catch (e) {
      var a = e;
    }
  }

  ///disconnect device
  static Future<dynamic> disconnect() async {
    return _channel.invokeMethod('disconnect');
  }

  /// Sets the engine event handler.
  ///
  /// After setting the engine event handler, you can listen for engine events and receive the statistics of the corresponding [RtcEngine] instance.
  ///
  /// **Parameter** [handler] The event handler.
  static void setEventHandler(ZebraEngineEventHandler handler) {
    _handler = handler;
  }

  static StreamSubscription<dynamic>? _sink;
  static Future<void> _addEventChannelHandler() async {
    _sink ??= _eventChannel.receiveBroadcastStream().listen((event) {
      final eventMap = Map<String, dynamic>.from(event);
      final eventName = eventMap['eventName'] as String;
      // final data = List<dynamic>.from(eventMap['data']);
      _handler?.process(eventName, eventMap);
    });
  }

  ///dispose device
  static Future<dynamic> dispose() async {
    _sink = null;
    return _channel.invokeMethod('dispose');
  }
}
