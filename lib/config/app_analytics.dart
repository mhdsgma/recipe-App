import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AppAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logLoginAttempt({required bool emailEntered}) async {
    await _analytics.logEvent(
      name: 'login_attempt',
      parameters: {'email_entered': emailEntered ? 'yes' : 'no'},
    );
  }

  static Future<void> logLoginSuccess({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logLoginFailedEmptyFields() async {
    await _analytics.logEvent(name: 'login_failed_empty_fields');
  }

  static Future<void> logAndroidDeviceInfo() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final android = await deviceInfo.androidInfo;

      String? trim(String? value) {
        if (value == null) return null;
        return value.length > 36 ? value.substring(0, 36) : value;
      }

      final model = trim(android.model);
      final manufacturer = trim(android.manufacturer);

      if (model != null) {
        await _analytics.setUserProperty(name: 'device_model', value: model);
      }

      if (manufacturer != null) {
        await _analytics.setUserProperty(
          name: 'manufacturer',
          value: manufacturer,
        );
      }

      await _analytics.logEvent(
        name: 'login_device_info',
        parameters: {
          'brand': android.brand,
          'device': android.device,
          'model': android.model,
          'product': android.product,
          'manufacturer': android.manufacturer,
          'hardware': android.hardware,
          'version_sdk': android.version.sdkInt.toString(),
          'version_release': android.version.release,
        },
      );
    }
  }
}
