import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_status.dart';
import '../models/blocked_site.dart';

class BlockingService {
  static const MethodChannel _channel = MethodChannel('com.prisonit.app/blocking');
  static const String _statusKey = 'prisonit_app_status';

  static Future<AppStatus> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_statusKey);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final map = jsonDecode(rawJson);
        return AppStatus.fromJson(map);
      } catch (_) {}
    }

    return AppStatus();
  }

  static Future<bool> saveStatus(AppStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(status.toJson());
    await prefs.setString(_statusKey, jsonStr);

    try {
      await _channel.invokeMethod('syncStatus', jsonStr);
    } catch (_) {}

    return true;
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool enabled = await _channel.invokeMethod('isAccessibilityEnabled');
      return enabled;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  static Future<bool> isDeviceAdminActive() async {
    try {
      final bool active = await _channel.invokeMethod('isDeviceAdminActive');
      return active;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestDeviceAdminPermission() async {
    try {
      await _channel.invokeMethod('requestDeviceAdmin');
    } catch (_) {}
  }

  static Future<void> startLocalVpn() async {
    try {
      await _channel.invokeMethod('startVpn');
    } catch (_) {}
  }
}
