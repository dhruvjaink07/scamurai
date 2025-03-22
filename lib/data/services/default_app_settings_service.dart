import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class DefaultAppSettingsService {
  /// Opens the Default Apps settings to allow the user to set this app as the default browser
  void openDefaultAppSettings() {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      intent.launch();
    }
  }
}
