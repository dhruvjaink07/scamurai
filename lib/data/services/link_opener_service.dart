import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class LinkOpenerService {
  void openLinkWithBrowserChooser(String link, String packageName) {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: link,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        package: packageName,
      );
      intent.launchChooser("Open link with");
    }
  }
}
